# MedDefense Tool-Agnostic Investigation Playbook v1

## Purpose
This playbook establishes a standard, platform-independent procedure for executing incident investigations across any SIEM environment. It ensures consistent investigation speed and analyst analysis quality regardless of underlying security tool migrations.

## Scope
* **In Scope**: Analysis of authenticated event records, raw host security audits, Sysmon metrics, firewall netflows, and host asset contexts.
* **Out of Scope**: Real-time asset quarantine, active packet captures, deep forensic disk imaging, or malware sample code reverse engineering.

## Inputs
Analysts must have verified access to these baseline artifact layers:
1. Enriched Events (`enriched_events.json`)
2. Asset Inventory (`asset_inventory.json`)
3. Known Good Baseline (`baseline_spec.md`)
4. Detection Catalog (`detection_catalog.json`)
5. Triage Package (`triage_package.json`)
6. IOC Threat Context (`ioc_context.json`)

## Workflow Steps

| # | Objective | CLI Action Path (jq) | Export / Dashboard Action Path |
|---|---|---|---|
| 1 | Event Scoping | Filter target host or source IP across the specific investigation window. | Open Discover module, apply index pattern, select time window, enter KQL query. |
| 2 | Pivot Audit | Select key pivot fields like EventID, user, process, and remote destination. | Add target tracking fields as display columns to strip interface noise. |
| 3 | Asset Contextualization | Join target host metrics against asset inventory classification records. | Cross-reference agent metadata labels or pivot to asset inventory. |
| 4 | EID Extraction | Group events by EventID or process name to identify anomalies. | Apply filter blocks for critical event IDs (e.g., 4624, 10, 11, 3). |
| 5 | Baseline Validation | Filter out known administrative service patterns via exclusions. | Suppress verified safe processes by clicking the minus filter icon. |
| 6 | Chain Correlation | Track chronological parent-child process chains and netflows. | Sort events by `@timestamp` ascending and track sequential activity. |
| 7 | Indicator Check | Compare external connection destinations against threat IOC logs. | Match external IPs against threat feed indicators via dashboard query. |
| 8 | Fact Compilation | Count matched events, extract timeline constraints, and export. | Save search results, extract JSON logs, and record click path trace. |

## Field Name Translation Table

| Normalized Schema | Wazuh Field Name | Description |
|---|---|---|
| `src_ip` | `source.ip` | Initiating source IPv4 or IPv6 network address. |
| `dst_ip` | `destination.ip` | Terminating destination network address. |
| `hostname` | `agent.name` | Unique alphanumeric string of the target asset host. |
| `user` | `user.name` | Target account name executing the event context. |
| `event_ref` | `_id` | Unique identifier generated per document log entry. |
| `raw_message` | `full_log` | Unparsed text blob payload of the security audit event. |
| `event_id` | `winlog.event_id` | Native Windows security audit or Sysmon Event identifier. |
| `proc_name` | `win.eventdata.image` | Executable process file path inside the operating system. |
| `parent_proc` | `win.eventdata.parentImage` | Executable process that spawned the child process. |
| `target_proc` | `win.eventdata.targetImage` | Target process memory space accessed by external thread. |

## Query Decomposition Rule
Every detection question must be broken down into three distinct operational blocks:
1. **Filter**: Isolates the target data space based on precise field equality criteria.
2. **Aggregation**: Groups and counts matches by a pivot key to expose clustering metrics.
3. **Time Window**: Binds the target analysis zone within strict chronological margins.

### Syntactic Realization Matrix

| Component | JQ Syntax Formulation | Sigma Rule Representation | KQL Dashboard Formulation | Lucene Legacy Search Syntax |
|---|---|---|---|---|
| **Filter** | `select(.winlog.event_id == 1)` | `selection: EventID: 1` | `winlog.event_id: 1` | `winlog.event_id:1` |
| **Aggregation**| `group_by(.user) \| map({u: .[0].user, c: length})` | `condition: selection \| count(user) > 5` | Use Visualize / Terms Aggregation on field | Run query then view field bucket counts |
| **Time Window**| `select(.timestamp >= "Start" and .timestamp <= "End")` | `timestamp\|range: gte: Start` | `@timestamp: [Start TO End]` | `@timestamp:[Start TO End]` |

## Finding Schema
```json
{
  "finding_id": "string (unique identifier)",
  "scenario_id": "string (scenario designation)",
  "interface": "string (cli / wazuh_export)",
  "target_host": "string (compromised asset name)",
  "mitre_attack_techniques": ["array of strings"],
  "metrics": {
    "matched_events": "integer (event count)",
    "earliest_timestamp": "string (ISO8601)",
    "latest_timestamp": "string (ISO8601)",
    "elapsed_seconds": "integer (benchmarked time)",
    "commands_executed_or_file_reads": "integer"
  },
  "verdict": "string (true_positive / false_positive)",
  "classification": "string (escalated / false_alarm)"
}
