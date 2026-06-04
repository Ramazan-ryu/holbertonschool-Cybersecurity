## IOC Extraction Report

---

# IOC Categorization

## Delivery Phase IOCs

| IOC Type | IOC Value | Source Email | Context | Confidence | Recommended Action |
|---|---|---|---|---|---|
| Domain | meddefense-portal[.]com | E2 | Credential-harvesting phishing domain impersonating MedDefense services | HIGH | Block |
| Email Address | support@meddefense-portal[.]com | E2 | Suspicious sender tied to phishing portal | HIGH | Block |
| IP Address | 185.217.0[.]84 | E2 | Observed sending infrastructure associated with phishing delivery | HIGH | Block |
| Tool | PHPMailer | E2 | Mailer fingerprint associated with phishing infrastructure | MEDIUM | Monitor |
| Domain | medequip-supplies[.]net | E5 | Invoice-themed phishing infrastructure | HIGH | Block |
| Email Address | billing@medequip-supplies[.]net | E5 | Fraudulent supplier/payment-themed sender | HIGH | Block |
| IP Address | 91.243.44[.]201 | E5 | External phishing infrastructure | HIGH | Block |
| Tool | PHPMailer | E5 | Shared phishing mailer fingerprint | MEDIUM | Monitor |
| Domain | meddefense-benefits[.]org | E7 | HR/benefits impersonation domain | HIGH | Block |
| Email Address | hr@meddefense-benefits[.]org | E7 | Fraudulent HR-themed sender | HIGH | Block |
| IP Address | 185.38.151[.]72 | E7 | Phishing delivery infrastructure | HIGH | Block |
| Tool | PHPMailer | E7 | Shared mailer software across phishing emails | MEDIUM | Monitor |

---

## Credential Harvesting IOCs

| IOC Type | IOC Value | Source Email | Context | Confidence | Recommended Action |
|---|---|---|---|---|---|
| URL | hxxps://meddefense-portal[.]com/login | E2 | Credential-harvesting login portal | HIGH | Block |
| URL | hxxps://outlook-protection[.]com/secure-review | E3 | Fake Microsoft-style credential portal | HIGH | Block |
| Domain | outlook-protection[.]com | E3 | Lookalike domain impersonating Microsoft/Outlook branding | HIGH | Block |
| IP Address | 103.145.13[.]77 | E3 | Infrastructure hosting lookalike phishing portal | HIGH | Block |
| Email Address | security@outlook-protection[.]com | E3 | Fake Microsoft-themed sender | HIGH | Block |

---

## Attachment / Lure Artifact IOCs

| IOC Type | IOC Value | Source Email | Context | Confidence | Recommended Action |
|---|---|---|---|---|---|
| PDF URL | hxxps://medequip-supplies[.]net/docs/invoice_april.pdf | E5 | Embedded invoice lure PDF | HIGH | Block |
| File Name | invoice_april.pdf | E5 | Attachment lure used for finance targeting | MEDIUM | Monitor |
| Infrastructure Note | Invoice-themed supplier impersonation | E5 | Finance/AP-focused phishing lure | MEDIUM | Alert |
| Infrastructure Note | Benefits enrollment urgency messaging | E7 | HR-targeted phishing lure | MEDIUM | Alert |
| Infrastructure Note | Security verification pretext | E2 | Clinical-user credential theft lure | MEDIUM | Alert |

---

## Infrastructure IOCs

| IOC Type | IOC Value | Source Email | Context | Confidence | Recommended Action |
|---|---|---|---|---|---|
| Infrastructure Note | Lookalike MedDefense-themed domains | E2/E7 | Domains impersonate trusted healthcare workflows | HIGH | Alert |
| Infrastructure Note | Shared PHPMailer fingerprints | E2/E5/E7 | Similar mailing infrastructure observed | MEDIUM | Monitor |
| Infrastructure Note | SPF fail / softfail patterns | E2/E5/E7 | Weak authentication consistent with phishing operations | MEDIUM | Monitor |
| Infrastructure Note | DMARC failures | E2/E5/E7 | Domain alignment failures tied to spoofing behavior | MEDIUM | Monitor |
| Infrastructure Note | Role-based healthcare targeting | E2/E5/E7 | Clinical, finance and HR departments targeted separately | MEDIUM | Alert |

