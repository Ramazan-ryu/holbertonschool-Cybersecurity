# THREAT HUNTING ENGAGEMENT REPORT: OPERATION HEALTHBANE STAGE 4

**Document Control:** Confidential - Executive & Technical Review  
**Target Audience:** Dr. Morales (Chief Executive Officer), Executive Board, and SOC Technical Team  
**Author:** Lead Threat Hunter  
**Status:** POSITIVE FINDING - CRITICAL ESCALATION REQUIRED  

---

## 1. Executive Summary

### 1.1 Objective & Context
Following recent security advisories regarding the HEALTHBANE threat actor group, an extensive, proactive threat hunting engagement was initiated within the MedDefense SIEM and endpoint telemetry infrastructure. The objective was to validate a critical hypothesis: Has the HEALTHBANE adversary progressed past initial intrusion stages into Stage 4 (Lateral Movement, Credential Access, and Infrastructure Staging) within the MedDefense corporate network undetected?

This report provides definitive answers to the two vital questions posed by security leadership:
* **"Did HEALTHBANE Stage 4 happen to us?"** — **YES.** Proactive hunting has uncovered irrefutable evidence of a swift, targeted lateral movement campaign utilizing compromised credentials and administrative Living-off-the-Land Binaries (LOLBins).
* **"What have we done to ensure we would detect it if it happens again?"** — The threat hunting team has performed a rigorous Detection Gap Analysis and engineered new, robust behavioral detection rules that close these visibility gaps permanently.

### 1.2 Key Findings & Impact Assessment
The hunt confirmed that an external adversary established a bridgehead on workstation `WS-RECV-03` (Module 5 bridge), extracted high-privileged credentials from memory, and systematically moved laterally deep into our internal network. 

* **Systems Reached:** The adversary progressed from initial access to internal staging infrastructure, compromising `WS-RECV-03`, `SRV-HEALTH-DB` (Primary Electronic Health Records Database), and targeting `SRV-DC-01`.
* **Data Exposed:** Database query logs indicate targeting of sensitive tables containing Protected Health Information (PHI). While data exfiltration channels remain under active investigation, data staging activity was detected on the critical `WS-RECV-03` bridge server.

### 1.3 Remediation & Posture Strategy
Prior to this engagement, MedDefense's automated detection rules covered only **55%** of observed adversary tactics, creating a dangerous vulnerability regarding administrative tool abuse. Following the deployment of hunt-derived rules, our verified MITRE ATT&CK coverage has risen to **80%**, crippling the adversary's ability to reuse these lateral movement vectors silently.

---

## 2. Hunt Methodology

The engagement abandoned traditional signature-based scanning in favor of a **Hypothesis-Driven Threat Hunting Model**. By mapping technical advisories from the HC3 Threat Briefing to our local environment, the team formulated targeted queries.

### 2.1 Telemetry & Data Sources
Queries were executed against 14 days of historical data spanning Windows Event Logs and endpoint telemetry:
* **Wazuh Security Alerts** (`wazuh_alerts_14d.json`): Audited system-wide security anomalies.
* **Sysmon Telemetry** (`wazuh_raw_sysmon_14d.json`): Analyzed for process creation, memory access, and remote service configurations.
* **Service Account Authorization Matrix** (`service_accounts.txt`): Leveraged to distinguish legitimate service calls from interactive credential misuse.

### 2.2 Control Vector: Baseline Establishment
To prevent false-positive inflation, the team built an administrative profile using the logged history of senior network administrator **Robert Kim** (`robert_kim_activity.json`). This baseline established standard working hours, source IPs, and normal administrative behaviors to effectively isolate anomalous, time-shifted credential abuse.

---

## 3. Findings per Hypothesis

### H1: Compromised Credentials Used for Initial Lateral Movement
* **Status:** Confirmed
* **Evidence Summary:** Windows Event ID 4624 logs revealed Type 3 and Type 10 logons using Robert Kim's credentials originating from unexpected internal segments during non-business hours. Adversaries focused heavily on stealing credentials via **LSASS** memory dumping.
* **Confidence Assessment:** High

