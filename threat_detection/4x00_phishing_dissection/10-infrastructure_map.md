## Infrastructure Map

### Suspicious Infrastructure Table

| Domain | Source Email | Sender Address | Observed IP Address | Registration Timing | Registrar / Hosting | Mailer Software |
|---|---|---|---|---|---|---|
| meddefense-portal[.]com | E2 | alerts@meddefense-portal.com | External phishing IP observed in headers | Recently registered / short oper
ational age inferred from investigation | External hosting infrastructure; exact provider not confirmed in evidence | PHPMailer indicators
observed |
| medequip-supplies[.]net | E5 | billing@medequip-supplies.net | External sender infrastructure observed in headers | Recently registered o
r low-reputation infrastructure inferred | Exact registrar not confirmed from provided evidence | PHPMailer-related characteristics observe
d |
| meddefense-benefits[.]org | E7 | hr@meddefense-benefits.org | External phishing infrastructure observed in headers | Recently registered
timing inferred from campaign activity | Hosting provider not independently confirmed | PHPMailer indicators observed |
| outlook-protection[.]com | E3 | security@outlook-protection.com | External infrastructure associated with lookalike domain | Registration
timing unknown | Exact registrar/provider not confirmed in evidence | Mailer fingerprint not conclusively linked to PHPMailer |

---

## Relationship Map

Healthcare Phishing Campaign
|
+-------------------+-------------------+-------------------+
|                   |                   |
v                   v                   v
meddefense-portal.com medequip-supplies.net meddefense-benefits.org
91.234.99.107        51.38.42.17         185.176.43.22
|
+------------------- PHPMailer -------------------+
|
v
Clinical targets
Finance targets
HR targets
|
v
Urgency + lookalike domains

outlook-protection.com
164.90.218.73
less directly connected infrastructure

---

## Pattern Analysis

The strongest infrastructure relationship exists between:

- meddefense-portal[.]com
- medequip-supplies[.]net
- meddefense-benefits[.]org

These domains share several operational characteristics:

- Healthcare-related impersonation themes
- Role-specific phishing targeting
- Similar urgency and social engineering tactics
- Weak or failed authentication
- PHPMailer-related indicators
- Similar operational timeframe
- External infrastructure not associated with legitimate MedDefense systems

The phishing activity targeted multiple internal business functions:

- Clinical staff
- Finance/accounts payable
- HR/benefits personnel

This type of role-aware targeting suggests the attackers intentionally tailored phishing themes to organizational workflows rather than sen
ding generic spam.

Shared timing is also significant:

- E2 activity observed on April 14
- E5 and E7 activity observed on April 16

The short campaign window supports coordinated operational activity.

### Outlook-Protection[.]com Assessment

outlook-protection[.]com appears somewhat different from the other phishing domains.

Reasons:

- It impersonates Microsoft-related branding rather than MedDefense workflows
- SPF, DKIM and DMARC all passed successfully
- The domain appears professionally configured for authentication
- The phishing technique relies more heavily on lookalike branding than failed infrastructure

However, the domain still demonstrates phishing behavior because:

- outlook-protection[.]com is not microsoft.com or outlook.com
- The domain attempts to create trust through Microsoft-style naming
- The email used impersonation-oriented social engineering

The available evidence does not conclusively prove whether outlook-protection[.]com belongs to the same operators as E2, E5 and E7 or wheth
er it represents a separate phishing operation using similar healthcare-sector targeting.

---

## Final Assessment

The evidence most strongly supports use of disposable phishing infrastructure operated through externally hosted domains.

Assessment:
- Likely disposable attacker-controlled infrastructure
- Multiple lookalike domains created for phishing operations
- Role-specific phishing workflows targeting healthcare personnel

Confidence Level:
- Moderate-to-high confidence that Emails 2, 5, and 7 are part of the same coordinated phishing campaign
- Low-to-moderate confidence that outlook-protection[.]com is directly connected to the same operators


Evidence supporting confidence assessment:

- Repeated phishing themes across multiple domains
- Similar authentication failures
- PHPMailer-related indicators
- Short operational timeframe
- Consistent healthcare-sector targeting
- Multiple impersonation domains
- Role-aware phishing lures

What remains unconfirmed:

- Exact registrar overlap between all domains
- Shared backend hosting ownership
- Direct operational linkage between outlook-protection[.]com and the MedDefense-themed phishing domains
- Whether any infrastructure was compromised rather than attacker-created

The available evidence supports a coordinated phishing campaign using disposable external infrastructure rather than legitimate MedDefense
infrastructure.


