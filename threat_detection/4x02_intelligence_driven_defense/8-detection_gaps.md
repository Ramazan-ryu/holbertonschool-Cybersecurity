# HEALTHBANE Detection Gap Analysis

## Overview

This assessment compares the HEALTHBANE ATT&CK mapping against MedDefense's currently documented detection capability.

Detection coverage was evaluated using:

- MedDefense 4x00 phishing investigation findings
- IOC-based detections from Tasks 0-5
- ATT&CK mapping from Task 7
- Existing packet and email-focused detections
- Local indicator database actions
- Expected YARA and analytic coverage from Tasks 9-10

Detection status definitions:

| Status | Meaning |
|---|---|
| DETECTED | Existing controls directly identify the technique |
| PARTIALLY DETECTED | Some telemetry or indicators exist, but coverage is incomplete |
| NOT DETECTED | No reliable documented detection currently exists |

---

# Technique Coverage Assessment

| ATT&CK ID | Technique | Observed / Inferred | Detection Status | Existing Evidence | Missing Telemetry | Gap Explanation | Detection Recommendation | Required Data Source | Suggested Owner |
|---|---|---|---|---|---|---|---|---|---|
| T1566.002 | Phishing: Spearphishing Link | OBSERVED | DETECTED | MedDefense identified phishing domains and malicious email activity | Limited user click telemetry | Existing detections rely heavily on known IOCs | Expand secure email gateway detections and URL analysis | Email gateway logs, proxy logs, URL sandbox telemetry | Email Security Team |
| T1583.001 | Acquire Infrastructure: Domains | OBSERVED | PARTIALLY DETECTED | Known phishing domains already blocked | Newly registered domain monitoring absent | Similar healthcare-themed domains may bypass controls | Add newly registered domain analytics and brand monitoring | Passive DNS, WHOIS monitoring, threat intel feeds | Threat Intelligence Team |
| T1583.003 | Acquire Infrastructure: VPS | OBSERVED | PARTIALLY DETECTED | Known malicious VPS IPs identified | Limited hosting-provider correlation | Shared hosting environments create false positives | Correlate ASN reputation with behavioral indicators | Firewall logs, passive DNS, ASN enrichment feeds | Network Security Team |
| T1204.001 | User Execution: Malicious Link | OBSERVED | PARTIALLY DETECTED | Phishing URLs identified in investigation | No reliable user click visibility | User interaction tracking incomplete | Add click-tracking and browser isolation analytics | Proxy logs, browser telemetry, EDR | SOC Engineering |
| T1204.002 | User Execution: Malicious File | OBSERVED | PARTIALLY DETECTED | Malware hashes documented | Office macro execution visibility incomplete | Hash-only detection may miss variants | Deploy behavioral macro and script execution detections | EDR telemetry, Office logs, AMSI | Endpoint Security Team |
| T1059.001 | PowerShell | OBSERVED | NOT DETECTED | HC3 documented PowerShell exfiltration scripts | PowerShell execution logging absent | Encoded PowerShell may execute silently | Enable PowerShell Script Block Logging and AMSI | Windows Event Logs, Sysmon, EDR telemetry | Endpoint Security Team |
| T1105 | Ingress Tool Transfer | OBSERVED | PARTIALLY DETECTED | Malware download URLs identified | Download telemetry incomplete | Suspicious executable downloads may not alert | Detect executable downloads from low-reputation domains | Proxy logs, web gateway logs, EDR | Network Detection Team |
| T1053.005 | Scheduled Task | OBSERVED | NOT DETECTED | HC3 references scheduled-task persistence | Task creation telemetry missing | Malware persistence may survive unnoticed | Enable scheduled-task monitoring and alerting | Sysmon, Windows Task Scheduler logs | Endpoint Monitoring Team |
| T1112 | Modify Registry | OBSERVED | NOT DETECTED | Registry persistence behavior referenced in reporting | Registry auditing disabled | Run-key persistence may remain invisible | Deploy Sysmon registry monitoring rules | Sysmon registry events, Windows logs | Endpoint Security Team |
| T1071.004 | DNS Protocol | OBSERVED | PARTIALLY DETECTED | HC3 identified DNS tunneling activity | Full DNS visibility incomplete | DNS TXT tunneling may evade current controls | Deploy DNS anomaly and entropy analysis | DNS logs, Zeek DNS telemetry, passive DNS | Network Detection Team |
| T1048.003 | Exfiltration Over Unencrypted Non-C2 Protocol | OBSERVED | NOT DETECTED | DNS TXT exfiltration confirmed by HC3 | No DNS payload inspection capability | Large TXT exfiltration may go undetected | Alert on abnormal TXT query frequency and payload size | DNS packet capture, Zeek, recursive resolver logs | Network Detection Team |
| T1027 | Obfuscated/Compressed Files and Information | OBSERVED | PARTIALLY DETECTED | Base32 encoded subdomains identified | Automated encoding analysis absent | Obfuscated payloads require manual review | Add encoded payload and entropy detections | DNS telemetry, SIEM analytics, Zeek | SOC Engineering |
| T1036 | Masquerading | OBSERVED | DETECTED | Outlook impersonation domains identified | Brand abuse monitoring incomplete | New impersonation domains may appear rapidly | Add brand impersonation analytics and lookalike detection | WHOIS feeds, passive DNS, email telemetry | Threat Intelligence Team |
| T1587.001 | Develop Capabilities: Malware | INFERRED | NOT DETECTED | Campaign likely uses customized malware tooling | Malware development telemetry unavailable | Custom malware evolution may not match signatures | Add sandbox detonation and memory-analysis workflows | Sandbox telemetry, malware analysis platform | Malware Research Team |
| T1588.001 | Obtain Capabilities: Malware | INFERRED | NOT DETECTED | Tooling overlap suggested by commercial feed | Malware acquisition visibility absent | Shared tooling sources remain poorly understood | Expand retro-hunting and malware clustering | Threat intel platform, malware repositories | Threat Intelligence Team |
| T1595.002 | Active Scanning: Vulnerability Scanning | INFERRED | NOT DETECTED | Pre-target reconnaissance suspected | External scan visibility limited | Reconnaissance may occur before phishing phase | Monitor external scanning and suspicious probes | IDS logs, firewall logs, NetFlow | Network Operations Team |
| T1082 | System Information Discovery | INFERRED | NOT DETECTED | Malware likely collected host information | Host telemetry collection incomplete | Discovery commands currently unmonitored | Detect suspicious enumeration commands | EDR telemetry, PowerShell logs, Sysmon | Endpoint Security Team |
| T1005 | Data from Local System | INFERRED | NOT DETECTED | Healthcare document theft suspected | File access telemetry missing | Sensitive file collection activity may remain hidden | Monitor access to sensitive healthcare directories | File auditing logs, EDR telemetry | Data Protection Team |
| T1041 | Exfiltration Over C2 Channel | INFERRED | PARTIALLY DETECTED | DNS tunneling overlaps with known indicators | Full outbound traffic visibility incomplete | Exfiltration content visibility remains limited | Add network anomaly detection and outbound traffic analysis | DNS telemetry, NetFlow, packet capture | Network Detection Team |

