# HEALTHBANE Intelligence Brief

---

## 1. Executive Summary (Board-Level)

HEALTHBANE is a coordinated, financially motivated phishing and intrusion campaign targeting healthcare organizations in the United States. MedDefense Health Systems was affected through credential harvesting, with at least one confirmed user interaction leading to suspected credential submission via a phishing portal. At least two other healthcare organizations in the Midwest ISAC region experienced multi-stage compromise, including malware delivery and data exfiltration. Current intelligence indicates the campaign is active, with rotating infrastructure and continued targeting of healthcare providers and insurers. Detection at MedDefense is partially effective, relying primarily on indicator-based blocking of known domains, IPs, and hashes. However, adversary infrastructure rotation reduces long-term effectiveness of static defenses. Immediate actions are required to strengthen behavioral detection, enforce email authentication controls, and improve DNS and endpoint monitoring. Top priorities are MFA enforcement across all external access points, deployment of behavioral phishing detection, and expansion of threat hunting for DNS tunneling and scheduled task persistence.

---

## 2. Adversary Profile

The adversary is tracked as the HEALTHBANE campaign operator cluster. Attribution remains unconfirmed, but confidence is high that this represents a mid-tier cybercrime actor rather than an APT. The group demonstrates consistent use of PHPMailer-based phishing kits, wkhtmltopdf-generated lure documents, and DNS-based command-and-control infrastructure. Commercial intelligence labels such as VITALSCORE (entity["company","Acme CTI","commercial threat intelligence provider"]) overlap significantly but rely on partially automated clustering and should be treated cautiously.

HC3 (entity["organization","HC3","Health Sector Cybersecurity Coordination Center"]) assesses the actor as financially motivated with moderate technical capability. Independent research attributes such as APT-MEDAGENT (entity["people","Marcus Weller","security researcher"] analysis) suggest historical continuity across healthcare phishing campaigns but lack authoritative confirmation.

Key characteristics:

* Mid-tier cybercrime capability
* Modular phishing kit infrastructure
* Healthcare-focused targeting
* Infrastructure churn and rapid domain rotation

---

## 3. Campaign Analysis

### Stage 1: Credential Harvesting

* Spear-phishing emails using healthcare-themed domains
* PHPMailer 6.6.0 headers
* Credential capture via fake staff/benefits/invoice portals
* Observed at MedDefense and multiple partner organizations

### Stage 2: Malware Delivery

* Use of compromised accounts for lateral phishing
* Macro-enabled documents (DOCM)
* Payload delivery via second-stage C2 infrastructure

### Stage 3: Exfiltration

* DNS tunneling using base32-encoded subdomains
* Patient and insurance data exfiltration observed in external environments

### Timeline

* 2026-04-05 to 2026-04-10: Domain registration burst
* 2026-04-14: First observed phishing activity
* 2026-04-16–04-22: Malware delivery phase
* 2026-04-23–04-26: Exfiltration phase observed

### Confidence

* Stage 1: HIGH
* Stage 2: HIGH (external organizations)
* Stage 3: HIGH (packet-level evidence outside MedDefense)

---

## 4. ATT&CK Mapping

### Observed Techniques

* T1566.002 Spearphishing Link
* T1566.001 Spearphishing Attachment
* T1059.005 VBA Macros
* T1059.001 PowerShell
* T1053.005 Scheduled Tasks
* T1547.001 Registry Run Keys
* T1071.004 DNS C2
* T1041 Exfiltration over C2

### Inferred Techniques

* T1078 Valid Accounts (post-compromise lateral movement)
* T1021 Remote Services (likely internal propagation)

### Detection Relevance

* High reliance on email and DNS telemetry
* Endpoint persistence mechanisms currently under-monitored
* Behavioral detection gaps in macro execution chains

---

## 5. Detection Gap Assessment

### Critical Gaps (Observed but not reliably detected)

* DNS tunneling detection not fully operational
* Macro execution behavioral correlation missing
* Cross-account email abuse detection limited

### Inferred Gaps

* Lack of lateral movement detection (remote service usage)
* Weak anomaly detection on newly created scheduled tasks
* Insufficient detection of compromised internal email accounts

### Priority

1. DNS exfiltration detection (high urgency)
2. Macro + PowerShell execution chaining detection
3. Identity-based anomaly detection across departments

---

## 6. Indicator of Compromise Table

### Stage 1: Phishing Infrastructure

| Indicator               | Confidence | Action               |
| ----------------------- | ---------- | -------------------- |
| meddefense-portal.com   | HIGH       | Block + monitor DNS  |
| medequip-supplies.net   | HIGH       | Block                |
| meddefense-benefits.org | HIGH       | Block                |
| outlook-protection.com  | HIGH       | Block + email filter |

### Stage 2: Malware Delivery

| Indicator                  | Confidence | Action              |
| -------------------------- | ---------- | ------------------- |
| HEALTHBANE_S2_invoice.docm | HIGH       | EDR block           |
| svchost_update.exe         | HIGH       | Endpoint quarantine |

### Stage 3: Exfiltration

| Indicator                   | Confidence | Action                      |
| --------------------------- | ---------- | --------------------------- |
| healthbane-c2.net           | HIGH       | DNS sinkhole                |
| data-sync.healthbane-c2.net | HIGH       | Block DNS + monitor queries |

---

## 7. YARA Rule Summary

### Rules Developed

* HEALTHBANE_Email_Headers
* HEALTHBANE_Document_Metadata
* HEALTHBANE_Campaign_Composite

### Test Results (Task 11)

* High detection rate across phishing and document samples
* Minimal false positives in controlled dataset
* Composite rule requires tuning for edge-case benign PDFs

### Deployment Status

* Recommended: DEPLOY (header + document rules)
* Composite rule: MONITOR / TUNE depending on FP tolerance

---

## 8. Recommendations

### Immediate (0–48 hours)

* Enforce MFA on all external access and email accounts
* Block all known HEALTHBANE domains and IPs
* Disable Office macros from external sources
* Enable DNS query anomaly detection

### Short-term (2 weeks)

* Deploy behavioral detection for phishing + macro execution chains
* Implement scheduled task anomaly monitoring
* Improve email authentication enforcement (SPF/DKIM/DMARC alignment)

### Medium-term (30 days)

* Build correlation between email, endpoint, and DNS telemetry
* Introduce threat hunting for DNS tunneling patterns
* Develop user-aware phishing simulation program

---

## 9. Intelligence Gaps and Collection Priorities

### Unknowns

* True identity of the operator cluster
* Extent of reuse across non-healthcare sectors
* Full scale of compromised organizations

### Required Collection

* Full email gateway logs across healthcare partners
* DNS query logs with subdomain-level visibility
* Endpoint telemetry for macro execution chains
* Authentication logs for cross-organization credential reuse

### Responsible Parties

* SOC teams at MedDefense Health Systems
* Healthcare ISAC partners
* HC3 intelligence coordination unit

---

## Final Assessment

HEALTHBANE represents an active, evolving cybercrime campaign targeting healthcare systems with a repeatable phishing-to-exfiltration pipeline. While infrastructure is regularly rotated, operational patterns remain consistent, enabling effective behavioral detection strategies if properly implemented.

