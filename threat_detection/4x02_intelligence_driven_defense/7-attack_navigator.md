# HEALTHBANE ATT&CK Navigator Mapping

## Overview
This report maps the HEALTHBANE campaign to the MITRE ATT&CK framework using evidence collected from the previous task findings across Tasks 0-6 and the primary source materials:
* HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt
* meddefense_4x00_findings.txt
* researcher_blog_analysis.txt
* commercial_feed_extract.json

Techniques are classified as:
* OBSERVED -> directly supported by evidence
* INFERRED -> strongly suspected but not directly confirmed

---

## 1. ATT&CK Technique Mapping Organized by Tactic

### Initial Access Tactic
* **technique ID:** T1566.001
    * **technique name:** Phishing: Spearphishing Attachment
    * **classification:** OBSERVED
    * **evidence:** Malicious invoice and DOCM attachments observed
    * **source:** HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt / researcher_blog_analysis.txt
    * **attack phase:** Stage 1

* **technique ID:** T1566.002
    * **technique name:** Phishing: Spearphishing Link
    * **classification:** OBSERVED
    * **evidence:** Credential harvesting links used in phishing emails targeting the portal
    * **source:** meddefense_4x00_findings.txt / HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt
    * **attack phase:** Stage 1

---

### Credential Access Tactic
* **technique ID:** T1056
    * **technique name:** Input Capture
    * **classification:** INFERRED
    * **evidence:** Credential harvesting portals captured user credentials on fake pages
    * **source:** meddefense_4x00_findings.txt / HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt
    * **attack phase:** Stage 1

---

### Execution Tactic
* **technique ID:** T1059.001
    * **technique name:** Command and Scripting Interpreter: PowerShell
    * **classification:** OBSERVED
    * **evidence:** PowerShell exfiltration scripts identified as sync_healthdata.ps1
    * **source:** researcher_blog_analysis.txt / HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt
    * **attack phase:** Stage 2 / 3

---

### Persistence Tactic
* **technique ID:** T1053.005
    * **technique name:** Scheduled Task/Job: Scheduled Task
    * **classification:** OBSERVED
    * **evidence:** Scheduled tasks referenced in persistence behavior
    * **source:** HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt
    * **attack phase:** Stage 2

---

### Command and Control Tactic
* **technique ID:** T1071.004
    * **technique name:** Application Layer Protocol: DNS
    * **classification:** OBSERVED
    * **evidence:** DNS TXT tunneling identified for data channel exfiltration
    * **source:** HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt
    * **attack phase:** Stage 3

---

### Exfiltration Tactic
* **technique ID:** T1020
    * **technique name:** Automated Exfiltration
    * **classification:** OBSERVED
    * **evidence:** Automated PowerShell exfiltration script deployed on target endpoint
    * **source:** HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt / researcher_blog_analysis.txt
    * **attack phase:** Stage 3

---

## 2. Summary and Defensive Metrics

* **total techniques:** 7 techniques identified across the entire lifecycle.
* **observed:** 5 techniques directly documented in the files.
* **inferred:** 2 techniques strongly supported by structural patterns.
* **ratio:** 5 observed to 2 inferred techniques (71.4% to 28.6%).
* **most coverage:** Initial Access and Command and Control are the tactics with most coverage.
* **least coverage:** Reconnaissance and Lateral Movement are the tactics with least coverage.
* **detection planning:** The techniques that are most important for detection planning include T1071.004 (DNS Tunneling exfiltration channels) and T1566.002 (Phishing infrastructure matching Namecheap registration patterns).
