# MedDefense Detection Engineering Specification

## Purpose
This document establishes the technical specifications and data contracts governing the MedDefense detection engine pipeline. It defines the formal operational standards required to engineer, execute, tune, prioritize, and hand off security alerts to downstream Tier 1 triage workflows.

## Inputs
The pipeline relies on these explicit directory structures and environmental variable targets:
* `$HANDOFF_DIR` (Defaults to `~/3x00_handoff`): Contains historical security log inputs and `context/asset_inventory.json`.
* `$ASSETS_DIR` (Defaults to `~/3x02_assets`): Houses the corporate risk repository (`risk_register.json`).
* `$BASELINE_PKG`: Points to log collections used during False Positive (FP) baseline calculations.

## Rule Authoring Standard
All detection analytics must be authored inside standard Sigma (`.yml`) files using this format:
* **Required Fields**: `id` (UUIDv4), `title`, `status` (experimental/stable), `description`, `author`, `logsource` (category/product), `detection` (selection/condition), `level` (low/medium/high/critical).
* **Naming Convention**: Rules must use lower-case snake_case prefixed by a three-digit sequence index matching the detection intent (e.g., `001_ssh_brute_force.yml`).
* **ATT&CK Tagging**: Every rule must contain a `tags` section map indicating valid MITRE ATT&CK technique identifiers (e.g., `attack.t1110.001`).

## Execution Model
The detection engine operates as a scheduled batch execution pipeline over fixed evaluation windows:
1.  **The Runner**: `3-sigma_runner.sh` parses active rule signatures and evaluates them against target log streams.
2.  **Preprocessing Primitives**: Logging entries pass through `8-correlation_primitives.py` to standardize field schemas into normalization matrices.
3.  **Window Semantics**: The runner evaluates target events over a specific lookback window using the `--window` parameter, processing event groupings sequentially.

## Quality Thresholds
Rules cannot be promoted to the production catalog without meeting strict statistical gates:
* **Precision ($P$)**: $$P = \frac{TP}{TP + FP} \ge 0.80$$ for critical pathways.
* **Recall ($R$)**: $$R = \frac{TP}{TP + FN} \ge 0.75$$ across test telemetry matrices.
* **F1-Score ($F_1$)**: $$F_1 = 2 \cdot \frac{P \cdot R}{P + R} \ge 0.70$$ balance score.
* **False Positive Rate (FPR)**: Must be $< 5\%$ against historical `fp_baseline.json` data.

## Tuning Protocol
When a production rule violates quality thresholds by generating excessive false positives:
1.  **Isolation**: The original rule signature is modified via exclusions in a dedicated copy inside `rules/tuned/`.
2.  **Modality**: Scope narrowing filters out benign system behaviors (e.g., service accounts, specific host zones) without blinding the core logic.
3.  **Validation**: `11-tune_rules.sh` tests the variant against the baseline to verify threshold compliance before deployment.

## Risk Ranking Model
Alert priority is determined mathematically by mapping detections directly to systemic risk targets:
1.  **Risk Score**: Derived from `risk_register.json` based on threat likelihood and impact.
2.  **Quality Discounting**: The raw risk value is multiplied by the rule's verified $F_1$ score.
3.  **Formula**:
    $$\text{priority\_score} = \text{risk\_score} \cdot F_1$$
4.  **Orphans**: Rules with no matching threat scenario in the register evaluate to a score of `0.0`.

## Outputs
The pipeline outputs the finalized `alert_queue.json` array adhering strictly to `alert_queue_schema.json`:
* **Fields**: `alert_id` (UUIDv5), `generated_at`, `rule_id`, `rule_title`, `rule_level`, `priority_score`, `event_ref`, `event_summary` (flattened metadata), `asset_context`, `attack_techniques`, `status`, `evidence_hash`.
* **Downstream Contract**: Alerts are deduplicated using a sliding 60-second window on the `(rule_id, hostname, user)` key. The array is sorted descending by `priority_score`, breaking ties by `event_summary.timestamp` ascending.

## Failure Modes
* **Schema Key Mismatch (`KeyError`)**: Occurs if internal schemas mismatch down-level consumers (e.g., querying `rule_title` instead of `rule_name`), breaking ingestion.
* **Deduplication Blindness**: Occurs if the sliding 60-second time tracking logic fails, causing alert storms that bury high-priority incidents.
* **Context Asynchrony**: Occurs if `asset_inventory.json` is missing or unreadable, stripping risk context from triage records.

## Reviewer Checklist
* [ ] Does the filename strictly match the `###_snake_case.yml` format standard?
* [ ] Are all mandatory fields populated, including valid UUIDv4 IDs and explicit MITRE ATT&CK tags?
* [ ] Has the rule been evaluated by `13-rule_quality.sh` to confirm it passes the minimum $F_1 \ge 0.70$ threshold?
* [ ] Does the rule successfully parse against `alert_queue_schema.json` without throwing structural errors?
