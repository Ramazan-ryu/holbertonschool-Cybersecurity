# Wazuh Dashboard Evidence Summary — Scenario C

> Generated: 2026-06-04T00:00:00Z  
> Source index: `meddefense-evidence-2026-03`  
> Scenario: Medical IoT segment egress from med-mri-02 to external C2 (T1071.001, T1041)

## Investigation Context

This document records the equivalent Wazuh dashboard investigation workflow for this scenario.
Use it alongside the JSON search results file to complete the dashboard-side finding.

## KQL Query Used

```
source.ip:"10.2.3.2" AND destination.ip:"198.51.100.73"
```

**Time range:** `2026-03-25T11:44:00Z` to `2026-03-25T12:32:00Z`  
**Index:** `meddefense-evidence-2026-03`  
**Total matches:** 6

## Click Path (Equivalent Browser Workflow)

1. Navigate to Discover → index meddefense-evidence-2026-03
2. Set time range: 2026-03-25T11:00:00Z to 2026-03-25T13:00:00Z
3. Type KQL: source.ip:"10.2.3.2" AND destination.ip:"198.51.100.73"
4. Sort by @timestamp ascending
5. Note 5 matching flows — consistent 12-minute beacon interval
6. Check source.zone field — MEDICAL_IOT (should have no direct internet access)
7. Note bytes_out increasing per flow: 8KB, 14KB, 28KB, 42KB, 48KB — data staging pattern

## Field Name Translation

| Normalized Schema Field | Wazuh Dashboard Field |
|-------------------------|----------------------|
| `src_ip` | `source.ip` |
| `dst_ip` | `destination.ip` |
| `hostname` | `agent.name` |
| `protocol` | `network.transport` |
| `timestamp` | `@timestamp` |
| `action` | `network.direction` |

## ATT&CK Mapping

- [T1071.001](https://attack.mitre.org/techniques/T1071/001)
- [T1041](https://attack.mitre.org/techniques/T1041)

## Verdict

Confidence: **high**  
Classification: **true_positive**  

## Notes for Comparison

- Record your click path in the `actions` field of your finding JSON
- Measure elapsed time from first KQL entry to finding completion
- Note which fields were immediately visible vs required expansion
- See `wazuh_exports/field_mapping.json` for the complete field translation table