---

# Priority 1 – OBSERVED and NOT DETECTED

## T1059.001 – PowerShell

Why the gap matters:

- HEALTHBANE used PowerShell-based exfiltration tooling
- Scripts may bypass traditional antivirus controls

Current weakness:

- No PowerShell logging or AMSI visibility enabled

Detection idea:

- Alert on encoded PowerShell execution
- Detect suspicious child processes from Office applications

Required telemetry:

- PowerShell Script Block Logging
- AMSI telemetry
- Sysmon process creation events

Implementation path:

- Deploy Sysmon configuration
- Enable centralized PowerShell logging into SIEM

Suggested owner:

- Endpoint Security Team

---

## T1053.005 – Scheduled Task

Why the gap matters:

- Persistence may survive system reboot
- Common malware persistence technique

Current weakness:

- No scheduled-task auditing enabled

Detection idea:

- Detect scheduled task creation from Office or PowerShell parent processes

Required telemetry:

- Windows Task Scheduler logs
- Sysmon Event ID 1

Implementation path:

- Enable Task Scheduler operational logging
- Add SIEM correlation rules

Suggested owner:

- Endpoint Monitoring Team

---

## T1112 – Modify Registry

Why the gap matters:

- Registry persistence can maintain long-term access

Current weakness:

- Registry changes are not monitored

