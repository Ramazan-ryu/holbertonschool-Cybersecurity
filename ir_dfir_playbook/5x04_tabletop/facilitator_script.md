# Facilitator Script: Nexus Supply Chain Compromise Tabletop

## Pre-exercise checklist
- [ ] **room setup**: Verify that the physical layout allows clear visibility between all seven core administrative and technical roles.
- [ ] **participant seating**: Ensure table tents are arranged so that technical stakeholders sit directly across from clinical and operational stakeholders to highlight decision friction points.
- [ ] **materials distributed**: Check that physical printouts of the participant guide, background architecture baselines, and tracking logs are physically handed out.
- [ ] **recording**: Initialize the local session data recording stream if applicable and approved by compliance safeguards.
- [ ] **observer briefing**: Confirm that any non-participating room guests have been instructed on non-interference rules.
- [ ] **Timeline tracking**: Ensure a clock or timer is clearly visible to the facilitator to manage inject pacing.

---

## Facilitator ground rules
The facilitator must read these rules aloud verbatim at the start of the exercise to establish structural baseline expectations:

> "Before we review our opening alert telemetry, let us clearly define **what the exercise is** and **what the exercise is not**. This simulation is a dedicated strategic sandbox designed to stress-test our horizontal coordination models, internal communication playbooks, and regulatory alignment under a third-party vendor crisis scenario. This session is not an individual performance audit, a blame-allocation meeting, or a test of personal technical speed.
> 
> Here is how the **injects** work: I will deliver periodic situation updates that reflect the passing of operational time in production. Once an inject is dropped, the room owns the clock to evaluate threat scope and execute coordination workflows.
> 
> My role throughout this simulation is one of absolute **neutrality**. I am here to capture raw data points, document unmitigated cross-system dependencies, and probe your strategic assumptions. I will frequently challenge your decisions with follow-up questions. Do not interpret this as a sign that your action was flawed; I am simply acting as a neutral mirror to uncover hidden trade-offs.
> 
> Please remember that during a distributed software supply chain compromise, there are **no correct answers**. There are only **complete and incomplete responses**. A response is complete when it accurately accounts for downstream clinical care throughput, data verification workflows, legal compliance timelines, and perimeter security actions. An incomplete response is one that optimizes for a single department while leaving other organizational dependencies in a blind spot. Let us begin."

---

## Per-Inject Facilitation

### INJ-00
**Read aloud:**
"The SOC has flagged unusual outbound traffic from the Nexus Patient Scheduling server `SCHED-SVR-01` at Main Campus to 193.42.100.77. The alert fired 45 minutes ago and similar patterns are now being observed on other Nexus agent hosts across MedDefense sites. Patient scheduling operations appear stable and no service disruption is currently visible."

* **Allow:** 10–12 minutes discussion.
* **Probing questions:**
  1. What initial severity level do you assign to this simultaneous cross-site beaconing, and what explicit playbook criteria dictate that choice?
  2. Who is formally notified within our internal leadership tree during the first 15 minutes of investigation?
  3. What specific volatile forensic evidence is required before any disruptive perimeter network containment actions are authorized?
  4. What baseline assumptions are being made by the engineering team regarding the implicit safety of validly signed binaries?
* **Watch for:** Technical teams treating the alert as an isolated malware infection or local host exploit while failing to notice the systemic, simultaneous pattern across multiple clinical environments. If a participant role is not engaging or not participating actively, prompt them directly about clinical workflow dependencies.
* **Transition:** "We have now received critical additional vendor context that changes our baseline assumptions."

---

### INJ-01
**Read aloud:**
"Nexus Health Technologies issues an urgent advisory stating that its build and release pipeline has been compromised. A threat actor accessed the code-signing infrastructure and distributed a malicious update through the automated update channel. All Nexus agents updated within the last 72 hours may be affected. The update is validly signed but now considered untrusted due to vendor compromise. No patch is available."

* **Allow:** 10–15 minutes discussion.
* **Probing questions:**
  1. Do you still trust installed agents and the code running on your active local hosts given that the signature certificate itself is compromised?
  2. Do you shut down scheduling integrations completely, or do you attempt to implement a degraded operational state?
  3. Who has authority to decide on a complete technical shutdown of a core vendor connection?
  4. What is your containment boundary if you cannot differentiate between legitimate vendor transactions and malicious backdoor activity?
