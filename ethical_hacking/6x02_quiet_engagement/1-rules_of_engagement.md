# Rules of Engagement, Lumen Industrial Systems

## Engagement Metadata
* **Client:** Lumen Industrial Systems
* **Engagement Reference:** ENG-LUMEN-2026-Q3
* **Engagement Window:** July 15, 2026 – August 15, 2026
* **Signing Parties:**
  * Lumen Industrial Systems: Chief Information Security Officer (CISO)
  * Vanguard Security: Lead Penetration Tester

## Scope

### In Scope
The authorized testing perimeter is strictly limited to Lumen-controlled infrastructure that directly supports the industrial SaaS platform:
* **Cloud-Hosted Platform:** All web-accessible administrative and client-facing dashboards hosted within the Lumen production environment (`*.lumen-industrial.com`).
* **Public API:** The external API layer (`api.lumen-industrial.com`) utilized for telemetry and platform integration.
* **Internal Admin Panel:** Lumen-controlled administrative backends accessible via the designated corporate VPN or external IP boundaries.
* **Lumen-Controlled Demo/QA Infrastructure:** Non-production environments explicitly provisioned by Lumen for customer demonstrations and internal QA testing.

### Out of Scope
* **Customer-Deployed Gateways and IoT Sensors:** All edge devices, PLCs, and gateways located on customer premises are strictly excluded. Lumen cannot authorize testing on assets it does not own or operate. Even if this customer-premises infrastructure is technically reachable from Lumen's environment, it remains legally out of scope.
* **Third-Party SaaS Applications:** Platforms hosted by external vendors (e.g., Salesforce, Office 365, AWS Control Plane) are excluded to prevent violating third-party Terms of Service (ToS) and unauthorized testing of shared infrastructure.
* **Physical Security and Social Engineering:** Physical intrusion and active phishing campaigns against employees are excluded from this specific technical mandate.

## Testing Window
* **Days:** Monday through Friday.
* **Hours:** 22:00 – 04:00 Central European Time (CET) to minimize operational disruption.
* **Blackout Periods:** Month-end financial reconciliation (July 30 – July 31). No active scanning or exploitation permitted during this window.

## Communication and Escalation
* **Primary Contact:** Lumen SOC Lead (Routine findings, daily check-ins).
* **Secondary Contact:** Lumen CISO (Critical findings, RoE modifications).
* **Escalation Path:** Tester -> Vanguard Pentest Lead -> Lumen SOC Lead -> Lumen CISO.
* **Channels:** PGP-encrypted email for reports; Signal/secure messaging for real-time alerts.
* **Expected Response Times:** < 15 minutes for critical/stop-condition alerts; < 24 hours for routine operational queries.

## Authorised Tools, Forbidden Tools
* **Authorised Tools:** Nmap, Burp Suite Professional, OWASP ZAP, BloodHound, custom Python/Bash scripts, open-source OSINT frameworks (e.g., Maltego, Recon-ng).
* **Forbidden Tools:** * **Metasploit Framework:** Strictly forbidden for establishing the initial foothold to ensure manual, low-noise exploitation and satisfy project constraints.
  * **DDoS/Stress Testing Tools:** Any tool designed to exhaust network bandwidth or application resources (e.g., LOIC).
  * **Destructive Payloads:** Ransomware simulators or any exploit known to cause unrecoverable system crashes or data corruption.

## Stop Conditions
Testing will halt immediately and the escalation path will be triggered if any of the following occur:
* **Service Degradation:** Any unplanned outage, systemic latency spike, or operational disruption reported by the Lumen SOC.
* **Prior Compromise Discovery:** Detection of an active, ongoing breach by an unaffiliated third-party threat actor (e.g., existing web shells, ransomware staging).
* **Stakeholder Request:** Explicit "STOP" command issued by the Lumen CISO or SOC Lead.
* **Out-of-Scope Traversals:** Accidental pivoting into unauthorized infrastructure, customer-owned environments, or accessing unencrypted PII/PHI.

## Data Handling
* **Treatment:** Target data encountered during post-exploitation will only be captured as sanitized excerpts or redacted screenshots strictly necessary for proof-of-impact. All sensitive data must be immediately masked in notes and stored exclusively on Vanguard’s AES-256 encrypted drives.
* **Retention Period:** All engagement data, including tool outputs and evidence, will be retained for exactly 30 days post-engagement.
* **Destruction Commitment:** Upon expiration of the retention period, all client data, source code, and credentials will undergo cryptographic erasure (DoD 5220.22-M standard).

## Post-Engagement Obligations
* **Reporting Timeline:** Comprehensive draft report delivered within 5 business days after the conclusion of the testing window.
* **Evidence Retention:** 30 days post-delivery to support findings validation and client queries, followed by complete destruction.
* **Audit Support:** A 14-day consultation window following report delivery to support Lumen's internal remediation and technical clarification for industrial auditors.

## Signatures
* **Client (Lumen Industrial Systems):** ___________________________ Date: __________
* **Consultant (Vanguard Security):** ___________________________ Date: __________
