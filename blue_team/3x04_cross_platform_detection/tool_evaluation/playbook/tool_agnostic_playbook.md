# MedDefense Tool-Agnostic Investigation Playbook v1

## Purpose
This playbook establishes a standard, platform-independent procedure for executing incident investigations across any SIEM environment. It ensures consistent investigation speed and analyst analysis quality regardless of underlying security tool migrations.

## Scope
In Scope: Analysis of authenticated event records, raw host security audits, Sysmon metrics, firewall netflows, and host asset contexts.
Out of Scope: Real-time asset quarantine, active packet captures, deep forensic disk imaging, or malware sample code reverse engineering.

## Inputs
Analysts must have verified access to these locked input artifact list parameters during triage:
enriched events
asset inventory
baseline
detection catalog
triage package
ioc context

## Workflow Steps
The side-by-side analytical paths define tracking workflows across engines:
| # | Objective | CLI action | export/dashboard action |
|---|---|---|---|
| 1 | Event Scoping | Filter target host or source IP across the specific investigation window using grep or jq. | Open Discover module, apply index pattern, select time window, enter KQL query string. |
| 2 | Pivot Audit | Select key pivot fields like EventID, user, process, and remote destination via jq filters. | Add target tracking fields as display columns to strip interface noise. |
| 3 | Asset Contextualization | Join target host metrics against asset inventory classification records. | Cross-reference agent metadata labels or pivot to asset inventory interface dashboards. |
| 4 | EID Extraction | Group events by EventID or process name to isolate operational anomalies. | Apply filter blocks for critical event IDs (e.g., 4624, 10, 11, 3). |
| 5 | Baseline Validation | Filter out known administrative service patterns via exclusions. | Suppress verified safe processes by clicking the minus filter icon inside the UI. |
| 6 | Chain Correlation | Track chronological parent-child process chains and netflows. | Sort events by timestamp ascending and track sequential activity. |
| 7 | Indicator Check | Compare external connection destinations against threat IOC logs. | Match external IPs against threat feed indicators via dashboard query fields. |
| 8 | Fact Compilation | Count matched events, extract timeline constraints, and export logs. | Save search results, extract JSON logs, and record click path trace patterns. |

## Field Name Translation Table
This table maps common normalized fields to Wazuh field names to maintain schema alignment:
| Normalized Field Name | Wazuh Field Name | Description |
|---|---|---|
| `timestamp` | `@timestamp` | Chronological event record marking. |
| `hostname` | `agent.name` | Unique alphanumeric string of the target asset host. |
| `src_ip` | `source.ip` | Initiating source IPv4 or IPv6 network address. |
| `dst_ip` | `destination.ip` | Terminating destination network address. |
| `user` | `user.name` | Target account name executing the event context. |
| `process` | `win.eventdata.image` | Executable process file path inside the operating system. |
| `command_line` | `win.eventdata.commandLine` | Exact text string parameters evaluated on execution. |
| `event_id` | `winlog.event_id` | Native Windows security audit or Sysmon Event identifier. |
| `rule_id` | `rule.id` | Identification signature of the triggered metric signature. |
| `severity` | `rule.level` | Numeric tracking priority indicating context threat importance. |

## Query Decomposition Rule
Every detection question must be broken down into three distinct operational blocks: filter, aggregation, and time window.
Syntactic Realization Matrix Across Modern Architectures:

jq:
Filter: `select(.winlog.event_id == 1)`
Aggregation: `group_by(.user) | map({u: .[0].user, c: length})`
Time Window: `select(.timestamp >= "Start" and .timestamp <= "End")`

Sigma:
Filter: `selection: winlog.event_id: 1`
Aggregation: `unsupported in native language syntax core`
Time Window: `timeframe: 24h`

KQL:
Filter: `where winlog.event_id == 1`
Aggregation: `| summarize count() by user`
Time Window: `| where @timestamp between(datetime("Start") .. datetime("End"))`

Lucene:
Filter: `winlog.event_id:1`
Aggregation: `unsupported via text query strings context`
Time Window: `AND @timestamp:[2026-03-18T00:00:00Z TO 2026-03-24T23:59:59Z]`

## Finding Schema
Every completed investigation must yield a structured finding output matching these short-form key definitions:
* finding_id: Globally unique tracking string identifier.
* rule_id: Reference matching the source rule deployment manifest.
* target_entity: Impacted system hostname or asset tag identity.
* evidence_count: Integer volume of matching malicious events found.
* disposition: Analytical conclusion status string value.
* mitigation_status: Immediate containment action execution state.

## Exit Criteria
An investigation is formally complete and ready for finding schema generation only when the following goals are met:
* The original alert triggering log record is isolated and its field parameters verified.
* True volume counts are calculated across the entire specified time window duration.
* Historical baselines are cross-referenced to prove the activity is atypical.
* Final disposition state is marked as either a verified True Positive or False Positive.

## Known Pitfalls
* Log truncation during parsing causes critical fields to return empty bracket objects.
* Mismatched time zone offsets shift analytical lookups outside active alert windows entirely.
* High volume automated system service accounts generate false positive spikes mimicking brute force chains.
