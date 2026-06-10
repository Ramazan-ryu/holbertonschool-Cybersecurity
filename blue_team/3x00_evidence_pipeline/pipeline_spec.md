# Overview
The evidence pipeline ingest, normalizes, validates, and enriches disparate digital forensics telemetry from a compromised system into an indexed threat-hunting repository. The entire pipeline executes via a single orchestration command, accepting an unprivileged absolute path to an input evidence pack directory to build the target incident timeline.

# Stage Table
| Stage | Script | Input | Output | Failure Modes |
| :--- | :--- | :--- | :--- | :--- |
| 0 | `0-source_inventory.sh` | Evidence pack directory | `source_inventory.json` | Missing directory; permissions error; malformed file structure; invalid JSON generation |
| 1 | `1-telemetry_import.sh` | Evidence pack, `source_inventory.json` | `import_validation.json` | Corrupted CSV/JSON/Syslog archives; mismatching file hashes; extraction timeout |
| 2 | `2-windows_parse.sh` | Imported EVTX JSON files | `windows_events.json` | Missing EVTX files; internal parsing exceptions; string encoding corruption |
| 3 | `3-linux_parse.sh` | Imported `auth.log`, `syslog`, `audit.log` | `linux_events.json` | Unknown date formats; incomplete text records; missing raw logs |
| 5 | `5-normalize.sh` | `windows_events.json`, `linux_events.json` | `normalized_events.json`, `quarantine.json` | Broken field maps; zero compliant records; file write lock |
| 6 | `6-network_normalize.sh`| `firewall.csv`, `suricata_eve.json`, `pcap_summary.json` | `network_events.json`, appends to `normalized_events.json` | Corrupt lines; epoch translation out of bounds; empty telemetry sources |
| 7 | `7-schema_validate.sh` | `normalized_events.json`, `event_schema.json` | `validation_report.json` | Compliance drops below 100%; missing schema config; missing properties |
| 8 | `8-data_quality.sh` | `normalized_events.json` | `cleaned_events.json`, `cleaning_log.json` | Duplicate floods; unrepairable timestamp formatting; memory bounds exceeded |
| 9 | `9-enrich.sh` | `cleaned_events.json`, context directory files | `enriched_events.json` | Asset/Zone inventory files missing; unresolvable IP subnets; context data corruption |
| 10 | `10-timeline.sh` | `enriched_events.json` | `timeline_index.json` | Sorting failure; unparseable dates; disk saturation |
| 11 | `11-source_stats.sh` | Intermediary artifacts | `source_stats.json` | Missing source streams; divide-by-zero on empty inputs; invalid schema |

# Schema Summary
The pipeline enforces rigid compliance metrics defined natively in `event_schema.json`. Every transaction record processed must contain the following required structural fields:
* `timestamp` (string, ISO 8601 UTC representation: `YYYY-MM-DDTHH:MM:SSZ`)
* `hostname` (string, target computer short name or FQDN)
* `source_type` (string, data collection origin: `windows_json`, `linux_text`, `firewall`, `suricata`, `pcap`)
* `event_category` (string, type taxonomy class: `authentication`, `process`, `network`, `network_alert`, `network_flow`)
* `user` (string or null, account descriptor executing action)
* `process_name` (string or null, binary executing action)
* `process_id` (integer or null, processing subsystem identifier)
* `src_ip` (string or null, IPv4/IPv6 source identity address)
* `src_port` (integer or null, network source port mapping)
* `dst_ip` (string or null, IPv4/IPv6 destination identity address)
* `dst_port` (integer or null, network destination port mapping)
* `protocol` (string or null, network transport protocol layer lowercase label)
* `action` (string, enforcement decision, audit outcome, or log state result: `allow`, `deny`, `success`, `failure`)
* `source_origin` (string, ingest tracking absolute filesystem path context)
* `raw_message` (string, unmodified complete base entry stream payload)

# Inputs and Outputs
### Target Evidence Pack Layout
```text
evidence_pack_<name>/
├── context/
│   ├── asset_inventory.json
│   └── network_zones.json
├── linux/
│   ├── audit.log
│   ├── auth.log
│   └── syslog
├── network/
│   ├── firewall.csv
│   ├── pcap_summary.json
│   └── suricata_eve.json
└── windows/
    └── Security.json
