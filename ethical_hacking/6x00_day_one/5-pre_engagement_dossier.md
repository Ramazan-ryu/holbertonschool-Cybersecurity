# Pre-Engagement Dossier: Nexus Financial

**Document Version:** 1.0 (Draft for Review)
**Prepared By:** Vanguard Security Consulting
**Prepared For:** James Okafor, CISO, Nexus Financial
**Date:** [Current Date]

---

## 1. Executive Summary
Vanguard Security has been engaged by Nexus Financial to perform a comprehensive security assessment of its core payments platform, corporate infrastructure, and employee security awareness. Driven by investor due diligence requirements for an upcoming Series B funding round, this engagement aims to identify, quantify, and provide remediation guidance for security vulnerabilities. The objective is to provide an accurate picture of Nexus Financial's risk exposure while strictly safeguarding the availability of critical payment processing systems and the confidentiality of customer PII.

---

## 2. Scope Document

### 2.1 In-Scope Assets
The following assets are explicitly authorized for testing:
*   **Staging Environment:** The complete replica of the production AWS environment (EKS, RDS, S3).
*   **Production Environment:**
    *   Core Payments API (Ruby on Rails) - `api.nexus-financial.com`
    *   Customer Web Application - `app.nexus-financial.com`
    *   Mobile Applications (iOS and Android client binaries and their API communications).
    *   Admin Panel - `admin.nexus-financial.com`
*   **Corporate Infrastructure:**
    *   WireGuard VPN endpoints.
*   **Human Element:**
    *   All current employees for controlled social engineering (phishing).

### 2.2 Out-of-Scope Assets
The following are strictly prohibited from testing:
*   **VerifyID Infrastructure:** Any infrastructure, API endpoints, or servers owned or hosted by VerifyID.
*   **Stripe Infrastructure:** Any infrastructure owned by the payment gateway.
*   **Denial of Service (DoS/DDoS):** Any volumetric or resource-exhaustion attacks against Nexus Financial infrastructure.
*   **Physical Security:** Tailgating, lockpicking, or unauthorized physical entry to Nexus Financial offices.
*   **AWS Underlying Infrastructure:** The hypervisors and underlying physical network of AWS (testing is limited to the Nexus tenant configuration and hosted applications).

### 2.3 Scope Boundaries & Gray Areas
*   **Production vs. Staging:** *Recommendation: Hybrid Approach.* To satisfy the CTO's requirement for realistic testing and the CFO's requirement for zero downtime, heavy automated scanning and destructive payload testing will be restricted to the Staging environment. Findings will then be carefully, manually validated in Production using benign payloads to confirm existence without causing disruption.
*   **Third-Party Integrations (VerifyID/Stripe):** *Recommendation: Application-Side Testing Only.* We will test how the Nexus application processes, sanitizes, and validates responses *from* VerifyID and Stripe. We will not send malicious payloads *to* their APIs.
*   **Social Engineering:** *Recommendation: Phishing Only.* We will conduct a realistic credential-harvesting phishing campaign. Active pretexting (phone calls) or deploying macro-enabled malware is excluded to prevent business disruption and minimize legal risk.

---

## 3. Rules of Engagement (RoE)

### 3.1 Testing Windows and Authorized Hours
*   **Staging Environment:** 24/7 testing permitted.
*   **Production Environment:** Strictly limited to EU Business Hours (09:00 - 18:00 CET). *Justification:* If an unexpected outage occurs, the Nexus IT/DevOps teams are online and available to immediately restore services, mitigating the CFO's concerns regarding revenue-impacting downtime.

### 3.2 Testing Approach
*   **Recommendation:** Gray Box.
*   **Justification:** Given the tight 4-week timeline and the goal of comprehensive risk discovery, a pure Black Box approach wastes valuable time on reconnaissance. Providing Vanguard with architecture diagrams, API documentation, and varying levels of user/admin credentials will maximize the ROI and ensure deep business-logic flaws are uncovered prior to the investor audit.

### 3.3 Communication Protocols
*   Routine updates and weekly status reports will be sent via PGP-encrypted email to the designated Project Managers.
*   Critical findings (e.g., unauthenticated RCE, database exposure) will be reported immediately to the CISO via secure messaging (e.g., Signal) and followed up with an encrypted email.

### 3.4 Emergency Stop Procedures
*   **Triggers:** Unplanned degradation of the production API, payment processing failures, or accidental access to high-volume PII.
*   **Authority:** The "Kill Chain" can be invoked by the Nexus CISO, CFO, CTO, or the Vanguard Lead Consultant.
*   **Mechanism:** A direct phone call to the Vanguard Lead. Upon receipt, all testing tools will be immediately halted.

