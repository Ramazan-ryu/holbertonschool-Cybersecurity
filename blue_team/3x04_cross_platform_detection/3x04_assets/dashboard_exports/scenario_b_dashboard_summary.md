# Wazuh Dashboard Evidence Summary — Scenario B

> Generated: 2026-06-04T00:00:00Z  
> Source index: `meddefense-evidence-2026-03`  
> Scenario: Off-hours privileged logon on PHI workstation clin-ws-07 (T1078.002, T1059.001, T1530)

## Investigation Context

This document records the equivalent Wazuh dashboard investigation workflow for this scenario.
Use it alongside the JSON search results file to complete the dashboard-side finding.

## KQL Query Used

```
agent.name:"clin-ws-07" AND winlog.event_id:(4624 OR 4672 OR 1 OR 3)
```

**Time range:** `2026-03-25T02:17:00Z` to `2026-03-25T02:23:00Z`  
**Index:** `meddefense-evidence-2026-03`  
**Total matches:** 11

## Click Path (Equivalent Browser Workflow)

1. Navigate to Discover → index meddefense-evidence-2026-03
2. Set time range: 2026-03-25T02:00:00Z to 2026-03-25T03:00:00Z
3. Type KQL: agent.name:"clin-ws-07" AND winlog.event_id:(4624 OR 4672 OR 1)
4. Sort by @timestamp ascending
5. Expand EID 4624 — note LogonType 10 (RemoteInteractive) for p.morales
6. Expand EID 4672 — note SeBackupPrivilege, SeRestorePrivilege assigned
7. Expand EID 1 (Sysmon) — note powershell.exe -ExecutionPolicy Bypass command line

## Field Name Translation

| Normalized Schema Field | Wazuh Dashboard Field |
|-------------------------|----------------------|
| `hostname` | `agent.name` |
| `event_id` | `winlog.event_id` |
| `user` | `user.name` |
| `timestamp` | `@timestamp` |
| `src_ip` | `source.ip` |

## ATT&CK Mapping

- [T1078.002](https://attack.mitre.org/techniques/T1078/002)
- [T1059.001](https://attack.mitre.org/techniques/T1059/001)
- [T1530](https://attack.mitre.org/techniques/T1530)

## Verdict

Confidence: **high**  
Classification: **true_positive**  

## Notes for Comparison

- Record your click path in the `actions` field of your finding JSON
- Measure elapsed time from first KQL entry to finding completion
- Note which fields were immediately visible vs required expansion
- See `wazuh_exports/field_mapping.json` for the complete field translation table
