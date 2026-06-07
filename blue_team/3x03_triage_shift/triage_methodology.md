# MedDefense SOC Triage Methodology

## Classification Taxonomy
* **true_positive**: Confirmed malicious or highly unauthorized activity matching adversarial behavior, such as a rule `010_credential_theft_chain` trigger where `canonical_label` equals `credential_dumping`.
* **false_positive**: Non-malicious, authorized activity triggered by safe system operations or administrative behavior, such as an off-hours patching cycle firing `002_windows_offhours_privileged_logon`.
* **benign**: Known safe, routine system noise requiring closure but no remediation, such as a verified background clinical device sync triggering `012_medical_segment_egress`.
* **escalated**: Suspicious activity requiring advanced investigation or active incident response, such as rule `011_patient_data_access` firing outside an analyst's visibility matrix.

## Priority Ordering Rule
Analysts must process the triage queue in strict descending order of the `priority_score` attribute. A manual priority override is permitted only when an alert references a high-criticality asset identified via the `criticality` field inside `asset_inventory.json` or when multiple related rules target a single host within a 15-minute window.

## Evidence Requirement
Each classification requires explicit telemetry validation mapped by field names from `enriched_events.json`:
* **true_positive / escalated**: Requires tracking a matching malicious indicator string in `ioc_context.json` via the `src_ip` or `dst_ip` fields.
* **false_positive / benign**: Requires matching the `user` or `process_name` fields against known whitelisted entries within `baseline_summary.json`.

## Escalation Criteria
An alert must be immediately escalated to a Tier 2 responder if any of the following boolean predicates evaluate to true:
* `has_malicious_ioc == true` AND `asset_zone == "medical_devices"`
* `rule_level == "critical"` AND `shift_hour_match == false`
* `canonical_label == "credential_dumping"` AND `is_domain_controller == true`
* `unauthorized_path_access == true` AND `account_is_privileged == true`

## SLA
The strict maximum time budgets allowed from alert ingestion to final ticket classification are:
* **Critical (Priority >= 20)**: 15 minutes.
* **High (Priority 10–19)**: 30 minutes.
* **Medium (Priority 5–9)**: 60 minutes.
* **Low (Priority 1–4)**: Same day / end of active shift.

## Documentation Standard
Every generated triage ticket must fulfill this absolute compliance closure checklist:
* [ ] `ticket_id`: Deterministic UUID generated directly from the unique source `alert_id`.
* [ ] `alert_id`: Verifiable lookup string pointing back to the core queue.
* [ ] `classification`: One of `true_positive`, `false_positive`, `benign`, or `escalated`.
* [ ] `justification`: Concise statement naming the specific field and value driving the choice.
* [ ] `evidence_refs`: Array containing at least one explicit log `event_ref` tracking pointer.
* [ ] `ioc_hits`: Extracted list of all matching metadata artifacts from `ioc_context.json`.
* [ ] `attack_techniques`: String list of copied MITRE ATT&CK technique IDs.
* [ ] `recommended_action`: Explicitly marked as `close`, `escalate_tier2`, `monitor`, or `tune_rule`.
* [ ] `analyst_time_seconds`: Ingestion processing latency duration metrics.
* [ ] `created_at`: Compliant ISO 8601 UTC timestamp format (`YYYY-MM-DDTHH:MM:SSZ`).
