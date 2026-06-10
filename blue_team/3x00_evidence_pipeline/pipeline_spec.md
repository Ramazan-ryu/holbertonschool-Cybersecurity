## Overview
The digital forensics evidence pipeline ingests, normalizes, validates, and enriches disparate telemetry from a compromised system into a unified indexed repositority. The entire process executes end-to-end via a single orchestration bash script `./evidence_pipeline.sh`, converting unprivileged directory data packs into chronological security timelines.

## Stage Table
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

## Schema Summary
The pipeline enforces rigid structural data compliance metrics defined natively in `event_schema.json`. Every normalized event record must explicitly contain the following fields:
- `timestamp`: Normalized ISO 8601 UTC format string (`YYYY-MM-DDTHH:MM:SSZ`)
- `hostname`: Target computer context short name or FQDN string
- `source_type`: Data collection origin category taxonomy code (`windows_json`, `linux_text`, `firewall`, `suricata`, `pcap`)
- `event_category`: Event class taxonomy designation (`authentication`, `process`, `network`, `network_alert`, `network_flow`)
- `severity`: Numeric or string alert impact prioritization level metric
- `user`: Account descriptor string executing the specific activity
- `process_name`: Executable binary name string responsible for running the record block
- `src_ip`: Contextual network packet source identity IPv4/IPv6 address string
- `dst_ip`: Contextual network packet destination identity IPv4/IPv6 address string
- `raw_message`: Pristine unmodified complete event string payload data block for log triage fallback

## Inputs and Outputs
Expected source layout structure for the input evidence pack directory path:
```text
evidence_pack_primary/
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


Expected output file layout schema inside the final handoff processing workspace folder:

blue_team/3x00_evidence_pipeline/
├── cleaned_events.json
├── cleaning_log.json
├── enriched_events.json
├── import_validation.json
├── network_events.json
├── normalized_events.json
├── pipeline_run.log
├── pipeline_test_report.json
├── quarantine.json
├── source_inventory.json
├── source_stats.json
├── timeline_index.json
└── validation_report.json
