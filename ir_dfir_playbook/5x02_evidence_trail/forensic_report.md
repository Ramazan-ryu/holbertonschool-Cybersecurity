# Forensic Investigation Report

**Case number:** LH-2026-0414-01  
**Litigation hold reference:** Memo from Helena Reyes, 2026-04-14T07:30Z  
**Date:** 2026-04-14  
**Lead investigator:** Forensic Analyst  
**Classification:** Internal — Legal Hold  
**Distribution:** Dr. Patricia Morales (CISO), Helena Reyes (General Counsel), James Chen (SOC Lead)  

---

## Executive Summary

Between 2026-04-13 and 2026-04-14, a MedDefense employee account (`MEDDEFENSE\dmarsh`) was compromised following a credential phishing event. The user visited a fraudulent Microsoft-themed login page and submitted credentials to a typosquatted domain at `ms0365-support.login-verification.click` (TIMELINE-01, TIMELINE-02, ART-001-F04).

At 2026-04-14T02:44:17Z, the compromised credentials were used to establish a successful VPN session from external IP `45.63.9.88` (TIMELINE-03, AUTH-F01). Shortly after, the attacker executed malicious commands on workstation `WST-WS-031`, including launching `MSBuild.exe` with a staged payload located at `C:\Users\dmarsh\AppData\Local\Temp\update.xml` (ART-001-F01, ART-002-M01).

The attacker then moved laterally to `WST-WS-017` and subsequently accessed the clinical system `LIS-WSIDE-01` using Kerberos-authenticated sessions (TIMELINE-15, TIMELINE-16, AUTH-F02). At 2026-04-14T03:43:30Z, the attacker accessed 14 patient laboratory report PDF files (TIMELINE-18, AUTH-F04).

Current evidence confirms unauthorized access to PHI. External exfiltration is not confirmed, though outbound network activity suggests possible attempted data transfer (TIMELINE-19, NET-F02).

---

## Methodology

Evidence was collected and analyzed from the following artifacts:

- ART-001: `wst-ws-031.dd`
- ART-002: `wst-ws-031.mem`
- ART-003: `wst-ws-017.mem`
- `proxy_log.jsonl`
- `ad_auth_log.jsonl`
- `siem_alert_export.json`

Evidence integrity was preserved using SHA-256 hash verification via `verify_artifacts.sh`. All artifacts were handled under chain-of-custody tracking (CoC-ART-001, CoC-ART-002, CoC-ART-003) and processed in a read-only forensic environment.

Analysis tools included:
- The Sleuth Kit (mmls, fsstat, fls, icat, mactime)
- Volatility 3 (pslist, pstree, cmdline, netscan, dlllist, malfind, handles, hashdump)

---

## Technical Findings

### Disk

**ART-001-F01:** MSBuild staging payload identified at `C:\Users\dmarsh\AppData\Local\Temp\update.xml` indicating malicious execution chain (ART-001-F01, NET-F01).

**ART-001-R01:** Registry Run key persistence configured to execute malicious payload at user logon (ART-001-R01).

**ART-001-R02:** Scheduled task `MSBuild_Update` configured for persistence via MSBuild execution (ART-001-R02).

---

### Memory

**ART-002-M01:** Process execution of `MSBuild.exe` observed with command-line invocation of `update.xml` payload (ART-002-M01).

**ART-002-M04:** Memory analysis detected suspicious process behavior consistent with C2 communication patterns (ART-002-M04, ART-002-M05).

---

### Network

Outbound encrypted connections were observed from `WST-WS-031` and `WST-WS-017` to external infrastructure:

- Tor exit relay activity at `185.220.101.47:443` (NET-F01)
- C2 infrastructure at `91.234.99.107:443` (NET-F02)

These connections were associated with `MSBuild.exe` process activity (NET-F01, NET-F02).

---

### Authentication

At 2026-04-14T02:44:17Z, VPN authentication succeeded using compromised credentials from external IP `45.63.9.88` (AUTH-F01, TIMELINE-03).

Kerberos service tickets were used for lateral movement:

- Access from `WST-WS-031` to `WST-WS-017` (AUTH-F02, TIMELINE-15)
- Access from `WST-WS-017` to `LIS-WSIDE-01` (AUTH-F03, TIMELINE-16)

File access logs confirm access to 14 patient records (AUTH-F04, TIMELINE-18).

---

## Incident Timeline

- 2026-04-13T18:14:41Z — User submits credentials to phishing site `ms0365-support.login-verification.click` (ART-001-F04, TIMELINE-01)
- 2026-04-14T02:44:17Z — Successful VPN login from `45.63.9.88` (AUTH-F01, TIMELINE-03)
- 2026-04-14T03:23:01Z — Lateral movement from `WST-WS-031` to `WST-WS-017` via Kerberos (AUTH-F02, TIMELINE-15)
- 2026-04-14T03:42:08Z — Access to `LIS-WSIDE-01` established (AUTH-F03, TIMELINE-16)
- 2026-04-14T03:43:30Z — Access to 14 patient lab reports confirmed (AUTH-F04, TIMELINE-18)
- 2026-04-14T03:44:10Z — Suspicious outbound C2 activity observed (NET-F02, TIMELINE-19)

---

## Breach Scope Determination

**PHI categories accessed:**
- Patient laboratory report PDFs (TIMELINE-18)
- Patient identifiers within lab reports (AUTH-F04)
- Clinical test results and metadata (TIMELINE-18)

**Patient count:** 14 patients (TIMELINE-18)

**Certainty assessment:**
- Credential compromise: high certainty (ART-001-F04, TIMELINE-01)
- Unauthorized PHI access: high certainty (AUTH-F04, TIMELINE-18)
- Lateral movement: high certainty (AUTH-F02, AUTH-F03)
- External exfiltration: low certainty / unconfirmed (NET-F02, TIMELINE-19)

**HIPAA four-factor assessment:**
1. Nature and extent: PHI included lab reports and identifiers (TIMELINE-18)
2. Unauthorized person: external actor using compromised credentials (AUTH-F01)
3. Acquisition/viewing: confirmed access to 14 records (AUTH-F04)
4. Mitigation: systems isolated; exfiltration not confirmed (NET-F02)

Conclusion: Reportable HIPAA security incident involving confirmed unauthorized access to PHI affecting 14 patients.

---

## Gaps and Limitations

- Full packet capture data was not available, limiting confirmation of external data exfiltration (TIMELINE-19).
- Cloud email security logs were not available for phishing origin verification.
- Endpoint coverage was limited to WST-WS-031 and WST-WS-017; additional hosts were not imaged.
- Some SIEM correlation relies on timestamp reconstruction and may not reflect all attacker actions (TIMELINE-01–TIMELINE-19).
- External attacker infrastructure attribution remains partial based on proxy reputation tagging (NET-F01, NET-F02).

---

## Recommendations

1. Enforce MFA for all VPN and remote authentication services (AUTH-F01 risk mitigation).
2. Block execution of `MSBuild.exe` for non-build environments using application control policies (ART-002-M01 mitigation).
3. Deploy EDR rules for detection of encoded PowerShell spawning MSBuild processes (ART-002-M04).
4. Segment clinical systems (LIS-WSIDE-01) from general workstation network zones to reduce lateral movement (AUTH-F03).
5. Conduct phishing simulation training targeting laboratory staff accounts (ART-001-F04 root cause).

---
