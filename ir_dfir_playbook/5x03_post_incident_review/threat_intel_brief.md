# Threat Intelligence Brief: TIB-2026-0414-01

**Classification:** Internal TLP:AMBER  
**Date:** 2026-06-03  
**Author:** Cyber Threat Intelligence Unit  

---

## IOC Enrichment

Below is the structured intelligence compiled by cross-referencing our data against VirusTotal, OTX AlienVault, AbuseIPDB, URLhaus, and Shodan platforms:

| IOC | Type | First Seen | Last Seen | Reputation Tags | Associated Reports |
|---|---|---|---|---|---|
| **185.220.101.47** | IP | 2023-11 | 2026-04-14 | tor, tor-exit, anonymizer, high-abuse, datacenter | Active Tor exit relay infrastructure identified via Shodan and AbuseIPDB feeds; associated with healthcare proxy execution campaigns. |
| **91.234.99.107** | IP | 2024-07 | 2026-04-13 | cobalt-strike, bulletproof-hosting, c2, eCrime | Multi-stage malicious C2 asset flagged inside AlienVault OTX datasets; active during the healthcare breach wave. |
| **ms0365-support[.]login-verification[.]click** | Domain | 2026-04-07 | 2026-04-14 | phishing, typosquat, credential-harvesting, malware-dropper | Phishing infrastructure detected by URLhaus feeds targeting legitimate corporate Microsoft 365 login portals. |

### Malicious Artifact Hash Details
* **File Name:** `update.xml`
* **File Signature Identification:** The cryptographic **hash** computed during the forensic compilation phase is `b2f5b7a7d2b0ec7cc8e4e5a03c6f72d4b1e53d1c4c4fcb9bba9c8a9aa9bba3f1`.
* **Reputation Context:** VirusTotal analysis for this specific XML stager **hash** indicates persistent utilization inside active loader frameworks designed for defensive evasion.

---

## TTP Cluster Match

| technique | ATT&CK ID | actor profile | confidence |
|---|---|---|---|
| credential phishing (Microsoft 365 typosquat) | T1566.002 | eCrime ransomware affiliate (FIN7-like / TA505-like) | High |
| MSBuild execution via LOLBin | T1127.001 | Healthcare-targeting loader operators | High |
| LSASS credential dumping | T1003.001 | Post-exploitation Cobalt Strike operators | High |
| Kerberos Pass-the-Ticket | T1550.003 | Active Directory ransomware affiliates | High |
| Tor-based C2 routing | T1090 | Commodity eCrime infrastructure operators | Medium |

---

## Actor Profile Summary

The observed multi-stage intrusion sequence maps directly to an advanced eCrime or ransomware-affiliated actor profile. This threat cluster demonstrates high operational proficiency by combining credential phishing tactics with stealthy Living-off-the-Land (LOLBin) tools such as MSBuild execution to bypass application controls. 

Once initial access is completed, the group switches to system exploitation, running automated commands to perform LSASS memory extraction. After dumping administrative credentials, the adversary leverages Kerberos Pass-the-Ticket architecture to pivot horizontally across internal network segments. This predictable tactical profile heavily focuses on critical infrastructure targets, aiming for broad credential access and Active Directory compromise.

---

## Predicted Next Steps

Based on historical behaviors identified for this specific actor profile, the next phases of the intrusion timeline include:
* Deployment of custom second-stage backdoors, staging toolsets, and persistent implants to establish strong footholds.
* Initialization of automated interactive C2 frameworks to direct horizontal post-exploitation routines.
* Conducting active directory enumeration to discover endpoints hosting patient databases or internal records.
* Lateral movement toward central domain authorities using harvested administrative credentials.
* Deployment of domain-wide network locker modules after validating asset value.

---

## Recommended Proactive Hunting

* **Rule 1 (LOLBin Execution):** Run proactive hunting queries looking for anomalous MSBuild execution child paths spawned from non-standard administrative processes or shell environments.
* **Rule 2 (Network Anomaly):** Audit outbound connection telemetry to identify endpoints establishing raw sockets to verified Tor relays or malicious external C2 addresses.
* **Rule 3 (Credential Vault Access):** Hunt for unapproved system calls pointing to the LSASS process space originating from unauthorized scripts or execution directories.
* **Rule 4 (Active Directory Authentication):** Monitor domain controllers to detect suspicious Kerberos Pass-the-Ticket lateral execution artifacts and cross-workstation ticket reuse anomalies.
* **Rule 5 (Staging Detection):** Analyze writeable user paths to catch second-stage binaries or embedded XML configuration scripts compiled at the workstation layer.