---

## Context-Only Indicators

| IOC Type | IOC Value | Source Email | Context | Confidence | Recommended Action |
|---|---|---|---|---|---|
| Infrastructure Note | Healthcare-sector phishing trends | E8 | HC3 advisory describing healthcare phishing activity | LOW | Context only |
| Infrastructure Note | PHPMailer usage alone | E2/E5/E7 | Legitimate services may also use PHPMailer | LOW | Context only |
| Infrastructure Note | Shared hosting providers | Multiple | Hosting overlap alone is insufficient for blocking | LOW | Context only |
| Infrastructure Note | Registrar overlap | Multiple | Registrar data alone is not attribution evidence | LOW | Context only |

---

# IOC Quality Assessment

## High-Confidence IOCs

The following indicators are high-confidence because they are directly tied to phishing delivery or credential-harvesting activity:

- meddefense-portal[.]com
- medequip-supplies[.]net
- meddefense-benefits[.]org
- outlook-protection[.]com
- Credential-harvesting URLs
- Observed phishing sender addresses
- Related phishing IP addresses

These indicators are appropriate for:
- DNS blocking
- Email gateway blocking
- SIEM alerting
- Threat intelligence sharing

---

## Medium-Confidence IOCs

The following indicators support investigation activity but may create false positives if blocked independently:

- PHPMailer fingerprints
- SPF softfail patterns
- DMARC failures
- Invoice or HR-themed phishing language
- Role-based targeting behavior

These indicators are best used for:
- Threat hunting
- Correlation analysis
- SIEM enrichment
- Alert generation

---

## Low-Confidence / Context-Only Indicators

The following indicators should not be blocked independently:

- Hosting providers
- Registrars
- Shared healthcare terminology
- Generic urgency language
- PHPMailer usage alone

These indicators may appear in legitimate environments and should only support broader correlation analysis.

---

# HC3-Ready Summary

Observed phishing activity targeted MedDefense personnel using role-specific lures against clinical staff, finance/accounts payable and HR-related personnel.

High-confidence phishing infrastructure identified during analysis:

## Domains

- meddefense-portal[.]com
- medequip-supplies[.]net
- meddefense-benefits[.]org
- outlook-protection[.]com

## Related URLs

- hxxps://meddefense-portal[.]com/login
- hxxps://outlook-protection[.]com/secure-review
- hxxps://medequip-supplies[.]net/docs/invoice_april.pdf

## Related Sender Addresses

- support@meddefense-portal[.]com
- billing@medequip-supplies[.]net
- hr@meddefense-benefits[.]org
- security@outlook-protection[.]com

## Related Infrastructure IPs

- 185.217.0[.]84
- 91.243.44[.]201
- 185.38.151[.]72
- 103.145.13[.]77

## Campaign Characteristics

- Healthcare-sector targeting
- Credential-harvesting activity
- Lookalike domains
- Role-specific phishing themes
- PHPMailer-related infrastructure
- Weak or failed SPF/DKIM/DMARC authentication
- Urgency-based social engineering

---

# False-Positive Considerations

Some indicators observed during the investigation should NOT be blocked independently because they may generate excessive false positives or affect legitimate services.

Examples include:

- PHPMailer:
  PHPMailer is commonly used in both legitimate applications and phishing campaigns. Its presence alone does not prove malicious activity.

- Microsoft infrastructure references:
  Microsoft-related infrastructure, Outlook branding, or cloud-hosted mail services may appear in both legitimate and malicious emails. Blocking generic Microsoft infrastructure could disrupt normal business communication.

- Shared hosting providers:
  Providers such as DigitalOcean, Hostinger, or Namecheap may host both legitimate and malicious domains simultaneously. Hosting-provider presence alone is not sufficient evidence for blocking.

- SPF softfail results:
  SPF softfail can occur because of forwarding issues or mail configuration problems and should not independently determine malicious classification.

- Generic urgency language:
  Urgent wording is common in phishing emails but also appears in legitimate healthcare, HR and finance communications.

These indicators are most effective when combined with:
- Lookalike domains
- Credential-harvesting URLs
- DMARC failures
- Role-specific phishing lures
- Known malicious infrastructure

Correlation of multiple indicators provides stronger detection confidence and reduces false-positive risk.
