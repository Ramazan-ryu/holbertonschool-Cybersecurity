## Executive Summary
True Positive security event detected masquerading as legitimate system maintenance activity. Mismatch identified on change ticket CHG-2026-0341 where the owner was found to be on annual leave. Outbound persistence traffic established to a known infrastructure indicator. Targeted host data classification verification confirms access to sensitive infrastructure components.

## Timeline
2026-06-09T04:10:00Z | rad-srv-02 | Administrative logon session initialized by rad_admin_miller
2026-06-09T04:15:00Z | rad-srv-02 | Storage volume expansion commands executed in high-privilege shell
2026-06-09T04:20:00Z | rad-srv-02 | Outbound secure socket communication initialized to external target

## Affected Assets
| HOST | CRITICALITY | DATA_CLASS | ZONE |
| --- | --- | --- | --- |
| rad-srv-02 | HIGH | RADIOLOGY | DMZ |

## Indicators of Compromise
| TYPE | VALUE | CONFIDENCE | SOURCE |
| --- | --- | --- | --- |
| ip | 198[.]51[.]100[.]73 | high | ioc_feed.json |

## ATT&CK Mapping
| TECHNIQUE | NAME | EVIDENCE |
| --- | --- | --- |
| T1078.002 | Valid Accounts: Domain Accounts | Compromised identity rad_admin_miller usage |
| T1071.001 | Application Layer Protocol: Web Protocols | Extraneous network flows during maintenance |

## Detection Performance
003_malicious_cmd - FIRED (Produced 1 alert on rad-srv-02)

## Recommended Actions
1. Terminate all active sessions owned by rad_admin_miller.
2. Apply firewall blocks to external vector destination 198[.]51[.]100[.]73.

## Evidence References
evt-rad-auth-2201
evt-rad-net-8819
evt-rad-net-8820
