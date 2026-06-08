# MedDefense Tool-Agnostic Investigation Playbook v1

## Purpose
This playbook establishes a standard, platform-independent procedure for executing incident investigations across any SIEM environment. It ensures consistent investigation speed and analyst analysis quality regardless of underlying security tool migrations.

## Scope
* **In Scope**: Analysis of authenticated event records, raw host security audits, Sysmon metrics, firewall netflows, and host asset contexts.
* **Out of Scope**: Real-time asset quarantine, active packet captures, deep forensic disk imaging, or malware sample code reverse engineering.

## Inputs
Analysts must have verified access to these locked input artifact list parameters during triage:
* enriched events
* asset inventory
* baseline
* detection catalog
* triage package
* ioc context

## Workflow Steps
The side-by-side analytical paths define tracking workflows:

| # | Objective | CLI Action | Export/Dashboard Action |
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
Every detection question must be broken down into three distinct operational blocks: **filter**, **aggregation**, and **time window**.

### Syntactic Realization Matrix Across Modern Architectures:
* **jq**:
  * Filter: `select(.winlog.event_id == 1)`
  * Aggregation: `group_by(.user) | map({u: .[0].user, c: length})`
  * Time Window: `select(.timestamp >= "Start" and .timestamp <= "End")`
* **Sigma**:
  * Filter: `selection: EventID: 1`
  * Aggregation: `condition: selection | count(user) > 5`
  * Time Window: `timestamp|range: gte: Start`
* **KQL**:
  * Filter: `winlog.event_id: 1`
  * Aggregation: Use Visualize / Terms Aggregation on field dashboards
  * Time Window: `@timestamp: [Start TO End]`
* **Lucene**:
  * Filter: `winlog.event_id:1`
  * Aggregation: Run query then view field bucket counts manually
  * Time Window: `@timestamp:[Start TO End]`

## Finding Schema
The analytical outputs must conform to this short finding schema model definition:
```json
{
  "finding_id": "unique matching key identifier string",
  "title": "unambiguous description of threat pattern detected",
  "severity": "high / medium / low context assignment value",
  "evidence": "verifiable forensic metrics extracted from logs",
  "confidence": "high / medium / low analyst evaluation certainty",
  "scenario_id": "string scenario designation tracking indicator"
}





Exit Criteria
An investigation is considered complete and ready for a finding only when:
The exact scope of the target timeline boundaries is isolated to a minute-level margin.
The complete MITRE ATT&CK technique chain is mapped to verifiable process or network metrics.
No field parsing or timezone ambiguities remain unnoted within the final evaluation ledger.

Known Pitfalls
Pitfall 1: Command parameters vary across systems and older environments lack the --argfile option in jq, requiring alternative flags like --slurpfile for script cross-compatibility.
Pitfall 2: Standard indices often drop the asset data classification tag, forcing a manual fallback join to separate asset records.
Pitfall 3: Timezone variations between local platform dashboard views and global ISO8601 formatting cause systemic event scoping gaps.