Detection idea:

- Detect modifications to Run and RunOnce keys

Required telemetry:

- Sysmon registry monitoring
- Windows registry auditing

Implementation path:

- Deploy registry monitoring configuration via Sysmon

Suggested owner:

- Endpoint Security Team

---

## T1048.003 – DNS TXT Exfiltration

Why the gap matters:

- Confirmed exfiltration method used during Stage 3

Current weakness:

- DNS payload analysis capability missing

Detection idea:

- Detect excessive TXT queries and Base32 encoded subdomains

Required telemetry:

- Full DNS query logging
- Zeek DNS analysis
- Passive DNS telemetry

Implementation path:

- Deploy DNS analytics platform and SIEM detections

Suggested owner:

- Network Detection Team

---

# Priority 2 – INFERRED and NOT DETECTED

| ATT&CK ID | Technique | Why It Matters | Detection Recommendation | Required Data Source |
|---|---|---|---|---|
| T1587.001 | Develop Capabilities: Malware | Possible custom malware development | Add malware sandboxing and memory analysis | Sandbox telemetry, malware analysis platform |
| T1588.001 | Obtain Capabilities: Malware | Tooling overlap may indicate broader actor ecosystem | Expand malware clustering and retro-hunting | Threat intel repositories |
| T1595.002 | Active Scanning | Possible pre-attack reconnaissance | Detect external scanning behavior | IDS, firewall logs, NetFlow |
| T1082 | System Information Discovery | Discovery may precede exfiltration | Monitor enumeration commands | EDR telemetry, Sysmon |
| T1005 | Data from Local System | Sensitive healthcare data likely targeted | Monitor access to protected data stores | File auditing, EDR telemetry |

---

# Priority 3 – PARTIALLY DETECTED

| ATT&CK ID | Technique | Main Weakness | Recommendation |
|---|---|---|---|
| T1583.001 | Acquire Infrastructure: Domains | Reactive IOC-only blocking | Add predictive domain monitoring |
| T1583.003 | Acquire Infrastructure: VPS | Shared hosting false positives | Combine ASN and behavioral detections |
| T1204.001 | User Execution: Malicious Link | Limited user telemetry | Add browser telemetry |
| T1204.002 | User Execution: Malicious File | Variant evasion risk | Add behavioral detections |
| T1071.004 | DNS Protocol | Incomplete DNS analytics | Deploy DNS anomaly detection |
| T1027 | Obfuscated Files | Manual review dependence | Automate entropy analysis |
| T1041 | Exfiltration Over C2 Channel | Partial outbound visibility | Expand packet capture coverage |

---

# Detection Coverage Summary

| Detection Status | Count |
|---|---|
| DETECTED | 2 |
| PARTIALLY DETECTED | 8 |
| NOT DETECTED | 9 |

---

# Most Significant Defensive Weaknesses

1. Lack of endpoint telemetry
2. Limited PowerShell visibility
3. Weak DNS analytics capability
4. Incomplete persistence monitoring
5. Heavy dependence on static IOC blocking

---

# Recommended Defensive Priorities

## Immediate Priorities

- Enable PowerShell Script Block Logging
- Deploy Sysmon across endpoints
- Expand DNS query monitoring
- Improve phishing telemetry correlation

## Medium-Term Priorities

- Deploy behavioral EDR detections
- Add automated malware sandboxing
- Improve outbound traffic visibility
- Expand ATT&CK-aligned detection engineering

## Long-Term Priorities

- Build continuous ATT&CK coverage tracking
- Automate IOC enrichment workflows
- Improve cross-stage correlation analytics

---

# Final Assessment

MedDefense currently has strong visibility into Stage 1 phishing operations through IOC-based detection and email analysis.

However, visibility into Stage 2 persistence activity and Stage 3 DNS exfiltration remains limited due to insufficient endpoint telemetry and incomplete DNS monitoring.

The highest-risk gaps involve PowerShell execution, scheduled-task persistence and DNS-based data exfiltration, all of which could allow HEALTHBANE activity to continue undetected after initial compromise.