* **Watch for:** IT operations hesitating to recommend isolation because the servers appear to be running normally and processing appointments. If any infrastructure role is not engaged, challenge them on network level containment constraints.
* **Transition:** "New telemetry is now arriving from production systems as clinical workflows begin to degrade."

---

### INJ-02
**Read aloud:**
"EDR shows periodic outbound connections from Nexus agents every four hours to unknown infrastructure. Clinical staff report missing appointments, duplicate bookings, and altered schedules affecting patient care across all sites."

* **Allow:** 12–15 minutes discussion.
* **Probing questions:**
  1. Is this now patient safety critical, or does it remain an isolated technical data issue?
  2. Do we isolate immediately to stop data tampering, or do we maintain the connection to preserve clinic registration flow?
  3. What is the worst-case clinical impact if a high-risk surgery or critical outpatient appointment was silently deleted from the database?
  4. How do we validate correct records and identify thousands of appointment modifications made during the compromise window?
* **Watch for:** Clinical managers downplaying the safety risks of scheduling glitches or failing to activate paper-based fallback workflows quickly enough. Ensure non-technical tracks are not participating silently.
* **Transition:** "Legal and compliance context is now introduced to our risk assessment matrix."

---

### INJ-03
**Read aloud:**
"Nexus confirms no breach on their side but acknowledges build pipeline compromise and cannot guarantee integrity of signed updates. Legal reminds the team Nexus is a Business Associate under HIPAA with a 24-hour notification obligation upon discovery of a potential breach."

* **Allow:** 10–12 minutes discussion.
* **Probing questions:**
  1. Do we initiate HIPAA assessment now based on structural exposure, or do we wait for forensic proof of exfiltration?
  2. What triggers notification obligations under our current Business Associate Agreement (BAA)?
  3. What if the vendor is wrong about the scope of their cloud pod breach?
  4. What is our legal exposure if we delay while waiting for vendor forensic confirmation?
* **Watch for:** Legal and compliance representatives refusing to take an active posture and waiting passively for the vendor to issue a formal breach declaration. Watch for unengaged roles in leadership tracks.
* **Transition:** "External pressure is emerging that completely bypasses our planned timeline boundaries."

---

### INJ-04
**Read aloud:**
"A media outlet requests immediate comment regarding a potential vendor supply chain compromise affecting patient scheduling systems. Scope of impact is still unknown."

* **Allow:** 10–12 minutes discussion.
* **Probing questions:**
  1. Do we release a public statement immediately, or do we maintain absolute silence until local forensics are finalized?
  2. Do we name Nexus publicly, or do we refer to them as an anonymous 'third-party IT provider' to protect their identity?
  3. How do we handle external communications without creating contractual liability or violating confidentiality terms of our vendor agreement?
  4. How does this external inquiry alter our timeline for briefing executive leadership and the hospital board?
* **Watch for:** Public relations personnel over-sharing unverified forensic metrics or delaying communications so long that rumors disrupt patient care operations. Check for any participant role not engaging in external risk evaluation.
* **Transition:** "Internal governance demands a definitive synthesis of our operational risk profile."

---

### INJ-05
**Read aloud:**
"The executive board demands a formal executive status brief under extreme pressure, providing only a tight timeline before a critical corporate governance decision must be made regarding ongoing clinical operations."

* **Allow:** 15 minutes discussion.
* **Probing questions:**
  1. What are the top three critical business and clinical risks that the incident commander must communicate to the board during this briefing?
  2. What concrete operational alternatives are available to maintain clinical volume if the primary scheduling application remains offline?
  3. What is the estimated time to recovery (ETR) for achieving a verified, trusted system baseline across all outpatient sites?
  4. What resource or budget authorizations must be unlocked from executive leadership to sustain our emergency operations today?
* **Watch for:** Technical incident leaders overwhelming executive board members with granular log details instead of presenting clear, actionable business choices. Note if any strategic role is not engaged.
* **Transition:** "The immediate tactical crisis begins to clear, revealing a long-term technical roadblock."

---

### INJ-06
**Read aloud:**
"The exercise concludes with a critical technical roadblock. Forensic logs show active backdoor beacons, but because the vendor’s environment is completely opaque to us, we have zero visibility into what specific records were pulled. This leaves a massive open question regarding the exact data exfiltration volume that cannot be cleanly resolved during the exercise."

