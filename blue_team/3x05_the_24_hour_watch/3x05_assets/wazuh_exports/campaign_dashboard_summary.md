# Wazuh Campaign Dashboard Summary — HC-RED7 (Capstone)

**Generated:** 2026-06-04
**Index:** meddefense-evidence-2026-03
**Cluster:** HC-RED7

## Campaign Overview (Wazuh View)

This summary represents what an analyst would see in the Wazuh security events
dashboard when correlating the three capstone incidents under a campaign lens.

## Incident-IOC Matrix

| Incident | IOC IP Hit | IOC Domain Hit | IOC Service Hit | Feed Match |
|----------|------------|----------------|-----------------|-----------|
| A (rad-srv-02) | 198.51.100.73 ✓ | update.medinfo-portal.net | — | HC-RED7 ✓ |
| B (bill-ws-09) | 203.0.113.44 ✓ | — | — | HC-RED7 ✓ |
| C (db-patient-01) | — | — | MedSyncHelper | HC-RED7 ✓ |

## Tactical Overlap (ATT&CK)

| Pair | Shared Techniques |
|------|------------------|
| A-B | T1071.001 (C2) |
| A-C | T1071.001, T1543.003 |
| B-C | — |

## Verdict

Based on IOC feed matches and tactical overlap:
- **campaign_linked:** true
- **cluster_id:** HC-RED7
- **confidence:** high

See `exported_dashboard_workflow.json` for the equivalent dashboard pivot path.
