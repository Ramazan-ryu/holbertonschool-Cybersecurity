# MedDefense Detection Engineering Specification

## Purpose
This document establishes the technical specifications and data contracts governing the MedDefense detection engine pipeline layer. It defines the formal operational standards required to engineer, execute, tune, prioritize, and hand off security alerts to downstream Tier 1 triage workflows inside the production catalog context.

## Inputs
The pipeline relies on these explicit directory structures and environmental variable targets to resolve paths and satisfy component dependency conditions:
* `$HANDOFF_DIR` (Defaults to `~/3x00_handoff`): Contains historical security log inputs and `context/asset_inventory.json`.
* `$ASSETS_DIR` (Defaults to `~/3x02_assets`): Houses the corporate risk repository (`risk_register.json`).
* `$BASELINE_PKG`: Points to log collections used during False Positive (FP) baseline calculations.
* `$CATALOG_DIR` (Defaults to `~/3x02_package/detection_catalog/`): The deployment target root directory.

## Rule Authoring Standard
All detection analytics must be authored inside standard Sigma (`.yml`) files using this format:
* **Sigma Structure and Required Fields**: `id` (UUIDv4), `title`, `status` (experimental/stable), `description`, `author`, `logsource` (category/product), `detection` (selection/condition), `level` (low/medium/high/critical).
* **Naming Convention**: Rules must follow the explicit naming standard using lower-case snake_case prefixed by a three-digit sequence index matching the detection intent (e.g., `001_ssh_brute_force.yml`).
* **ATT&CK Tag Requirement**: Every rule must contain a tags section map indicating valid MITRE ATT&CK technique identifiers (e.g., `attack.t1110.001`).

## Execution Model
The detection engine operates as a scheduled batch execution pipeline over fixed evaluation windows:
* **The Runner**: `3-sigma_runner.sh` parses active rule signatures and evaluates them against target log streams.
* **Preprocessing Primitives**: Logging entries pass through `8-correlation_primitives.py` preprocessing code to standardize field schemas into normalization matrices.
* **Window Semantics**: The runner evaluates target events over a specific lookback window using the `--window` parameter, processing event groupings sequentially with clear window semantics.

## Quality Thresholds
Rules cannot be promoted to the production catalog without meeting strict statistical gates and concrete quality thresholds:
* **Precision ($P$)**: $$P = \frac{TP}{TP + FP} \ge 0.80$$ (Minimum 80% precision target).
* **Recall ($R$)**: $$R = \frac{TP}{TP + FN} \ge 0.75$$ (Minimum 75% recall target).
* **F1-Score ($F_1$)**: $$F_1 = 2 \cdot \frac{P \cdot R}{P + R} \ge 0.70$$ (Minimum 70% F1-score balance).
* **False Positive Rate (FPR)**: Must be less than 5% (FPR < 5%) against historical `fp_baseline.json` data.

## Tuning Protocol
When a production rule becomes noisy and violates quality thresholds by generating excessive false positives:
* **Isolation**: The original rule signature is isolated, modified via exclusions, and stored inside `rules/tuned/`.
* **Modality**: Scope tuning narrowing filters out benign system behaviors (e.g., service accounts) to stop noisy false positives without blinding core logic.
* **Validation**: `11-tune_rules.sh` tests the variant against the baseline to validate and verify threshold compliance before deployment.

## Risk Ranking Model
Alert priority is determined mathematically by mapping detections directly to systemic risk targets:
* **Risk Score**: Derived from the centralized `risk_register.json` risk register based on threat likelihood and impact.
* **Quality Discounting**: The raw risk value is multiplied by the rule's verified F1 score to establish the priority_score.
* **Formula**:
    $$\text{priority\_score} = \text{risk\_score} \cdot F_1$$
* **Orphans**: Rules with no matching threat scenario in the risk register evaluate to a score of `0.0`.

## Outputs
The pipeline outputs the finalized `alert_queue.json` array adhering strictly to `alert_queue_schema.json` for downstream 3x03 contract handoff:
* **Alert Queue Schema Fields**: Contains `alert_id`, `rule_id`, `priority_score`, `event_summary`, `status`, `severity`, `timestamp`, `evidence_hash`.
* **Downstream 3x03 Contract**: Alerts are deduplicated using a sliding 60-second window on the `(rule_id, hostname, user)` key. The array is sorted descending by `priority_score`, breaking ties by `timestamp` ascending.

## Failure Modes
* **Schema Key Mismatch (`KeyError`)**: Ingestion pipeline crashes. Observable symptoms include a complete halt of the downstream data flow and fatal Python stack traces.
* **Deduplication Blindness**: Extreme alert floods. Symptoms present as identical duplicate records spiking within the same minute, overwhelming analysts.
* **Context Asynchrony**: Missing asset metadata. Observable symptoms include null fields within `asset_context` arrays inside `alert_queue.json`.

## Reviewer Checklist
* [ ] Review the filename to confirm it strictly follows the three-digit snake_case standard pattern.
* [ ] Verify and validate that all mandatory Sigma fields, UUIDv4 identifiers, and ATT&CK tags are fully populated.
* [ ] Run `13-rule_quality.sh` to check and confirm that the rule passes the minimum numeric precision and F1 threshold targets.
* [ ] Check and test that the rule output successfully parses against the strict JSON compilation schema.