### H2: WMI and PowerShell Used for Internal Reconnaissance
* **Status:** Confirmed
* **Evidence Summary:** Sysmon Event ID 1 captured heavily obfuscated PowerShell scripts executing network discovery commands disguised as routine IT health checks via **WMI** (`wmic.exe`) queries.
* **Confidence Assessment:** High

### H3: Lateral Movement to Database Staging Environments
* **Status:** Confirmed
* **Evidence Summary:** Network flow logs showed a direct connection from a compromised workstation to `WS-RECV-03` (Module 5 bridge) to pivot toward the data center using **PowerShell Remoting** and **WinRM**.
* **Confidence Assessment:** High

### H4: Target Database Probing and Enumeration
* **Status:** Confirmed
* **Evidence Summary:** Database transaction logs on `SRV-HEALTH-DB` recorded unauthorized schema enumeration queries checking patient record counts using a compromised **Service Account**.
* **Confidence Assessment:** High

### H5: Active Data Exfiltration over Encrypted Channels
* **Status:** Suspected / Under Investigation
* **Evidence Summary:** Large outbound TLS connections to an external malicious IP address were flagged from the staging environment; exact payloads remain obscured. Unauthorized **PsExec** activity was observed here during system compilation.
* **Confidence Assessment:** Medium

---

## 4. Reconstructed Attack Timeline

The following chronology maps the adversary's progression through our network during the HEALTHBANE Stage 4 campaign:

| Timestamp | Source Host | Destination Host | Event Description | MITRE Technique |
| :--- | :--- | :--- | :--- | :--- |
| **02:14:10** | External / Pivot | `WS-MGMT-01` | Unauthorized RDP logon using Robert Kim's compromised credentials. | T1078 (Valid Accounts) |
| **02:22:15** | `WS-MGMT-01` | Network-wide | Automated network discovery scans executed via obfuscated PowerShell blocks. | T1059.001 (PowerShell) |
| **02:30:05** | `WS-MGMT-01` | `WS-MGMT-01` | **LSASS** memory injection attempt to harvest high-privileged tokens. | T1003.001 (LSASS Dumping) |
| **02:45:30** | `WS-MGMT-01` | `WS-RECV-03` | Lateral movement via **WinRM**; tool deployment on the Module 5 bridge. | T1021.006 (WinRM) |
| **03:01:12** | `WS-RECV-03` | `SRV-DC-01` | Remote execution attempt targeting Active Directory via administrative **WMI**. | T1047 (WMI Execution) |
| **03:12:00** | `WS-RECV-03` | `SRV-HEALTH-DB` | Network connection established using a hijacked internal **Service Account**. | T1046 (Network Scanning) |
| **03:15:22** | `WS-RECV-03` | `SRV-HEALTH-DB` | Execution of internal remote utilities matching **PsExec** process behaviors. | T1570 (Lateral Tool Transfer) |
| **03:18:45** | `SRV-HEALTH-DB` | `SRV-HEALTH-DB` | Direct SQL enumeration queries executed targeting sensitive health records. | T1505 (Data from Local System) |
| **03:55:00** | `WS-RECV-03` | External IP | High-volume outbound HTTPS connection detected (Potential Exfiltration). | T1041 (Exfiltration Over C2) |

---

## 5. ATT&CK Update

### Coverage Improvement Visualization
Through this hunt, our visibility and detection engineering posture have been fundamentally transformed:

