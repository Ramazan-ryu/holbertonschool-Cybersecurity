# HEALTHBANE Adversary Profile

## 1. Identity and Attribution

### Observed designations

* **HEALTHBANE** (primary designation used by entity["organization","HC3","HHS Health Sector Cybersecurity Coordination Center"])

  * **Confidence:** High
  * **Evidence:** Direct multi-victim telemetry, confirmed phishing infrastructure, and HC3 advisory HC3-2026-HEALTHBANE-001.
  * **Caveats:** Represents campaign-level tracking, not necessarily a long-term actor identity.

* **VITALSCORE** (commercial label used by entity["company","Acme CTI","commercial threat intelligence provider"])

  * **Confidence:** Medium
  * **Evidence:** Acme feed clustering overlaps strongly with HEALTHBANE infrastructure and TTPs.
  * **Caveats:** Acme explicitly notes ML-based clustering and partial analyst review; may over-cluster unrelated infrastructure.

* **APT-MEDAGENT** (researcher attribution)

  * **Confidence:** Medium
  * **Evidence:** Blog analysis by entity["people","Marcus Weller","security researcher"] linking repeated tooling and infrastructure patterns across 2024–2025 campaigns.
  * **Caveats:** Not corroborated by HC3 or commercial feeds.

### Final working designation

**Recommended:** HEALTHBANE campaign operator

* This aligns with HC3 attribution neutrality
* Avoids premature grouping under APT labels
* Reflects observed operational continuity without overclaiming identity persistence

---

## 2. Capability Assessment

### Technical sophistication

* Moderate
* Uses commodity phishing kit architecture (PHP-based credential harvesting)
* Implements multi-stage infection chain (phishing → macro document → RAT → DNS tunneling)

### Tooling quality

* PHPMailer 6.6.0 observed across multiple sources
* wkhtmltopdf-based lure generation (0.12.6)
* Basic but effective macro and PowerShell payload chaining

### Infrastructure management

* Rapid domain rotation (registration-to-use window ~4–14 days)
* Mixed hosting: Hostinger, DigitalOcean, OVH
* Use of registrar diversity (Namecheap, Njalla for operator assets)

### Resource level

* Mid-tier cybercrime infrastructure
* Multiple VPS nodes and rotating domains indicate financial backing but not elite persistence infrastructure

### Actor classification

* **Assessment:** Mid-tier cybercrime operator
* Not consistent with APT-level strategic persistence
* More aligned with scalable phishing-as-a-service style operations

---

## 3. Intent and Targeting

### Sector focus

* Healthcare systems (primary)
* Insurance billing providers
* Medical clinics and hospital networks

### Geographic focus

* United States (strong Midwest ISAC concentration)

### Likely objectives

* Credential harvesting (primary)
* Patient and insurance record theft
* Malware deployment for persistence and exfiltration
* Potential financial monetization via access resale

### Targeting methodology

* Spear-phishing emails using healthcare-themed lures
* Domain impersonation (e.g., meddefense*, medequip*)
* Multi-stage social engineering (email → portal → document → macro execution)

---

## 4. Operational Signature

### Infrastructure pattern

* Short-lived domains (high churn)
* Consistent naming schema: healthcare + function (portal, benefits, invoice)

### Registrars and hosting

* Namecheap: phishing domains
* Njalla: operator-controlled infrastructure (C2)
* Hostinger / OVH / DigitalOcean: payload hosting and staging

### Domain naming convention

* meddefense-portal.com
* medequip-supplies.net
* meddefense-benefits.org
* outlook-protection.com

### TLS certificate usage

* Let’s Encrypt certificates issued shortly before campaign activation
* Typical lag: 1–7 days pre-usage

### Tooling signatures

* PHPMailer 6.6.0 (email delivery + header fingerprint)
* wkhtmltopdf 0.12.6 (PDF lure generation)
* VBA macros + PowerShell execution chain
* DNS tunneling for exfiltration (base32 encoded labels)

### Social engineering pattern

* Urgency-based messaging ("FINAL NOTICE", "URGENT")
* Healthcare/HR/invoice themes
* Multi-department targeting within organizations

---

## 5. Predictive Assessment

### Likely changes

* Frequent domain rotation under new healthcare-themed naming variants
* IP rotation across low-cost VPS providers
* Hash changes for macro payloads and executables

### Likely constants

* PHPMailer-based delivery remains core infrastructure
* Healthcare targeting will persist
* Credential harvesting remains primary access vector
* DNS-based exfiltration likely to continue in variants

### Indicators of retooling

* Shift away from PHPMailer 6.6.0 fingerprint
* Introduction of signed binaries or packers (to evade EDR)
* Migration from wkhtmltopdf to alternative document generation tools
* Reduced reliance on obvious healthcare keyword domains

---

## 6. Confidence and Unknowns

### What is known

* Multi-stage campaign confirmed by HC3 and MedDefense investigations
* Clear infrastructure overlap across phishing, malware, and C2 layers
* Repeated tooling signatures (PHPMailer, wkhtmltopdf, DNS tunneling)

### What is inferred

* Likely single coordinated operator or tightly coupled group
* Infrastructure reuse suggests centralized control or kit-based operation
* Commercial feed clustering (VITALSCORE) likely corresponds to same campaign cluster

### What remains unknown

* True identity of operator(s)
* Whether APT-MEDAGENT represents a single actor or a cluster label
* Extent of campaign reuse across non-healthcare sectors
* Degree of automation in phishing kit deployment

---

## Final Assessment

The HEALTHBANE campaign represents a **structured mid-tier cybercrime operation** with consistent tooling, repeatable infrastructure patterns, and scalable phishing infrastructure. While commercial and independent research labels (VITALSCORE, APT-MEDAGENT) suggest clustering, confidence is highest when using HC3’s neutral campaign-based designation.

**Final Recommendation:**
➡️ Treat as HEALTHBANE campaign operator cluster
➡️ Avoid over-attribution to a fixed APT identity
➡️ Focus defenses on infrastructure + behavioral signatures

