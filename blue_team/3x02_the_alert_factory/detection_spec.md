# MedDefense Detection Engineering Specification

## Purpose
This document establishes the technical specifications and data contracts governing the MedDefense detection engine pipeline. It defines the formal operational standards required to engineer, execute, tune, prioritize, and hand off security alerts to downstream Tier 1 triage workflows within the centralized catalog framework.

## Inputs
The pipeline processes raw data inputs by resolving dependency path mappings through these environment variables:
* `$HANDOFF_DIR`: Resolves the path containing historical logs and `context/asset_inventory.json`.
* `$ASSETS_DIR`: Resolves the path housing the corporate `risk_register.json`.
* `$BASELINE_PKG`: Resolves the path to the original raw validation telemetry.
* `$CATALOG_DIR`: Resolves the path pointing to the unified asset delivery destination root.

## Rule Authoring Standard
All detection analytics must be authored inside standard Sigma (`.yml`) files using this format:
* **Required Fields**: `id`, `title`, `status`, `description`, `author`, `logsource`, `detection`, `condition`, `level`.
* **Naming Convention**: Rules must use lower-case snake_case prefixed by a three-digit sequence index matching the detection intent (e.g., `001_ssh_brute_force.yml`).
* **ATT&CK Tag Requirement**: Every rule must contain a tags section map indicating valid MITRE ATT&CK technique identifiers prefixed with `attack.`.

## Execution Model
The batch pipeline processes security analytics under this operational execution model:
* **The Runner**: `3-sigma_runner.sh` coordinates signature validation across raw audit trails.
* **Preprocessing Primitives**: `8-correlation_primitives.py` flattens data schemas before logic execution.
* **Window Semantics**: Telemetry ingestion uses a sliding evaluation window via the `--window` lookback parameter to group events dynamically.

## Quality Thresholds
Rules cannot be promoted to production without clearing these statistical quality gates:
* **Precision ($P$)**: $$P = \frac{TP}{TP + FP} \ge 0.80$$ (Minimum 80% accuracy).
* **Recall ($R$)**: $$R = \frac{TP}{TP + FN} \ge 0.75$$ (Minimum 75% coverage).
* **F1-Score ($F_1$)**: $$F_1 = 2 \cdot \frac{P \cdot R}{P + R} \ge 0.70$$ (Minimum 0.70 balance).
* **False Positive Rate (FPR)**: Must be $< 5\%$ against the verified `fp_baseline.json` package profile.

## Tuning Protocol
When a noisy rule breaches quality thresholds by creating high false positive volumes:
* **Isolation**: Engineers copy the rule signature out of the baseline stack and place it into `rules/tuned/`.
* **Modification**: Benign system profiles or service accounts are excluded from the match criteria.
* **Validation**: The new rule iteration is tested via execution against historical log baselines to confirm false positive suppression before deployment.

## Risk Ranking Model
The generation engine derives each record's explicit `priority_score` from risk register entries:
* **Calculation Engine**: Raw values from `risk_register.json` are cross-referenced against active rules.
* **Discounting Scale**: The baseline vulnerability impact score is multiplied by the rule's verified $F_1$ performance metric:
$$\text{priority\_score} = \text{risk\_score} \cdot F_1$$
* **Orphan Handling**: Unmapped rules without a threat profile entry drop to a value of `0.0`.

## Outputs
The pipeline writes output entries to `alert_queue.json` following the structural data validation boundaries defined by the downstream 3x03 contract:
* **Schema Fields**: Every record requires an `alert_id`, `rule_id`, `priority_score`, `event_summary`, `status`, and `evidence_hash`.
* **Downstream Delivery Contract**: Alerts are deduplicated inside a sliding 60-second frame using a unique triple key hash (`rule_id`, `hostname`, `user`) and sorted descending by `priority_score` with an ascending timestamp tie-breaker.

## Failure Modes
* **Schema Key Mismatch**: Breaks structural parser functions. Observable symptom shows immediate stack traces on ingestion and total pipeline halt.
* **Deduplication Blindness**: Occurs if the lookback window fails. Observable symptom shows alert storms filling storage pools with identical entries within 60 seconds.
* **Context Asynchrony**: Missing asset metadata feeds. Observable symptom shows missing risk scores causing alerts to drop to an orphan state value of `0.0`.

## Reviewer Checklist
* [ ] Verify that the file naming standard follows the exact three-digit snake_case prefix rules.
* [ ] Confirm that all mandatory parameters, including UUID identifiers and explicit ATT&CK tag targets, are valid.
* [ ] Check that the signature cleared execution trials without generating an FPR above the 5% threshold gate.
* [ ] Run validation tests against output targets to ensure correct structure mapping.
