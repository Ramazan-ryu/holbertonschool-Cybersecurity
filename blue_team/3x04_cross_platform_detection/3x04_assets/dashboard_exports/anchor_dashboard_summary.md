# Wazuh Dashboard Evidence Summary — Anchor

> Generated: 2026-06-04T00:00:00Z  
> Source index: `meddefense-evidence-2026-03`  
> Scenario: SSH brute force cluster against db-patient-01

## Investigation Context

This document records the equivalent Wazuh dashboard investigation workflow for this scenario.
Use it alongside the JSON search results file to complete the dashboard-side finding.

## KQL Query Used

```
source.ip:("203.0.113.41" OR "203.0.113.42" OR "203.0.113.43" OR "203.0.113.44") AND destination.ip:"10.1.2.10"
```

**Time range:** `2026-03-25T01:15:00Z` to `2026-03-25T01:47:00Z`  
**Index:** `meddefense-evidence-2026-03`  
**Total matches:** 47

## Click Path (Equivalent Browser Workflow)

1. Navigate to Discover → index meddefense-evidence-2026-03
2. Set time range: 2026-03-25T01:00:00Z to 2026-03-25T02:00:00Z
3. Type KQL: source.ip:("203.0.113.41" OR "203.0.113.42" OR "203.0.113.43" OR "203.0.113.44") AND destination.ip:"10.1.2.10"
4. Sort by @timestamp ascending
5. Expand first matching row → inspect source.ip, destination.ip, full_log
6. Note 48 matching events — consistent SSH brute force pattern
7. Final event at 01:47 shows successful auth for user root

## Field Name Translation

| Normalized Schema Field | Wazuh Dashboard Field |
|-------------------------|----------------------|
| `src_ip` | `source.ip` |
| `dst_ip` | `destination.ip` |
| `hostname` | `agent.name` |
| `user` | `user.name` |
| `timestamp` | `@timestamp` |

## ATT&CK Mapping

- [T1110.003](https://attack.mitre.org/techniques/T1110/003)

## Verdict

Confidence: **high**  
Classification: **true_positive**  

## Notes for Comparison

- Record your click path in the `actions` field of your finding JSON
- Measure elapsed time from first KQL entry to finding completion
- Note which fields were immediately visible vs required expansion
- See `wazuh_exports/field_mapping.json` for the complete field translation table
