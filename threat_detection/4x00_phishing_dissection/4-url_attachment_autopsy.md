## URL and Attachment Autopsy

This document provides a safe analysis of indicators of compromise (IOCs) found in emails E2, E3, E5, and E7. All URLs are defanged. No live browsing or execution is performed. Only email-contained evidence and passive investigation methods are used.

---

## Indicator 1

- Source email: E2
- Original value: https://meddefense-portal.com/verify/staff?id=dmarsh&token=a8f3e2d1
- Defanged value: hxxps://meddefense-portal[.]com/verify/staff?id=dmarsh&token=a8f3e2d1
- Domain or IP: meddefense-portal[.]com
- Indicator type: Credential phishing URL

- Evidence from email:
  - Embedded in “VERIFY MY ACCESS NOW” button
  - Claims mandatory portal re-verification within 24 hours
  - Impersonates MedDefense IT Security

- Safe investigation method:
  - whois meddefense-portal.com
  - dig meddefense-portal.com
  - nslookup meddefense-portal.com
  - VirusTotal domain lookup
  - urlscan.io submission (passive)

- Finding:
  Lookalike credential harvesting domain used in IT impersonation attack.

- Risk rating: HIGH

---

## Indicator 2

- Source email: E3
- Original value: https://outlook-protection.com/verify
- Defanged value: hxxps://outlook-protection[.]com/verify
- Domain or IP: outlook-protection[.]com
- Indicator type: Microsoft impersonation phishing URL

- Evidence from email:
  - Claims unusual sign-in from Nigeria (Lagos)
  - 48-hour account lock threat
  - Fake Microsoft branding

- Safe investigation method:
  - whois outlook-protection.com
  - dig outlook-protection.com
  - nslookup outlook-protection.com
  - VirusTotal URL lookup
  - urlscan.io analysis

- Finding:
  Credential harvesting domain impersonating Microsoft security alerts.

- Risk rating: HIGH

---

## Indicator 3 (URL + ATTACHMENT ANALYSIS)

- Source email: E5
- Original value: https://medequip-supplies.net/invoices/pay?id=INV-2026-04891
- Defanged value: hxxps://medequip-supplies[.]net/invoices/pay?id=INV-2026-04891
- Domain or IP: medequip-supplies[.]net
- Indicator type: BEC phishing URL + malicious attachment indicator

- Evidence from email (URL):
  - Invoice INV-2026-04891 for $24,716.38
  - 7-day payment deadline
  - Threat of suspension and late fees

- Evidence from email (attachment):
  - Attachment name: INV-2026-04891.pdf
  - MIME type: application/pdf
  - Base64 encoded PDF present in raw email
  - Delivered alongside payment demand message

- Safe investigation method:
  - VirusTotal file hash analysis (PDF)
  - pdfid / pdf-parser (offline inspection)
  - strings INV-2026-04891.pdf
  - whois medequip-supplies.net
  - urlscan.io analysis of invoice URL
  - dig / nslookup for domain resolution

- Finding:
  Invoice-themed phishing email combining credential harvesting link and embedded PDF attachment likely used for malware delivery or social engineering fraud.

- Risk rating: CRITICAL

---

## Indicator 4

- Source email: E7
- Original value: https://meddefense-benefits.org/enroll
- Defanged value: hxxps://meddefense-benefits[.]org/enroll
- Domain or IP: meddefense-benefits[.]org
- Indicator type: HR phishing URL

- Evidence from email:
  - “FINAL NOTICE” open enrollment pressure
  - Threat of losing health coverage
  - Encourages login even if already enrolled

- Safe investigation method:
  - whois meddefense-benefits.org
  - dig meddefense-benefits.org
  - nslookup meddefense-benefits.org
  - VirusTotal domain lookup
  - urlscan.io analysis

- Finding:
  HR-themed credential harvesting domain exploiting benefits urgency.

- Risk rating: HIGH

---

## Indicator 5

- Source email: E5
- Original value: 203.0.113.228
- Defanged value: 203[.]0[.]113[.]228
- Domain or IP: 203[.]0[.]113[.]228
- Indicator type: Suspicious hosting IP

- Evidence from email:
  - Appears in external delivery infrastructure supporting phishing campaign context
  - Associated with invoice delivery ecosystem in E5 chain

- Safe investigation method:
  - whois 203.0.113.228
  - nslookup 203.0.113.228
  - dig -x 203.0.113.228
  - VirusTotal IP reputation lookup
  - Passive OSINT enrichment only

- Finding:
  External IP used as infrastructure component in phishing delivery chain; analysis limited to static email evidence.

- Risk rating: HIGH