### 3.5 Data Handling Procedures
*   Nexus Financial operates under GDPR. Vanguard will not exfiltrate, alter, or destroy any production Protected Health Information (PHI), Personally Identifiable Information (PII), or financial data.
*   If access to a database containing PII is achieved, Vanguard will document the access using heavily redacted screenshots (showing only column headers or fabricated test data) to prove impact, then immediately back out.
*   All engagement data will be securely wiped from Vanguard systems 30 days after final report delivery.

### 3.6 Incident Discovery Protocol
*   If Vanguard discovers evidence of a pre-existing or active compromise (e.g., a webshell, unauthorized lateral movement, or exploited leaked keys), testing will pause immediately.
*   Vanguard will contact the CISO out-of-band to report the finding so Nexus can activate their Incident Response plan without interference from our testing traffic.

---

## 4. Communication Plan

### 4.1 Points of Contact
*   **Vanguard Security:** Sarah Chen (Lead Consultant / PM), [Your Name] (Consultant)
*   **Nexus Financial Primary:** James Okafor (CISO)
*   **Nexus Financial Escalation/Sign-off:** Thomas [Last Name] (CTO), Maria [Last Name] (CFO)

### 4.2 Reporting Cadence
*   **Day 1:** Kickoff call to confirm scope and credential access.
*   **Weekly:** End-of-week status email detailing systems tested, high-level findings, and next week's plan.
*   **Immediate:** Ad-hoc alerts for Critical/High vulnerabilities.
*   **Week 4:** Delivery of Draft Report and Executive Read-out presentation.

### 4.3 Stakeholder Management
*   **Addressing the CTO/CFO Conflict:** Prior to signing the SoW, Vanguard will host a mandatory alignment meeting with the CISO, CTO, and CFO. We will present the "Hybrid Approach" (Heavy Staging / Light Prod) explicitly to demonstrate how it achieves the CTO's desire for a realistic attack simulation while guaranteeing the CFO's requirement for zero production downtime. Sign-off must be unanimous.

### 4.4 Secure Communication Channels
*   Encrypted Email (PGP).
*   Encrypted file transfer portal for deliverable submission.
*   Out-of-band secure messaging (Signal) for critical alerts.

---

## 5. Risk Register (Engagement Risks)

| Risk Description | Likelihood | Impact | Mitigation Strategy |
| :--- | :---: | :---: | :--- |
| **1. Production Outage:** Testing traffic accidentally crashes the core payments API, disrupting revenue and investor diligence. | Medium | High | Restrict heavy scanning/payloads to Staging. Limit Production testing to EU business hours for rapid recovery. Exclude DoS testing. |
| **2. Scope Creep into Third Parties:** Testers accidentally attack Stripe or VerifyID APIs, violating the CFAA and triggering legal action. | Low | High | Explicitly document exclusions in the RoE. Implement strict IP/domain blacklisting in Vanguard's testing tools (e.g., Burp Suite scope rules). |
| **3. Lack of Legal Authorization:** The engagement proceeds based solely on the CISO's signature, leaving Vanguard legally exposed. | High | High | Require formal signature on the Statement of Work from a Board Member or C-level executive with legal binding authority (CTO/CFO) prior to testing. |
| **4. GDPR Violation / PII Exposure:** Real customer financial data is accidentally downloaded or exposed during database exploitation. | Medium | High | Strict RoE data handling clauses. Testers are instructed to stop at the point of access, redact evidence, and utilize test accounts whenever possible. |
| **5. Missed Investor Deadline:** Technical blockers (e.g., VPN issues, staging environment broken) delay testing, missing the Series B deadline. | Medium | High | Establish the Go/No-Go checklist. Require all credentials, VPN access, and environment stability to be verified 48 hours before the official start date. |

---

## 6. Go / No-Go Checklist

Testing **WILL NOT COMMENCE** until all of the following conditions are met:

*   [ ] **Authorization:** Statement of Work and this Pre-Engagement Dossier signed by an authorized Nexus executive (CTO/CFO representing the Board).
*   [ ] **Scope Alignment:** CISO, CTO, and CFO have formally agreed to the Staging/Production Hybrid approach.
*   [ ] **Access Verified:** Vanguard consultants have successfully connected to the WireGuard VPN.
*   [ ] **Credentials Provisioned:** All requested test accounts for the Admin Panel, Web App, and Mobile Apps are active and functioning.
*   [ ] **Environment Stability:** Nexus IT confirms the Staging environment accurately mirrors Production and is stable.
*   [ ] **Whitelisting:** Vanguard source IP addresses have been whitelisted by Nexus WAF/IDS to prevent premature blocking during the agreed testing windows.
*   [ ] **Emergency Contacts:** 24/7 technical emergency contact numbers are confirmed and tested.
