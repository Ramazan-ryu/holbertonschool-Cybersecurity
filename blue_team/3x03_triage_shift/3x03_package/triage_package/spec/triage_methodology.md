# MedDefense SOC Triage Methodology

## Classification Taxonomy
* **true_positive**: Malicious activity matching threat scenarios. Example: a rule `010_credential_theft_chain` alert with malicious actions.
* **false_positive**: Authorized activity triggering safe alerts. Example: an off-hours patching cycle firing `002_windows_offhours_privileged_logon`.
* **benign**: Safe system noise requiring standard closure. Example: a clinical background device synchronization triggering `012_medical_segment_egress`.
* **escalated**: Suspicious activity requiring advanced investigation. Example: rule `011_patient_data_access` firing outside visible analyst matrices.

## Priority Ordering Rule
Analysts must process the triage queue in strict descending order of the `priority_score` attribute. A manual override condition is permitted only when an alert references high-criticality assets inside `asset_inventory.json` or when multiple rules target a single host.

## Evidence Requirement
Each classification requires explicit telemetry verification from `enriched_events.json` tracking fields:
* **true_positive / escalated**: Requires verification of malicious domain strings or indicators using `src_ip`, `dst_ip`, and log `severity` levels.
* **false_positive / benign**: Requires checking rule criteria using `user`, `hostname`, `timestamp`, or `process_name`.

## Escalation Criteria
An alert must be immediately escalated to a Tier 2 responder if any of these boolean conditions are true:
* `has_malicious_ioc == true` AND `asset_zone == "medical_devices"`
* `rule_level == "critical"` AND `shift_hour_match == false`
* `canonical_label == "credential_dumping"` AND `is_domain_controller == true`

## SLA
The maximum time budgets allowed from ingestion to final classification are:
* **critical**: 15 minutes.
* **high**: 30 minutes.
* **medium**: 60 minutes.
* **low**: Same day or end of active shift.

## Documentation Standard
Every generated triage ticket must fulfill this compliance checklist:
* [ ] `ticket_id`: Deterministic UUID derived from the unique `alert_id`.
* [ ] `alert_id`: Verifiable lookup tracker.
* [ ] `classification`: Marked classification choice.
* [ ] `justification`: Specific field and value text.
* [ ] `evidence_refs`: Array of log pointers.
* [ ] `ioc_hits`: Extracted list from `ioc_context.json`.
* [ ] `attack_techniques`: String list of ATT&CK IDs.
* [ ] `recommended_action`: Action choice.
* [ ] `analyst_time_seconds`: Duration metrics.
* [ ] `created_at`: ISO 8601 UTC timestamp.
