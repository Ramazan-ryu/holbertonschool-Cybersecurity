# Wazuh Dashboard Evidence Summary — Scenario A

> Generated: 2026-06-04T00:00:00Z  
> Source index: `meddefense-evidence-2026-03`  
> Scenario: Credential theft chain on clin-ws-12 (T1003.001, T1550.002, T1021.002)

## Investigation Context

This document records the equivalent Wazuh dashboard investigation workflow for this scenario.
Use it alongside the JSON search results file to complete the dashboard-side finding.

## KQL Query Used

```
agent.name:"clin-ws-12" AND winlog.event_id:(10 OR 1 OR 11 OR 3)
```

**Time range:** `2026-03-25T14:22:00Z` to `2026-03-25T14:28:00Z`  
**Index:** `meddefense-evidence-2026-03`  
**Total matches:** 10

## Click Path (Equivalent Browser Workflow)

1. Navigate to Discover → index meddefense-evidence-2026-03
2. Set time range: 2026-03-25T14:20:00Z to 2026-03-25T14:30:00Z
3. Type KQL: agent.name:"clin-ws-12" AND winlog.event_id:(10 OR 1 OR 11 OR 3)
4. Sort by @timestamp ascending
5. Expand EID 10 event — note process.name and parent lsass.exe
6. Pivot to EID 11 event — note file path C:\Temp\debug.dmp
7. Pivot to EID 3 event — note destination.ip 10.1.1.10 port 445 (SMB lateral move)

## Field Name Translation

| Normalized Schema Field | Wazuh Dashboard Field |
|-------------------------|----------------------|
| `hostname` | `agent.name` |
| `event_id` | `winlog.event_id` |
| `process_name` | `process.name` |
| `src_ip` | `source.ip` |
| `dst_ip` | `destination.ip` |
| `timestamp` | `@timestamp` |

## ATT&CK Mapping

- [T1003.001](https://attack.mitre.org/techniques/T1003/001)
- [T1550.002](https://attack.mitre.org/techniques/T1550/002)
- [T1021.002](https://attack.mitre.org/techniques/T1021/002)

## Verdict

Confidence: **high**  
Classification: **true_positive**  

## Notes for Comparison

- Record your click path in the `actions` field of your finding JSON
- Measure elapsed time from first KQL entry to finding completion
- Note which fields were immediately visible vs required expansion
- See `wazuh_exports/field_mapping.json` for the complete field translation table
