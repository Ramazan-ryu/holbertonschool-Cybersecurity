# Correlated Incident Timeline: LH-2026-0414-01

| timestamp | source | event | att_ck_technique | certainty | evidence_ref |
|---|---|---|---|---|---|
| 2026-04-13T18:14:00Z | proxy_log.jsonl | Credential phishing link clicked by dmarsh to typosquat domain portal | T1566.002 | confirmed | ART-001 / filesystem_analysis.md / finding ART-001-F05 |
| 2026-04-13T18:14:05Z | proxy_log.jsonl | Credentials submitted to typosquat phishing domain | T1566.002 | confirmed | ART-001 / filesystem_analysis.md / finding ART-001-F04 |
| 2026-04-14T02:45:30Z | ad_auth_log.jsonl | Attacker VPN access using dmarsh credentials from external IP address | T1078 | confirmed | ART-002 / memory_analysis.md / finding ART-002-M03 |
| 2026-04-14T02:46:40Z | ad_auth_log.jsonl | powershell.exe execution with encoded payload loader context | T1059.001 | confirmed | ART-002 / memory_analysis.md / finding ART-002-M03 |
| 2026-04-14T02:46:57Z | ART-002 / memory_analysis.md | msbuild.exe spawned by PowerShell execution chain context | T1127.001 | confirmed | ART-002 / memory_analysis.md / finding ART-002-M01 |
| 2026-04-14T02:47:10Z | ART-001 / filesystem_analysis.md | Malicious files dropped to AppData\Local\Temp staging paths | T1105 | confirmed | ART-001 / filesystem_analysis.md / finding ART-001-F01 |
| 2026-04-14T02:47:20Z | ART-001 / filesystem_analysis.md | Malicious payload dropped into C:\Users\dmarsh\AppData\Local\Temp directory | T1204.002 | confirmed | ART-001 / filesystem_analysis.md / finding ART-001-F02 |
| 2026-04-14T02:48:00Z | ART-001 / persistence_analysis.md | Scheduled task persistence configuration framework installed on disk | T1053.005 | confirmed | ART-001 / persistence_analysis.md / finding ART-001-R02 |
| 2026-04-14T02:48:30Z | ART-001 / persistence_analysis.md | Run key persistence added for automated payload execution | T1547.001 | confirmed | ART-001 / persistence_analysis.md / finding ART-001-R01 |
| 2026-04-14T02:49:00Z | ART-002 / memory_analysis.md | NTLM hash and Kerberos ticket material accessible in lsass.exe process | T1003.001 | probable | ART-002 / memory_analysis.md / finding ART-002-M07 |
| 2026-04-14T02:50:10Z | ART-002 / memory_analysis.md | NTLM hashes extracted using windows.hashdump.Hashdump profile | T1003.002 | confirmed | ART-002 / memory_analysis.md / finding ART-002-M08 |
| 2026-04-14T03:20:00Z | ad_auth_log.jsonl | Kerberos TGS request for cifs/WST-WS-017 network storage resource | T1558.003 | probable | ART-003 / memory_analysis.md / finding ART-003-M01 |
| 2026-04-14T03:25:10Z | ad_auth_log.jsonl | Lateral movement logon to WST-WS-017 completed successfully | T1021.002 | confirmed | ART-003 / memory_analysis.md / finding ART-003-M01 |
| 2026-04-14T03:30:00Z | ART-003 / memory_analysis.md | Second C2 beacon established from WST-WS-017 active process memory | T1071.001 | confirmed | ART-003 / memory_analysis.md / finding ART-003-M02 |
| 2026-04-14T04:00:00Z | ad_auth_log.jsonl | Kerberos TGS request for cifs/LIS-WSIDE-01 enterprise host target | T1558.003 | probable | siem_alert_export.json / finding SIEM-AD-88 |
| 2026-04-14T04:10:00Z | ad_auth_log.jsonl | Logon to LIS-WSIDE-01 using compromised user credentials | T1021.002 | confirmed | siem_alert_export.json / finding SIEM-AD-92 |
| 2026-04-14T04:15:00Z | siem_alert_export.json | 14 patient lab report PDFs read on LIS-WSIDE-01 server endpoints | T1083 | confirmed | siem_alert_export.json / finding SIEM-104 |
| 2026-04-14T04:20:00Z | siem_alert_export.json | Possible staging of patient report collection prior to data theft | T1020 | possible | siem_alert_export.json / finding SIEM-110 |

---

## Correlated Attack Narrative
The incident sequence began with a target credential phishing campaign aimed directly at dmarsh. Core proxy log telemetry data from proxy_log.jsonl and filesystem traces validated that a malicious link was clicked, leading to user input surrender on a typosquatted portal. Shortly afterwards, ad_auth_log.jsonl records highlighted an external VPN session mapping using the compromised credentials. 

Volatility verification within memory_analysis.md validated that an interactive powershell.exe script called an inline msbuild.exe deployment chain executing a staged compilation update.xml payload file inside AppData\Local\Temp. Persistent retention hooks were immediately generated within the environment via Scheduled task engines and startup profile Run key settings. 

The compromise escalated as tracking metrics highlighted raw credential dumping access hooks inside lsass.exe process structures. The threat actor then performed lateral movement via a Kerberos TGS request for cifs/WST-WS-017, leading to a direct network lateral movement logon to WST-WS-017 where a second C2 beacon routine initialized. Finally, network pivot loops targeted file shares via a Kerberos TGS request for cifs/LIS-WSIDE-01, leading to a direct logon to LIS-WSIDE-01 where 14 patient lab report PDFs were systematically targeted and read.