* **Allow:** 10–12 minutes discussion.
* **Probing questions:**
  1. How do we log, track, and manage a critical capability gap where our data resides inside a multi-tenant cloud provider environment that we do not own?
  2. If the data visibility gap cannot be cleanly resolved today, do we legally assume a total data breach occurred under federal compliance guidelines?
  3. What post-exercise action items must be formally assigned to audit historical queries executed by the `svc-nexus-prod` service principal?
  4. What criteria will our security team use to officially declare this supply chain incident closed when an open question remains regarding data exfiltration?
* **Watch for:** Teams assuming that the threat is entirely mitigated simply because perimeter firewall blocks are successfully dropping active outbound traffic. Ensure technical analysts are not participating in silos.

---

## Wrap-up facilitation
The facilitator will transition the room out of tactical operations mode and guide participants through a structured reflection. This is not a grading session, but rather a dedicated structured reflection. Use these verbatim text identifiers to document findings:

* **what went well**: "Where did our technical monitoring, team notification, and role execution work exactly as designed? What internal processes showed the highest resilience?"
* **what felt uncertain**: "During which specific injects did we experience the most severe analysis paralysis or confusion regarding who owned final decision authority?"
* **what they would change**: "If this exact software supply chain backdoor hit our production servers tomorrow morning, what specific modifications would we immediately make to our current playbooks, escalation parameters, and communication trees?"

---

## Facilitator notes per capability
*The guidance below is restricted solely to private facilitator reference to assist in tracking and assessing organizational maturity against the capability map.*

### CAP-01: Supply Chain Detection (Private Guidance)
- **Focus Area**: Evaluate whether the technical team uncovers the core threat vector by reviewing the residual risk findings from our November 2025 security review (which highlighted that the automated update channel lacks independent client-side hash pinning).
- **Key indicator**: Success requires moving beyond generic malware remediation to address the compromised trust of the validly signed vendor update pipeline.

### CAP-02: Vendor Communication (Private Guidance)
- **Focus Area**: Track whether the team attempts to utilize the formal, 24x7 emergency security channels (+1 512 555 0184 / `security@nexushealth.io`) or if they rely on low-priority account representatives.
- **Key indicator**: Overcoming the operational deficit that a joint tabletop exercise has never been conducted with Nexus prior to this incident.

### CAP-03: Business Continuity Decision (Private Guidance)
- **Focus Area**: Analyze how the room manages the trade-off between shutting down the site-to-site IPsec tunnel and breaking the Epic FHIR R4 integration, which handles approximately 3,500 patient interactions per week across three sites.
- **Key indicator**: The capacity to authorize a controlled degradation of service rather than suffering a complete administrative standstill.

### CAP-04: PHI Exposure Assessment (Private Guidance)
- **Focus Area**: Confirm that the security team audits the specific data fields accessible to the `svc-nexus-prod` service principal to confirm that patient demographic data and insurance data are exposed, while clinical charting is safe.
- **Key indicator**: Recognizing that data integrity modification of appointment records represents a reportable ePHI breach risk under current HIPAA rules.

### CAP-05: HIPAA Notification Posture (Private Guidance)
- **Focus Area**: Ensure the legal team holds Nexus strictly to its BAA requirement to notify MedDefense within 24 hours of discovering a potential security incident involving PHI.
- **Key indicator**: The willingness to trigger regulatory notification workflows based on a high risk of compromise, even in the absence of explicit exfiltration logs.

### CAP-06: Data Integrity Response (Private Guidance)
- **Focus Area**: Look for the implementation of a data reconciliation plan that utilizes Epic transaction history logs to identify every schedule modification made during the three-day compromise window.
- **Key indicator**: Refusing to declare the infrastructure safe until the accuracy of patient care appointments has been clinically verified.

### CAP-07: Crisis Communications (Private Guidance)
- **Focus Area**: Assess the corporate communications team's ability to navigate external media pressure while strictly respecting the non-disclosure boundaries built into our active vendor contract.
- **Key indicator**: Maintaining public trust across all three clinical sites without exposing internal forensic blind spots.

### CAP-08: Executive Briefing Under Pressure (Private Guidance)
- **Focus Area**: Grade the incident commander's capacity to deliver a comprehensive status summary to the hospital board under tight timeline constraints.
- **Key indicator**: Translating raw technical EDR indicators into clear, actionable governance alternatives regarding clinical continuity and regulatory exposure.
