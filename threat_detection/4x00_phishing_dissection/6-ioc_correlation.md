## IOC Correlation Report

---

### Normalized IOC List

**Domains & URLs:**
- Domain: meddefense-portal.com (defanged: meddefense[-]portal[.]com)
- URL: hxxps://meddefense[-]portal[.]com/verify/staff?id=dmarsh&token=a8f3e2d1
- Domain: outlook-protection.com (defanged: outlook[-]protection[.]com)
- Domain: medequip-supplies.net (defanged: medequip[-]supplies[.]net)
- Domain: meddefense-benefits.org (defanged: meddefense[-]benefits[.]org)

**Sending IP:**
- 91.234.99.107 (Email 2)
- 51.38.42.17 (Email 3)
- 185.176.43.22 (Email 5)
- 164.90.218.73 (Email 7)
- 203.0.113.228 (Email 6)

**Recipients:**
- dmarsh@meddefense.com (Email 2)
- rmendez@meddefense.com (Email 3)
- arivera@meddefense.com (Email 5)
- lpatterson@meddefense.com (Email 7)

**Timestamps:**
- 2026-04-14 14:47:52 -0500 (Email 2 delivery)
- 2026-04-14 15:02:33 CDT (click event — Diane Marsh WS-NURSE-04 / 10.10.2.15)
- 2026-04-15 09:13:44 -0500 (Email 3 delivery)
- 2026-04-16 11:28:39 -0500 (Email 5 delivery)
- 2026-04-16 15:22:07 -0500 (Email 7 delivery)

---

### Exposure Timeline

2026-04-14 14:47:52 -0500: Email 2 delivered to dmarsh@meddefense.com from 91.234.99.107   
2026-04-14 15:02:33 CDT: Diane Marsh (WS-NURSE-04, 10.10.2.15) clicks phishing URL   
2026-04-15 09:13:44 -0500: Email 3 delivered (outlook-protection.com)   
2026-04-16: Email 5 invoice phishing campaign observed   
2026-04-16: Email 7 HR benefits phishing observed   
2026-04-16 08:47 CDT: HC3 confirms active campaign (Email 8)

---

### Confirmed Evidence From Batch

- sending IPs confirm spoofed infrastructure usage
- recipient targeting is role-based (clinical, billing, HR)
- timestamp correlation confirms click event for Email 2
- domain impersonation across internal services and vendors
- PHPMailer used in multiple emails (E2, E5, E7)
- SPF/DMARC failures observed in malicious emails
- HC3 advisory confirms active healthcare phishing campaign

---

### Queries To Run If Logs Are Available

DNS:
- would search for domain resolution history for:
 - meddefense-portal.com
 - outlook-protection.com
 - medequip-supplies.net
 - meddefense-benefits.org

Proxy:
- would query HTTP logs for requests to:
 - /verify/
 - /login/
 - /enroll/
 - /invoices/pay
- inspect traffic to suspicious sending IPs

Endpoint:
- would search process execution on WS-NURSE-04 (10.10.2.15)
- investigate browser process spawn at 2026-04-14 15:02:33 CDT
- check file access to downloaded PDF attachments

Authentication:
- would query login logs for dmarsh@meddefense.com
- would search for anomalous sign-ins following Email 3

---

### Detection Gaps

- lack of DNS filtering for lookalike domains
- missing proxy alerting for newly registered domains
- insufficient endpoint monitoring on phishing click events
- weak correlation between email + authentication logs
- no automated detection of urgency-based phishing patterns
- missing cross-channel IOC correlation between departments

---

### Conclusion

This is a coordinated phishing campaign targeting healthcare operations. The confirmed click by Diane Marsh (WS-NURSE-04, 10.10.2.15) at 20
26-04-14 15:02:33 CDT represents successful compromise via Email 2. Subsequent emails show expansion into credential theft and financial fr
aud. HC3 intelligence confirms the campaign is active and multi-organizational.

