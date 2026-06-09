## Incident Identifier
INC-20260609-C

## Executive Summary
Lateral movement event detected originating from an internal network zone targeting high-value infrastructure. Administrative SMB communication tracks deployment of unauthorized persistent scheduling profiles. Immediate technical containment protocols executed successfully by security teams. Asset discovery logs confirm minimal post-compromise activity footprints.

## Timeline
2026-06-09T03:14:00Z | srv-prod-app01 | Incoming high-privilege remote share connection via SMB
2026-06-09T03:15:00Z | srv-prod-app01 | Remote interactive session allocated to administrative account
2026-06-09T03:17:00Z | srv-prod-app01 | Automated scheduler execution profile updated in registry
2026-06-09T03:20:00Z | srv-prod-app01 | Outbound network beacon verification attempt observed

## Affected Assets
| HOST | CRITICALITY | DATA_CLASS | ZONE |
| --- | --- | --- | --- |
| srv-prod-app01 | HIGH | PRODUCTION | INTERNAL |

## Indicators of Compromise
| TYPE | VALUE | CONFIDENCE | SOURCE |
| --- | --- | --- | --- |

## ATT&CK Mapping
| TECHNIQUE | NAME | EVIDENCE |
| --- | --- | --- |
| T1021.002 | Remote Services: SMB/Windows Admin Shares | Lateral movement connection trace from inside |
| T1053.005 | Scheduled Task/Job: Scheduled Task | Cron / Task Scheduler adjustments discovered |

## Detection Performance
001_ssh_brute_force - FIRED (Produced 2 alerts on srv-prod-app01)

## Recommended Actions
1. Revoke remote task allocation permissions from standard user directories.

## Evidence References
wazuh-evt-smb-991A
wazuh-evt-smb-991B
wazuh-evt-sch-114D
