# Rules of Engagement, Lumen Industrial Systems

## Engagement Metadata
* **Client:** Lumen Industrial Systems
* **Engagement Reference:** LIS-PT-2026Q2
* **Engagement Window:** July 6, 2026 – July 17, 2026
* **Consulting Firm:** Vanguard Security
* **Signing Parties:** Lead Consultant (Vanguard Security) and Chief Information Security Officer (Lumen Industrial Systems)

## Scope

### In Scope
* External-facing corporate web applications and portals explicitly hosted on `*.lumen-industrial.com`.
* Public API endpoints and microservices associated with Lumen's primary industrial management platform.
* External network infrastructure, specifically IP blocks and ASNs statically assigned to Lumen Industrial Systems.

### Out of Scope
* **Customer-deployed gateways and IoT sensors:** *Reasoning:* Lumen cannot authorize testing on assets it does not own or operate. Even if this customer-premises infrastructure is technically reachable from Lumen's environment, it remains strictly out of scope. 
* **Third-party SaaS providers (e.g., AWS management planes, Salesforce):** *Reasoning:* We lack explicit legal authorization and Safe Harbor from these vendors to perform offensive testing on their shared infrastructure.
* **Physical security and Social Engineering (Phishing/Vishing):** *Reasoning:* Expressly excluded to maintain focus on the technical external perimeter and prevent disruption to employee workflows.

## Testing Window
* **Days:** Monday through Friday.
* **Hours:** 09:00 – 17:00 Eastern Standard Time (EST).
* **Blackouts:** No active exploitation or scanning on weekends (Friday 18:00 EST to Monday 08:00 EST) or national holidays. *Reasoning:* Prevents triggering alerts that cause weekend on-call fatigue for Lumen's SOC team.

## Communication and Escalation
* **Primary Contact:** Lumen SOC Manager (Encrypted Signal / Phone) — Expected response time: 15 minutes.
* **Secondary Contact / Escalation Path:** Lumen CISO (Phone) — Expected response time: 1 hour.
* **Channels:** Signal for real-time emergency communication; PGP-encrypted email for daily status debriefs and non-urgent queries.

## Authorised Tools, Forbidden Tools
* **Authorised Tools:** Custom scripting (Python/Go), Nmap, Burp Suite Professional, Amass, Recon-ng, standard OSINT frameworks.
* **Forbidden Tools:** Metasploit Framework (strictly prohibited for initial foothold generation to ensure manual, low-noise exploitation), automated commercial vulnerability scanners (e.g., Nessus, OpenVAS) at high thread counts without explicit, real-time coordination.

## Stop Conditions
Testing will halt immediately and the escalation path will be triggered if any of the following occur:
* Discovery of an ongoing, active compromise by an unauthenticated third-party threat actor.
* Unintended degradation, denial of service, or systemic latency in Lumen production services.
* Accidental discovery or traversal into unlisted, out-of-scope customer environments.
* Accessing unencrypted PII, PHI, or sensitive customer intellectual property (testing halts at proof-of-access).

## Data Handling
* All engagement data, including recon telemetry and vulnerability findings, will be stored exclusively on AES-256 full-disk encrypted hardware.
* Target data encountered during post-exploitation will only be captured as sanitized excerpts or redacted screenshots strictly necessary for proof-of-impact.
* All client data, source code, and credentials will undergo cryptographic erasure (DoD 5220.22-M standard) 30 days post-engagement.

## Post-Engagement Obligations
* **Reporting:** Delivery of the combined Executive Summary and Technical Findings report within 5 business days of the testing window's conclusion.
* **Evidence Retention:** Encrypted retention of raw engagement logs for 30 days to support client queries, followed by complete destruction.
* **Audit Support:** A 14-day support window post-report delivery for technical clarification, debrief calls, and limited remediation validation testing.

## Signatures

**Vanguard Security (Lead Consultant):** ___________________________   **Date:** _______________

**Lumen Industrial Systems (CISO):** ___________________________   **Date:** _______________
