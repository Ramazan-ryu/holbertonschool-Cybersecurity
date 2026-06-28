## The Rapid Fire: Professional Judgment Drills

### Cluster A: Scope Boundaries

**Vignette 1: The "Direct Dependency" API**
* **CAN you?**: Contractually, this is a gray area. The phrase "direct dependencies" is highly ambiguous and poorly written. Legally, if this API is hosted by a third party (e.g., a payment gateway or managed SaaS), you absolutely cannot test it without their explicit written consent, regardless of the client's scope document.
* **SHOULD you?**: No. You should immediately halt testing of the API. Ambiguity in scope is a primary cause of legal liability. The correct professional action is to pause, contact the client, confirm ownership of the API, and get explicit written authorization with the specific hostname/IP added to an amended scope document before proceeding.

**Vignette 2: The Reachable Dev Server**
* **CAN you?**: No. The signed scope document strictly defines the boundaries as `10.0.1.0/24`. The dev server is at `10.0.2.15`. Contractually, you are not authorized to touch it. Verbal mentions ("we also have a dev environment") hold zero legal weight and do not override the written Statement of Work.
* **SHOULD you?**: No. You should not attempt to access or exploit the dev server. The correct professional action is to document the *finding* that network segmentation is failing (i.e., you can route to the dev subnet from the production subnet), report this routing misconfiguration, and stop there.

**Vignette 3: IDOR and Real PII**
* **CAN you?**: Contractually, testing the application is authorized, and demonstrating impact is a standard part of penetration testing. However, depending on the Rules of Engagement (RoE) and jurisdictional data privacy laws (e.g., GDPR, HIPAA), viewing or extracting real PII may violate data handling clauses or local laws.
* **SHOULD you?**: No. Fully exploiting an IDOR to access real customer PII introduces unnecessary liability and risk to the client. The professional approach is to demonstrate the vulnerability safely. You should create two test accounts under your control and demonstrate that Test Account A can access the records of Test Account B. If that's not possible, extract non-sensitive metadata to prove the flaw, report the vulnerability immediately as critical, and stop exploitation.

---

### Cluster B: Incidental Discoveries

**Vignette 4: The Fraudulent Workstation**
* **CAN you?**: Yes. The workstation is explicitly in scope, and discovering files during authorized post-exploitation is legally and contractually permitted. However, actively investigating financial fraud is outside the scope of a penetration test.
* **SHOULD you?**: This is an ethically and legally complex gray area. You should not ignore the finding, but you must not play investigator or independently report this to law enforcement. The correct professional action is to first check the Rules of Engagement (RoE) for an incidental discovery protocol and immediately consult your own firm's legal counsel. Following their guidance, you should notify the client's designated point of contact that a critical, non-security-related finding requires their attention, without detailing the accusations in the standard technical report.

**Vignette 5: The Prescribing Physician**
* **CAN you?**: Yes. The EHR system is in scope, and you gained access through authorized testing methods. 
* **SHOULD you?**: This carries extreme ethical and healthcare-specific legal complexity, as it may trigger mandatory reporting obligations under healthcare regulations. You must not act as a medical investigator or report this directly to medical boards yourself. You must immediately reference the RoE's discovery protocol and consult your own firm's legal counsel to navigate the specific mandatory reporting laws. Once advised by your legal team, you should formally escalate this to the designated client contact so the hospital can initiate the proper legal and medical response.

---

### Cluster C: Client Communication

**Vignette 6: The Active Compromise**
* **CAN you?**: Contractually, doing so technically violates the strict wording of the RoE, which states findings are delivered at the end. However, almost all standard Master Services Agreements (MSAs) or professional RoEs have (or should have) an "Emergency Escalation" clause overriding this. 
* **SHOULD you?**: Absolutely yes. Professional duty of care supersedes rigid reporting schedules. The client is suffering an active, real-world breach. You must immediately halt testing (to avoid confusing the forensic trail), invoke emergency communication procedures, and alert the client so they can activate their Incident Response team.

**Vignette 7: The Bypassed Project Manager**
* **CAN you?**: No. Contractually, you are bound by the RoE, which explicitly dictates the communication path. Sharing findings with an unauthorized individual—even the CISO—violates the agreed-upon rules.
* **SHOULD you?**: No. You do not know why the RoE was structured this way. The pentest might be an insider threat assessment targeting the IT/Security department, or the board may have mandated strict compartmentalization. The correct action is to politely decline, citing the RoE, and immediately escalate the request to Vanguard leadership (e.g., Sarah) to determine if an official addendum to the RoE should be negotiated.

---

### Cluster D: Engagement Qualification

**Vignette 8: The "Red Team" Startup**
* **CAN you?**: Yes. If Vanguard drafts a proposal for a red team engagement and the CEO signs it, it is a legally binding contract and you are authorized to perform the work.
* **SHOULD you?**: No. Selling a red team engagement to this client is professional negligence. A red team assessment is designed to test a mature organization's *detection and response* capabilities. This startup has no security team and has never had a basic security assessment. A red team will easily compromise them, providing zero actionable strategic value while wasting their budget. You should educate the client on the security maturity model and propose a standard Vulnerability Assessment or foundational Penetration Test instead.
