# Phishing Investigation Report — MedDefense Campaign

---

## 1. Executive Summary

This investigation identified a phishing campaign targeting MedDefense employees using impersonation domains and social engineering. Multiple emails attempted to trick users into interacting with fake login and business portals. Emails 2, 5, and 7 are likely part of the same coordinated campaign affecting different departments. One user, Diane Marsh, clicked a link in Email 2, creating a potential exposure risk. Immediate containment and monitoring actions are required.

---

## 2. Investigation Timeline

- Email collection window: April 14 – April 17, 2026
- Email 2 delivery: April 14, 2026
- Email 5 delivery: April 16, 2026
- Email 7 delivery: April 16, 2026
- Diane Marsh click event: Email 2 link clicked from WS-NURSE-04 at 2026-04-14 15:02:33 CDT (timestamp confirmed in log analysis)
- Scope: Email headers, authentication checks, domain analysis, HC3 comparison, IOC correlation

---

## 3. Email-by-Email Analysis

### Email 1
- Verdict: Legitimate newsletter   
- Classification: BENIGN   
- Confidence: High   
- Evidence: SPF, DKIM, and DMARC pass; sender domain aligned; no impersonation indicators   

### Email 2
- Verdict: Phishing (credential harvesting)   
- Classification: PHISHING-OPPORTUNISTIC   
- Confidence: High   
- Evidence: SPF fail, missing DKIM, DMARC failure, and use of meddefense-portal.com (lookalike healthcare login portal) over IP 91.234.99.107

### Email 3
- Verdict: Suspicious brand impersonation   
- Classification: PHISHING-OPPORTUNISTIC   
- Confidence: High   
- Evidence: outlook-protection.com is not an official Microsoft domain; used for impersonation over IP 164.90.218.73 despite authentication passing   

### Email 4
- Verdict: Legitimate internal email   
- Classification: BENIGN   
- Confidence: High   
- Evidence: Internal domain alignment and full authentication pass   

### Email 5
- Verdict: Phishing (invoice-themed)   
- Classification: PHISHING-OPPORTUNISTIC   
- Confidence: High   
- Evidence: SPF softfail, missing DKIM, DMARC failure; financial invoice impersonation content over IP 51.38.42.17  

### Email 6
- Verdict: Spam   
- Classification: SPAM   
- Confidence: High   
- Evidence: Bulk email patterns, SPF softfail, DMARC quarantine policy   

### Email 7
- Verdict: Phishing (HR-targeted)   
- Classification: PHISHING-TARGETED   
- Confidence: High   
- Evidence: SPF fail, missing DKIM, DMARC failure; HR/benefits impersonation targeting employees over IP 185.176.43.22  

### Email 8
- Verdict: Phishing (Executive Lure)   
- Classification: PHISHING-TARGETED   
- Confidence: High   
- Evidence: Urgent spear-phishing security notice sent to leadership targeting administrative credentials, aligning with current campaign indicators   

---

## 4. Campaign Analysis

Emails 2, 5, and 7 are part of a coordinated phishing campaign targeting MedDefense.

### Shared Indicators
- Lookalike healthcare/business domains:
  - meddefense-portal.com   
  - meddefense-benefits.org   
  - medequip-supplies.net   
- Authentication failures across multiple emails (SPF fail/softfail, missing DKIM, DMARC failure)
- Role-based targeting:
  - Email 2 → clinical staff (login portal lure)
  - Email 5 → finance (invoice lure)
  - Email 7 → HR (benefits lure)

### HC3 Context (Email 8)
Email 8 confirms known healthcare phishing patterns. It uses impersonation domains, fake credential harvesting portals, and urgency-based social engineering targeted at key personnel. This strengthens confidence that Emails 2, 5, and 7 belong to the same campaign.

### Email 3 Interpretation
Email 3 shows that SPF/DKIM passing does not guarantee legitimacy when attackers use trusted-looking domains for impersonation. It represents separate or less directly connected infrastructure used to blend into background noise.

---

## 5. Click Incident Assessment

### Confirmed facts
- Diane Marsh clicked a link in Email 2 
- Domain: meddefense-portal.com 
- Email showed authentication failures (SPF fail, no DKIM, DMARC fail) 
- Activity occurred on WS-NURSE-04 
- Exact timestamp of the event: 2026-04-14 15:02:33 CDT

### What cannot be confirmed
- Credential submission 
- Malware execution 
- Data exfiltration 
- System compromise 

### Assessment
This is a confirmed phishing exposure, not a confirmed compromise.

### Recommended actions
- Reset credentials immediately 
- Revoke active sessions 
- Review browser history and downloads 
- Check mailbox rules and forwarding changes 
- Monitor authentication logs for anomalies 

---

## 6. IOC Summary

### High-confidence block IOCs
- meddefense-portal.com   
- medequip-supplies.net   
- meddefense-benefits.org   

### Monitor IOCs
- outlook-protection.com   

### Email indicators
- SPF failure / softfail   
- Missing DKIM   
- DMARC failure   

### Infrastructure patterns
- Healthcare impersonation themes   
- Role-based phishing distribution   
- External login portal hosting   

### Domains
- meddefense-portal.com
- meddefense-benefits.org
- medequip-supplies.net
- outlook-protection.com

### IPs
- 91.234.99.107
- 51.38.42.17
- 185.176.43.22
- 164.90.218.73

### URLs and Sender Addresses
- alerts@meddefense-portal.com
- billing@medequip-supplies.net
- hr@meddefense-benefits.org
- security@outlook-protection.com

### Affected User and Asset
- Affected User: Diane Marsh
- Affected Workstation: WS-NURSE-04
- Click Timestamp: 2026-04-14 15:02:33 CDT

---

## 7. Detection and Control Gaps

### Observed gaps
- No DNS-level blocking of lookalike domains   
- Email gateway allowed authentication-failing messages   
- No pre-click URL filtering   
- Limited endpoint browser visibility   

### Improvements needed
- Enforce DMARC reject policy   
- Add IOC-based domain blocking   
- Implement real-time URL reputation filtering   
- Improve endpoint telemetry monitoring   

---

## 8. Recommendations

### Immediate (0–24 hours)
- Reset affected user credentials   
- Revoke active sessions   
- Block phishing domains (DNS + email gateway)   
- Hunt for related emails   

### Short-term (1–7 days)
- Deploy IOC-based detection rules   
- Strengthen DMARC enforcement   
- Review mail logs for additional victims   
- Begin awareness notification   

### Medium-term (7–30 days)
- Implement role-based phishing detection   
- Add endpoint/browser telemetry monitoring   
- Integrate HC3 intelligence feeds   
- Run phishing simulation training
