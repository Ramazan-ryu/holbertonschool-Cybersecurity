## Overview
The evidence pipeline normalizes forensic telemetry into a threat-hunting repository. The entire pipeline executes end-to-end via a single orchestration command using `./evidence_pipeline.sh`, accepting an absolute directory path to an input evidence pack to build an incident timeline.

## Stage Table
| stage | script | input | output | failure_modes |
| :--- | :--- | :--- | :--- | :--- |
| 0 | `0-source_inventory.sh` | Evidence pack directory | `source_inventory.json` | Missing directory; invalid JSON generation |
| 1 | `1-telemetry_import.sh` | Evidence pack, `source_inventory.json` | `import_validation.json` | Corrupted archives; mismatching file hashes |
| 2 | `2-windows_parse.sh` | Imported EVTX JSON files | `windows_events.json` | Missing EVTX files; parsing exceptions |
| 3 | `3-linux_parse.sh` | Imported `auth.log`, `syslog`, `audit.log` | `linux_events.json` | Unknown date formats; missing raw text logs |
| 5 | `5-normalize.sh` | `windows_events.json`, `linux_events.json` | `normalized_events.json`, `quarantine.json` | Broken field maps; zero compliant records |
| 6 | `6-network_normalize.sh`| `firewall.csv`, `suricata_eve.json`, `pcap_summary.json` | `network_events.json`, appends to `normalized_events.json` | Corrupt lines; epoch conversion out of bounds |
| 7 | `7-schema_validate.sh` | `normalized_events.json`, `event_schema.json` | `validation_report.json` | Compliance drops below 100%; missing schema config |
| 8 | `8-data_quality.sh` | `normalized_events.json` | `cleaned_events.json`, `cleaning_log.json` | Duplicate floods; unrepairable timestamp formatting |
| 9 | `9-enrich.sh` | `cleaned_events.json`, context files | `enriched_events.json` | Inventory files missing; subnet mapping error |
| 10 | `10-timeline.sh` | `enriched_events.json` | `timeline_index.json` | Chronological sorting failure; disk saturation |
| 11 | `11-source_stats.sh` | Intermediary artifacts | `source_stats.json` | Missing source streams; divide-by-zero errors |

## Schema Summary
The pipeline enforces rigid compliance metrics defined natively in `event_schema.json`. Every transaction record processed must contain the following required structural fields:
* `timestamp` (string, ISO 8601 UTC representation: `YYYY-MM-DDTHH:MM:SSZ`)
* `hostname` (string, target computer short name or FQDN)
* `source_type` (string, data collection origin: `windows_json`, `linux_text`, `firewall`, `suricata`, `pcap`)
* `event_category` (string, type taxonomy class: `authentication`, `process`, `network`, `network_alert`, `network_flow`)
* `severity` (integer or null, alert priority rating from 1 to 3)
* `user` (string or null, account descriptor executing action)
* `process_name` (string or null, binary executing action)
* `src_ip` (string or null, IPv4/IPv6 source identity address)
* `dst_ip` (string or null, IPv4/IPv6 destination identity address)
* `raw_message` (string, unmodified complete base entry stream payload)

## Inputs and Outputs
Expected layout of an input evidence pack directory structure:
```text
evidence_pack_secondary/
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


Expected final handoff directory output layout:
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
