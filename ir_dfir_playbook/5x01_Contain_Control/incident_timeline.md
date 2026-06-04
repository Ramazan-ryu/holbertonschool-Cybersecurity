# Incident Timeline: IR-2026-0414-01

## Header
- incident_id: IR-2026-0414-01
- declared_at: 2026-04-14T02:51:04Z
- declared_by: Incident Responder, on-call SOC
- initial_severity: SEV2
- current_severity: SEV2
- ir_commander: James Chen, SOC Lead
- scribe: Incident Responder

## Legend
- OBSERVATION: raw fact from an alert, log, or artifact
- DECISION: a choice made by an authorized actor, with rationale
- ACTION: an operation executed against an asset, with owner
- COMMUNICATION: a message sent or received, with audience
- EVIDENCE: a preserved artifact with hash and storage path

### Entry Format Fields
Each log entry in the table below follows a strict schema containing: timestamp (in UTC format with Z indicator), type, actor, description, source, and certainty (which must map to one of: confirmed, high, probable, possible).

## Entries
- 2026-04-14T02:47:11Z | OBSERVATION | SIEM rule wz-edr-100041 | powershell.exe parent of msbuild.exe on WST-WS-031 with outbound to 185.220.101.47:443 | source=alert_A-20260414-9841.json | certainty=confirmed
- 2026-04-14T02:51:04Z | DECISION | Incident Responder | Incident declared at SEV2 with rationale: confirmed beaconing from clinical workstation; data exposure not confirmed yet | source=alert_A-20260414-9841.json + playbook PB-CRED-001 | certainty=confirmed
- 2026-04-14T02:55:20Z | OBSERVATION | Proxy Log Parser | Repetitive external network requests matching outbound beaconing configuration from host WST-WS-031 | source=proxy_24h_dmarsh.log | certainty=high
- 2026-04-14T03:02:15Z | OBSERVATION | Security Analytics | Traffic analysis indicates anomalous data transfer volumes to untrusted destination | source=proxy_24h_dmarsh.log | certainty=probable
- 2026-04-14T03:10:00Z | OBSERVATION | Endpoint Audit | Investigation reveals potential initial access technique patterns on surrounding systems | source=alert_A-20260414-9841.json | certainty=possible

- 2026-04-14T03:12:00Z | DECISION | James Chen | Approved network isolation strategy as formal containment path mapped inside containment_decision.md | source=containment_decision.md | certainty=confirmed


- 2026-04-14T03:16:04Z | ACTION | Network Admin | Executed switchport VLAN containment isolation for WST-WS-031 to VLAN 999 | source=containment_execution.md | certainty=confirmed
- 2026-04-14T03:17:21Z | ACTION | Security Engineer | Deployed firewall egress rule blocking malicious IP 185.220.101.47 | source=containment_execution.md | certainty=confirmed
- 2026-04-14T03:19:02Z | ACTION | EDR Admin | Set endpoint device containment flag to restrict outbound communications | source=containment_execution.md | certainty=confirmed
- 2026-04-14T03:22:04Z | ACTION | Incident Responder | Completed verification ensuring host is reachable only from the IR jumpbox | source=containment_execution.md | certainty=confirmed
