# Gap Analysis: IR-2026-0414-01

This analysis incorporates findings and gaps extracted from `control_effectiveness.yaml` and `forensic_findings_summary.md`.

## Gap Register

| Gap ID | Phase | Gap description | Control category | Recommended improvement | Priority | Linked findings |
|---|---|---|---|---|---|---|
| GAP-001 | Credential phishing and submission | Users submitted MedDefense credentials to `ms0365-support.login-verification.click` without MFA enforcement or URL filtering protection. | preventive | Enforce Microsoft Entra ID MFA for all VPN and Office 365 authentication flows and deploy Microsoft Defender for Office 365 Safe Links blocking. | P1 critical | ART-001-F01, control_eff phase 1 |
| GAP-002 | Credential phishing and submission | The phishing domain remained reachable from MedDefense workstations during the attack window. | preventive | Configure DNS filtering and web proxy blocking for newly registered domains and typosquat indicators. | P2 high | IOC domain `ms0365-support.login-verification.click` |
| GAP-003 | VPN access using stolen credentials from a foreign IP | VPN authentication from Russian IP `45.63.9.88` succeeded without geolocation restrictions or impossible-travel detection. | preventive | Configure conditional access policies to block non-approved geolocations and require MFA for all external VPN logins. | P1 critical | Open investigative items, control_eff phase 2 |
| GAP-004 | VPN access using stolen credentials from a foreign IP | Azure AD risk alerts were suppressed by an overly permissive compliant-device conditional access rule. | detective | Reconfigure Microsoft Entra ID risk-based sign-in policies and forward medium/high-risk alerts to the SOC SIEM queue. | P1 critical | Open investigative items |
| GAP-005 | PowerShell to MSBuild LOLBin execution | `powershell.exe` launched `MSBuild.exe` from user context without EDR escalation or application control enforcement. | detective | Deploy Sigma detection rules for PowerShell spawning MSBuild and alert on MSBuild execution from user directories. | P2 high | ART-002-M01, ART-001-E01 |
| GAP-006 | PowerShell to MSBuild LOLBin execution | `update.xml` executed from `C:\Users\dmarsh\AppData\Local\Temp\` using MSBuild inline tasks. | preventive | Enable Microsoft Attack Surface Reduction rules to block executable content and LOLBin execution from `%TEMP%` directories. | P2 high | ART-001-F01 |
| GAP-007 | C2 beaconing to external IPs | Outbound beaconing traffic to `185.220.101.47` and `91.234.99.107` over TCP/443 was not blocked or investigated. | detective | Integrate AbuseIPDB and AlienVault OTX IOC feeds into firewall deny lists and SIEM correlation rules. | P2 high | ART-002-M02, ART-003-M01 |
| GAP-008 | LSASS credential access and Kerberos ticket extraction | LSASS memory access and NTLM credential material extraction occurred without endpoint prevention controls. | preventive | Enable Microsoft Defender Credential Guard and LSASS protected process mode on all MedDefense Windows endpoints. | P1 critical | ART-002-M04 |
| GAP-009 | Lateral movement and PHI access | Kerberos-authenticated lateral movement from `WST-WS-031` to `WST-WS-017` succeeded without segmentation controls. | preventive | Restrict workstation-to-workstation Kerberos authentication and implement endpoint network segmentation policies. | P1 critical | ART-003-M01 |
| GAP-010 | Lateral movement and PHI access | Access to PHI PDF files on `LIS_REPORTS$` generated logs but no DLP or anomaly alerting. | detective | Enable DLP monitoring and abnormal PDF access alerting for PHI repositories on `LIS-WSIDE-01`. | P2 high | AD-LOG-01 |
| GAP-011 | Persistence establishment | Run key persistence and scheduled task persistence remained active until manual containment. | corrective | Deploy Sigma rules for suspicious Run key creation and scheduled task registration from user-writable paths. | P3 medium | ART-001-R01, ART-001-R02 |

## Priority summary

- **GAP-001** (P1): Credential harvesting enabled the entire intrusion chain and would have been stopped by enforced MFA and phishing URL protection.
- **GAP-003** (P1): Foreign-IP VPN access is the point where a single control — conditional MFA — would have stopped the entire intrusion chain.
- **GAP-004** (P1): Missing or suppressed risk alerts delayed active threat detection and isolation of compromised user sessions.
- **GAP-008** (P1): Stolen local admin hashes allowed unrestricted domain horizontal pivoting because Credential Guard was inactive.
- **GAP-009** (P1): Microsegmentation was completely absent, which allowed attackers to jump between corporate endpoints unchecked.