### New Techniques Discovered
Our legacy monitoring entirely missed several advanced matrix mechanisms. The newly discovered and **Mapped Techniques** include:
* **T1021.006 (Remote Services: Windows Remote Management):** Exploited to bypass standard RDP monitoring.
* **T1059.001 (Command and Scripting Interpreter: PowerShell):** Script block logging was unmonitored, allowing obfuscated memory-only scripts to run unnoticed.
* **T1078.002 (Valid Accounts: Domain Accounts):** Misuse of administrator profiles during anomalous hours without triggering standard threshold alerts.
* **T1003.001 (OS Credential Dumping: LSA Secrets):** Targeted extraction from active processes.
* **T1047 (Windows Management Instrumentation):** Abused for remote network enumeration and process execution.

---

## 6. Detection Improvements

To prevent a recurrence of this attack chain and ensure real-time visibility, we designed, tested, and deployed new detection rules into production.

### Newly Deployed Rules & Detection Logic

* **Rule Name:** `Anomalous Administrative Access via WinRM/PowerShell Remoting`  
  **Rule ID:** `MD-SIG-0021`  
  **Detection Logic:** Monitors Sysmon Event ID 1 where parent process `wsmprovhost.exe` spawns interactive consoles (`cmd.exe`, `powershell.exe`) mapping to a compromised **Service Account** or unauthorized **Service Account** behaviors.  

* **Rule Name:** `Suspicious Remote Administrative Activity via WMI`  
  **Rule ID:** `MD-SIG-0022`  
  **Detection Logic:** Scans security events and **WMI** logs for inbound execution originating from unmapped engineering subnets targeting core database structures.  

* **Rule Name:** `LSASS Process Memory Access and Dumping Patterns`  
  **Rule ID:** `MD-SIG-0023`  
  **Detection Logic:** Triggers on Sysmon Event ID 10 where a non-standard process requests `PROCESS_VM_READ` access rights directly targeting **LSASS**.  

* **Rule Name:** `PsExec Service Installation and Dynamic Tool Execution`  
  **Rule ID:** `MD-SIG-0024`  
  **Detection Logic:** Flags execution of standard administrative binaries like **PsExec** matching unauthorized deployment across core internal networks.

### Metric Adjustments
* **Initial ATT&CK Coverage:** 55%
* **Current ATT&CK Coverage:** 80%
* **Detection Gaps Closed:** Automated monitoring of PowerShell Script Blocks, WinRM execution monitoring, and database administrative audit tracking.

---

## 7. Remaining Gaps and Recommendations

While our defenses are significantly stronger, an uncovered **20%** gap remains. This represents advanced evasions, zero-day vulnerabilities, and highly customized malware strains that cannot be caught with log analytics alone. To achieve full resilience, the following phased action plan must be executed immediately:

* **Immediate Actions (Next 24 Hours):** Initiate incident response procedures for `WS-RECV-03` (the Module 5 bridge server). Isolate the asset from the network and begin forensic memory collection to verify data staging scope.
* **Short-Term Recommendations (1–2 Weeks):** Complete a full **service account** rotation for all automated workflows. Conduct a thorough **privileged access** review to restrict network-wide interactive logons and strictly enforce the principle of least privilege.
* **Medium-Term Recommendations (1–3 Months):** Implement full, enterprise-wide **Sysmon** deployment integrated with advanced **behavioral analytics** to flag time-shifted or location-shifted credential usage automatically.

---

## 8. Lessons Learned

1. **The Danger of "Paper Compliance":** Our legacy **55%** ATT&CK coverage created a dangerous **false sense of security**. Having coverage on paper does not equate to effective detection if specific sub-techniques are left unmonitored.
2. **The Illusion of Legitimate Tools:** Against a sophisticated **LOLBin** (Living-off-the-Land Binary) attack, traditional reactive alerts fail completely. Because the adversary used built-in utilities and legitimate credentials, they blended seamlessly into standard infrastructure operations. 
3. **Proactive Threat Hunting is Mandatory:** Proactive threat hunting must be a **recurring operational discipline**. If we had not executed this hypothesis-driven hunt based on the external threat intelligence advisory, the adversary would still maintain persistent, undetected access to our core database environment today.
