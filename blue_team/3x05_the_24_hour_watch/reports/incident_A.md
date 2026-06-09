## Executive Summary
Initial entry achieved via credential brute-forcing targeting the backup_svc account. Upon successful authorization, the threat actor engaged in host compromise by dropping a persistent listener service. Command and Control beaconing back to a confirmed indicator of compromise was established. Host infrastructure validation reveals targeted data exfiltration attempts.

## Timeline
2026-06-09T23:30:00Z | wkst-hr-user12 | An account failed to log on - Username: backup_svc
2026-06-09T23:35:00Z | wkst-hr-user12 | An account failed to log on - Username: backup_svc
2026-06-09T23:45:00Z | wkst-hr-user12 | Logon successful - Interactive session for backup_svc
2026-06-09T23:47:00Z | wkst-hr-user12 | new_service installed - Execution of hidden persistence
2026-06-09T23:50:00Z | wkst-hr-user12 | C2 beacon pattern detected to untrusted external asset
2026-06-09T23:55:00Z | wkst-hr-user12 | outbound 443 match IOC - Remote admin backdoor established

## Affected Assets
| HOST | CRITICALITY | DATA_CLASS | ZONE |
| --- | --- | --- | --- |
| wkst-hr-user12 | MEDIUM | HR_DATA | INTERNAL |

## Indicators of Compromise
| TYPE | VALUE | CONFIDENCE | SOURCE |
| --- | --- | --- | --- |
| ip | 198[.]51[.]100[.]73 | high | ioc_feed.json |
| service_name | MedSyncHelper | high | ioc_feed.json |

## ATT&CK Mapping
| TECHNIQUE | NAME | EVIDENCE |
| --- | --- | --- |
| T1110.003 | Brute Force: Password Spraying | Logons failures followed by immediate success |
| T1543.003 | Create or Modify System Process: Windows Service | Installation of MedSyncHelper persistence |
| T1071.001 | Application Layer Protocol: Web Protocols | TLS/HTTPS beaconing to command server |

## Detection Performance
001_ssh_brute_force - FIRED (Produced 2 alerts on wkst-hr-user12)
002_offhours_priv - FIRED (Produced 1 alert on wkst-hr-user12)

## Recommended Actions
1. Isolate wkst-hr-user12 immediately from the internal network segment.
2. Revoke and rotate authorization credentials for the backup_svc profile.

## Evidence References
evt-win-auth-10924
evt-win-auth-10925
evt-win-auth-10930
evt-lin-proc-40112
evt-sur-alert-8911
evt-fw-flow-55219
