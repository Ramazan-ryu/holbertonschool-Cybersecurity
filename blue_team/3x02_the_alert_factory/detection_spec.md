# MedDefense Detection Engineering Specification

## Purpose
This document establishes the technical specifications and data contracts governing the MedDefense detection engine pipeline. It defines the formal operational standards required to engineer, execute, tune, prioritize, and hand off security alerts to downstream Tier 1 triage workflows.

## Inputs
The execution engine processes log data using these explicit dependency path structures and environmental variables to resolve their location:
* `$HANDOFF_DIR` (Defaults to `~/3x00_handoff`): Resolves the input baseline logs and asset inventory profile mapping context (`context/asset_inventory.json`).
* `$ASSETS_DIR` (Defaults to `~/3x02_assets`): Points to the central file dependency root for systemic organization risk targets (`risk_register.json`).
* `$BASELINE_PKG`: Evaluates test framework noise paths during historical False Positive calculation routines.
* `$CATALOG_DIR` (Defaults to `~/3x02_package/detection_catalog`): Establishes the designated assembly deployment output destination folder for every final rule and configuration file payload.

## Rule Authoring Standard
All detection analytics must be authored inside standard Sigma (`.yml`) files using this format:
* **Sigma Structure and Required Fields**: `id` (UUIDv4), `title`, `status` (experimental/stable), `description`, `author`, `logsource` (category/product), `detection` (selection/condition), `level` (low/medium/high/critical).
* **Naming Convention**: Lower-case snake_case prefixed by a three-digit sequence index matching the detection catalog intent (e.g., `001_ssh_brute_force.yml`).
* **ATT&CK Tag Requirement**: Every logic document must declare explicit `tags` indicating valid MITRE ATT&CK technique matrix indicators (e.g., `attack.t1110.001`).

## Execution Model
The analytics core processes inputs via a batch execution pipeline with clear window semantics:
* **The Runner**: `3-sigma_runner.sh` orchestrates signature evaluations against target data feeds using lookback controls.
* **Preprocessing Primitives**: Logging logs pass through `8-correlation_primitives.py` to map properties cleanly onto standardized fields.
* **Window Semantics**: The execution suite runs sequential lookbacks using the `--window` execution parameter flags to query distinct event telemetry ranges cleanly.

## Quality Thresholds
Rules cannot be promoted to the production catalog without passing concrete numeric gates:
* **Precision ($P$)**: $$P = \frac{TP}{TP + FP} \ge 0.80$$ (Minimum 80% genuine signal ratio required)
* **Recall ($R$)**: $$R = \frac{TP}{TP + FN} \ge 0.75$$ (Minimum 75% attack coverage match target)
* **F1-Score ($F_1$)**: $$F_1 = 2 \cdot \frac{P \cdot R}{P + R} \ge 0.70$$ (Overall harmonic balance threshold)
* **False Positive Rate (FPR)**: Must be $< 5\%$ against historical baseline matrices.

## Tuning Protocol
When a production signature runs noisy and triggers false positive alerts above bounds:
* **Isolation**: The filter logic is modified inside a dedicated copy within `rules/tuned/`.
* **Exclusion**: Narrow target adjustments weed out recurring background operations without blinding core behavior indicators.
* **Validation**: The script `11-tune_rules.sh` tests the adjusted variant against historical logs to validate it satisfies error budget constraints before merge approval.

## Risk Ranking Model
Alert priority values are calculated dynamically using metadata pulled directly from the risk register:
* **Risk Score**: Derived from `risk_register.json` based on business impact vectors.
* **Quality Discounting**: The raw risk value is multiplied by the rule's verified $F_1$ matrix rating.
* **Formula**:
    $$\text{priority\_score} = \text{risk\_score} \cdot F_1$$
* **Orphans**: Signatures missing matching threat records inside the company master register default to a baseline score of `0.0`.

## Outputs
Alert batches compile cleanly onto disk within `alert_queue.json` following the structural criteria defined by `alert_queue_schema.json`:
* **Schema Fields**: Each item populates `alert_id` (UUIDv5 derived from rule and event references), `rule_id`, `priority_score`, `event_summary`, and `status`.
* **Downstream 3x03 Contract**: Data entries are deduplicated via a sliding 60-second window key. The array sorts descending by `priority_score`, using event timestamp ascending as a fallback tie-breaker.

## Failure Modes
* **Schema Key Mismatch (`KeyError`)**: 
    * *Observable Symptom*: The pipeline fails entirely during the prioritization phase, logging missing dictionary fields.
* **Deduplication Blindness**: 
    * *Observable Symptom*: Downstream consumers receive multiple near-identical events, creating an alert storm that buries high-priority incidents.
* **Context Asynchrony**: 
    * *Observable Symptom*: Generated alert objects contain blank or empty records within the critical asset context parameters.

## Reviewer Checklist
* [ ] Verify the file title and name comply exactly with the lower-case `###_snake_case.yml` syntax format rule.
* [ ] Check that all required structural fields (including a valid UUIDv4 and ATT&CK tags) are completely populated.
* [ ] Run `13-rule_quality.sh` to confirm the rule achieves an F1-score metric performance of at least 0.70.
* [ ] Validate that the generated alert output formats compile against `alert_queue_schema.json` without errors.
