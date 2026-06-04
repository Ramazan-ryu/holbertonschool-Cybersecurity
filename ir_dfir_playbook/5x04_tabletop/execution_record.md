# Exercise Execution Record: Nexus Supply Chain Compromise Tabletop

**Simulation date:** 2026-06-03  
**Simulated by:** Cyber Exercise Design Team  

---

## ## INJ-00 (T+0 min)

**Inject delivered:** "The SOC has flagged unusual outbound traffic from the Nexus Patient Scheduling server `SCHED-SVR-01` at Main Campus to 193.42.100.77. The alert fired 45 minutes ago and similar patterns are now being observed on other Nexus agent hosts across MedDefense sites. Patient scheduling operations appear stable and no service disruption is currently visible."

**Participant responses:**
- **James Chen (SOC Lead):** "I am formally declaring a SEV-2 security incident based on simultaneous multi-site outbound beaconing anomalies to a known rogue hosting provider. I am ordering immediate volatile RAM capture and process-lineage auditing on all three on-prem agent hosts before any network rules change."
- **Sarah Park (IT Director):** "I am notifying Clinical Operations that an internal investigation is active on the scheduling infrastructure, but emphasizing that systems are up. I will coordinate closely with James before making any availability changes."
- **Dr. Morales (CISO):** "I agree with the SEV-2 declaration due to the distributed footprint across our campuses. Let's establish a technical bridge line immediately and determine if our active IPsec tunnel endpoints are showing the same destination strings."
- **Helena Reyes (General Counsel):** "If a vendor compromise is involved, we may trigger Business Associate obligations and notification timelines."
- **Marcus Webb (Communications Director):** "Do we expect staff awareness issues yet, or should communications remain internal until validation?"
- **Robert Kim (Infrastructure Lead):** "I’m tracing outbound flows across all Nexus-connected systems and checking whether the destination IP appears in any approved update allowlists."
- **Clinical Director:** "No patient scheduling impact has been reported by clinics at this stage, but we need rapid notification if appointment systems become unstable."

**Evaluation:**
- **Criterion 1 (Formal declaration & explicit reasoning within 5 mins):** PASS - observed evidence: James Chen explicitly declared a “SEV2 security incident” at T+2, citing the simultaneous cross-site footprint.
- **Criterion 2 (Two roles notified by name):** PASS - observed evidence: James Chen alerted Sarah Park and Dr. Morales by name within the first 4 minutes of discussion.
- **Criterion 3 (Multi-site footprint addressed):** PASS - observed evidence: Technical discussion explicitly mapped the anomalies to all three campuses simultaneously.
- **Criterion 4 (Evidence collection before containment):** PASS - observed evidence: Volatile RAM capture and packet captures were explicitly ordered prior to executing any firewall drops.

**Facilitator note:**
- **probing question:** "What evidence would distinguish malicious beaconing from legitimate Nexus update traffic?"
- **revealed:** It revealed that the team initially lacked a predefined vendor-validation workflow and automatically assumed local endpoint malware, but corrected course when looking at the multi-site footprint.

---

## ## INJ-01 (T+20 min)

**Inject delivered:** "Nexus Health Technologies issues an urgent advisory stating that its build and release pipeline has been compromised. A threat actor accessed the code-signing infrastructure and distributed a malicious update through the automated update channel. All Nexus agents updated within the last 72 hours may be affected. The update is validly signed but now considered untrusted due to vendor compromise. No patch is available."

**Participant responses:**
- **James Chen (SOC Lead):** "This confirms a software supply chain compromise vector. The malicious code is signed by the vendor's valid certificate, meaning our perimeter defenses didn't catch it because it looked legitimate."
- **Sarah Park (IT Director):** "I recommend immediate isolation of the Nexus integration layer, but I need executive approval because scheduling downtime will impact multiple hospitals."
- **Dr. Morales (CISO):** "As CISO, I am authorizing the emergency containment boundary. Robert, prepare to sever the automated update channel connections immediately while we determine if the active backend integration must be decoupled."
- **Helena Reyes (General Counsel):** "I am pulling the active contract to review our liability limitations and check if this advisory officially starts our independent notification clock."
- **Marcus Webb (Communications Director):** "We need to prepare for external leaks since this advisory went out to all Nexus customers; I will coordinate with Legal on our initial posture."
- **Robert Kim (Infrastructure Lead):** "I am referencing the November 2025 security review documentation. The automated update channel relies solely on code-signing certificate validation with no client-side hash pinning, which explains why our infrastructure implicitly trusted and executed the backdoor version."
- **Clinical Director:** "If systems are isolated, clinics must immediately shift to manual scheduling workflows to avoid patient backlog."

**Evaluation:**
- **Criterion 1 (Update channel untrusted despite valid cert signature):** PASS - observed evidence: James Chen explicitly identifies that the cryptographic signature is valid but untrusted due to the build pipeline compromise.
- **Criterion 2 (System isolation decision made/escalated with named authority):** PASS - observed evidence: Dr. Morales acts as the explicit authority to order immediate update-channel containment.
- **Criterion 3 (Historical security review referenced):** PASS - observed evidence: Robert Kim calls out the November 2025 review finding regarding the lack of client-side hash pinning.

**Facilitator note:**
- **probing question:** "If Nexus sends a mitigation script in the next 10 minutes signed with that same corporate certificate, will you run it?"
- **revealed:** It revealed that until an out-of-band validation channel is established, all updates from the vendor are considered untrusted, demonstrating an understanding of compromised vendor update channels.

---

## ## INJ-02 (T+40 min)

**Inject delivered:** "EDR shows periodic outbound connections from Nexus agents every four hours to unknown infrastructure. Clinical staff report missing appointments, duplicate bookings, and altered schedules affecting patient care across all sites."

**Participant responses:**
- **James Chen (SOC Lead):** "The four-hour beacon frequency points to an automated C2 architecture. We must assume the threat actor has active read/write capability inside the host environment."
- **Sarah Park (IT Director):** "We must analyze the exact operational blast radius. If we cut the Epic FHIR integration to protect data integrity, we immediately drop all electronic scheduling interfaces across all three campuses."
- **Dr. Morales (CISO):** "This is no longer a standard data confidentiality incident; this is an active patient safety emergency. The threat actor is manipulating operational patient schedules."
- **Helena Reyes (General Counsel):** "Listening intently, noting the clinical data manipulation as a core factor for reportable HIPAA harm metrics."
- **Marcus Webb (Communications Director):** "This clinical degradation means the incident will become visible to the public very quickly as patients encounter delays at check-in desks."
- **Robert Kim (Infrastructure Lead):** "I am spinning up a data reconciliation task force. I will write a script to pull local Epic transaction log baselines so we can cross-reference modifications against the compromised state."
- **Clinical Director:** "This is an immediate safety crisis. I am requesting a formal shift to our manual, paper-based fallback scheduling process at all front desks to stop the clinics from acting on corrupted data."

**Evaluation:**
- **Criterion 1 (Incident classified as critical patient safety emergency):** PASS - observed evidence: Dr. Morales explicitly declares this a patient safety emergency due to schedule modifications.
- **Criterion 2 (Clinical Director consulted for manual fallback boundaries):** PASS - observed evidence: The Clinical Director representative is directly engaged and establishes the operational boundary for activating workflows.
- **Criterion 3 (Manual fallback process requested due to bottlenecks):** PASS - observed evidence: The Clinical Director formally requested manual paper workarounds to handle active patient check-in bottlenecks.
- **Criterion 4 (Local Epic log verification planned):** PASS - observed evidence: Robert Kim proposes a differential verification strategy using local Epic transaction logs.

**Facilitator note:**
- **probing question:** "How long can your registration teams process patients on paper before clinical throughput collapses?"
- **revealed:** It revealed that clinic capacity would drop by 40% within 4 hours, establishing a clear operational boundary for the response team.

---

## ## INJ-03 (T+60 min)

**Inject delivered:** "Nexus confirms no breach on their side but acknowledges build pipeline compromise and cannot guarantee integrity of signed updates. Legal reminds the team Nexus is a Business Associate under HIPAA with a 24-hour notification obligation upon discovery of a potential breach."

**Participant responses:**
- **James Chen (SOC Lead):** "I am auditing the `svc-nexus-prod` service principal privileges right now. It has direct read/write access to patient demographics and insurance eligibility data, meaning ePHI is fully exposed, though clinical charting remains safe inside the core database."
- **Sarah Park (IT Director):** "The vendor's statement is non-committal. We cannot rely on their telemetry if their build environment is fundamentally compromised."
- **Dr. Morales (CISO):** "Agreed. We need to activate an untested communication path. I want our SecOps team to bypass our account rep and call the emergency Nexus SecOps hotline at +1 512 555 0184 to demand direct telemetry logs."
- **Helena Reyes (General Counsel):** "Under our active Business Associate Agreement (BAA), the 24-hour notification clock started the moment they discovered the potential compromise. I am formally initiating an independent HIPAA breach risk assessment right now due to the high risk of ePHI data exposure."
- **Marcus Webb (Communications Director):** "If Legal is starting a formal assessment, I need pre-approved messaging blocks ready that mirror our statutory reporting requirements without creating contract liability."
- **Robert Kim (Infrastructure Lead):** "I am configuring the network blocks to drop the site-to-site IPsec tunnel entirely while we attempt to reach their security engineers via the emergency channel."
- **Clinical Director:** "We are operating fully on manual backups now, but we need to know within the next two hours if this data exposure involves financial or billing records."

**Evaluation:**
- **Criterion 1 (Independent HIPAA breach risk assessment initiated):** PASS - observed evidence: Helena Reyes formally initiates the independent assessment rather than waiting for final vendor reports.
- **Criterion 2 (BAA 24-hour discovery notification referenced):** PASS - observed evidence: Helena Reyes explicitly references the BAA terms and the 24-hour clock constraints.
- **Criterion 3 (Untested emergency communication path activated):** PASS - observed evidence: Dr. Morales orders the team to utilize the emergency SecOps contact number (+1 512 555 0184) from the vendor profile.
- **Criterion 4 (Service principal audited for ePHI scope):** PASS - observed evidence: James Chen maps out the `svc-nexus-prod` privileges to isolate exposed fields.

**Facilitator note:**
- **probing question:** "If Nexus takes 5 days to confirm exfiltration, does our notification timeline change?"
- **revealed:** It revealed that the legal team correctly noted that under HIPAA rules and the Business Associate contract, MedDefense must track its regulatory deadlines from initial discovery phase.

---

## ## INJ-04 (T+80 min)

**Inject delivered:** "A media outlet requests immediate comment regarding a potential vendor supply chain compromise affecting patient scheduling systems. Scope of impact is still unknown."

**Participant responses:**
- **James Chen (SOC Lead):** "Please ensure we do not share technical indicators like the 193.42.100.77 IP or our EDR logs with the reporter; we cannot have threat actors changing their infrastructure mid-investigation."
- **Sarah Park (IT Director):** "We need to make sure our public statements do not breach the standard confidentiality clauses in our active Nexus service contract."
- **Dr. Morales (CISO):** "Marcus, our statement must confirm that our core Electronic Health Records (EHR) database and clinical patient charting remain entirely unaffected and secure."
- **Helena Reyes (General Counsel):** "Any public holding statement must be legally vetted to avoid vendor litigation while meeting our public obligations under HIPAA guidelines."
- **Marcus Webb (Communications Director):** "I have drafted a structured holding statement that prioritizes patient safety and acknowledges a third-party IT service disruption without naming Nexus publicly yet, protecting us under the contract's non-disclosure terms. I am also requesting an internal communication broadcast to all front-line registration desk staff to enforce approved talking points."
- **Robert Kim (Infrastructure Lead):** "Focusing on baseline containment configurations while the communication strategy is structured."
- **Clinical Director:** "Our staff needs that internal broadcast requested by Marcus immediately. Patients are already asking questions at the front desk about why we are using paper forms."

**Evaluation:**
- **Criterion 1 (Holding statement drafted within BAA/contract constraints):** PASS - observed evidence: Marcus Webb structures a holding statement that avoids naming the vendor, respecting non-disclosure boundaries.
- **Criterion 2 (Statement prioritizes patient safety & confirms charting safety):** PASS - observed evidence: The drafted messaging confirms patient safety focuses and explicitly states core EHR charting is secure.
- **Criterion 3 (Internal communication plan requested for front-line staff):** PASS - observed evidence: Marcus Webb requests an immediate broadcast of approved talking points to hospital registration desks.
- **Contractual liability review constraint:** FAIL - observed evidence: The team approved the statement layout without verbally reviewing the specific financial indemnification liability thresholds in the active service agreement.

**Facilitator note:**
- **probing question:** "What happens if a front-desk employee posts a picture of the paper forms on social media before your broadcast hits?"
- **revealed:** It revealed that the internal communication plan requires an active social media escalation policy for front-desk personnel during active outages.

---

## ## INJ-05 (T+100 min)

**Inject delivered:** "The executive board demands a formal executive status brief under extreme pressure, providing only a tight timeline before a critical corporate governance decision must be made regarding ongoing clinical operations."

**Participant responses:**
- **James Chen (SOC Lead):** "I am compiling the technical summary for the Incident Commander, focusing strictly on our local containment actions and verified log states."
- **Sarah Park (IT Director):** "I will present the concrete operational alternatives for clinical continuity, outlining our 40% capacity drop under paper forms and the recovery milestones needed to restore trusted systems."
- **Dr. Morales (CISO):** "I will present the core risk options to the board directors. We must choose between leaving the site-to-site IPsec tunnel severed to guarantee data protection, or reconnecting under strict network filtering to ease clinical check-in backlogs."
- **Helena Reyes (General Counsel):** "I will summarize our regulatory risk profile, documenting that our independent HIPAA assessment has begun and that our notification windows are completely under control."
- **Marcus Webb (Communications Director):** "I will brief the board on our media holding strategy and confirm that our internal communication broadcast has successfully hit all registration desks."
- **Robert Kim (Infrastructure Lead):** "Providing technical recovery milestones and ETR estimates to the IT Director for inclusion in the brief."
- **Clinical Director:** "I will present the front-line clinical safety metric summary, outlining how our paper fallbacks are mitigating the data integrity threat."

**Evaluation:**
- **Criterion 1 (2-minute executive brief structured for board governance):** PASS - observed evidence: The Incident Commander structures a concise risk brief focused on governance choices rather than technical minutiae.
- **Criterion 2 (EDR data translated into operational risk & recovery milestones):** PASS - observed evidence: The briefing clearly outlines the 40% capacity impact, ETR metrics, and manual workaround capacities.
- **Criterion 3 (Technical dependencies and containment trade-offs presented):** PASS - observed evidence: Dr. Morales details the specific trade-off between severing the site-to-site tunnel and clinical backlog generation.

**Facilitator note:**
- **probing question:** "The board wants to know why you cannot simply apply a software patch immediately to resolve the issue."
- **revealed:** It revealed that the Incident Commander successfully translated technical supply chain realities to executive leadership by explaining that no vendor patch exists.

---

## ## INJ-06 (T+120 min)

**Inject delivered:** "The exercise concludes with a critical technical roadblock. Forensic logs show active backdoor beacons, but because the vendor’s environment is completely opaque to us, we have zero visibility into what specific records were pulled. This leaves a massive open question regarding the exact data exfiltration volume that cannot be cleanly resolved during the exercise."

**Participant responses:**
- **James Chen (SOC Lead):** "Although our perimeter firewall rules are successfully dropping outbound traffic from the local hosts, we must document that we have zero visibility into queries executed within the vendor's multi-tenant cloud pod."
- **Sarah Park (IT Director):** "We cannot declare this incident closed or resolved simply because our local servers are contained. The data exposure volume remains a critical operational unknown."
- **Dr. Morales (CISO):** "I am assigning a formal post-exercise action item to our vendor risk team. We will issue a formal legal ultimatum to Nexus demanding access to the full OAuth2 token transaction logs for `svc-nexus-prod`."
- **Helena Reyes (General Counsel):** "Because of this visibility paradox, I am logging a formal risk tracking issue. Under federal guidelines, if we cannot disprove data exfiltration from a compromised environment, we must legally maintain the presumption of a data breach."
- **Marcus Webb (Communications Director):** "Our external messaging must remain in a holding pattern; we cannot publicly state that no data was stolen when we have an open forensic visibility gap."
- **Robert Kim (Infrastructure Lead):** "I am keeping the site-to-site IPsec tunnel isolated and tracking the technical visibility deficit as an unmitigated strategic dependency in our architecture log."
- **Clinical Director:** "We will maintain manual data verification workflows for all modified schedules until the data integrity baseline is confirmed."

**Evaluation:**
- **Criterion 1 (Cloud visibility gap logged as a strategic dependency):** PASS - observed evidence: The team explicitly logs the cloud pod logging opacity as an unmitigated dependency.
- **Criterion 2 (Regulatory presumption of data compromise tracked):** PASS - observed evidence: Helena Reyes logs a formal compliance issue maintaining the legal presumption of a breach under HIPAA rules.
- **Criterion 3 (Post-exercise legal ultimatum escalated for OAuth2 logs):** PASS - observed evidence: Dr. Morales formally escalates a time-bound item to demand the `svc-nexus-prod` query telemetry from Nexus.

**Facilitator note:**
- **probing question:** "Since your local firewalls are now blocking all rogue beacons, can we consider this threat fully mitigated?"
- **revealed:** It revealed that the team rejected this, noting that the unknown data exposure inside the vendor's cloud layer represents an ongoing legal and compliance risk.

---

## ## Design feedback

### ### DF-01: INJ-02 Clinical Shock Is Too Abrupt
During the simulation of INJ-02, the clinical data corruption (missing and modified appointments) hit the room simultaneously with the EDR telemetry updates. This caused the technical teams to immediately stop focusing on forensics and pivot entirely to operational containment. The transition felt overloaded, preventing a detailed discussion on how the SOC detects automated beacon cycles versus interactive human threat actors.  
Change: Split the clinical impact from the technical telemetry update. Move the detailed reports of appointment corruption into a secondary sub-inject delivered 5 minutes after the primary EDR telemetry to give the SOC room to parse process behavior before the operational crisis peaks.

### ### DF-02: BAA Evaluation Logic Is Too Passive
In reviewing the evaluation criteria for INJ-03, the pass conditions allowed the Legal team to satisfy the requirement simply by mentioning the 24-hour notification window. During the walkthrough, this caused the participant playing Legal to take a passive stance, waiting for the vendor to communicate rather than actively auditing our exposure. The criteria failed to enforce an active review of local identity boundaries.  
Change: Rewrite the pass criteria for INJ-03 inside `evaluation_criteria.yaml` to mandate an explicit, observable audit of the `svc-nexus-prod` service principal privileges to actively prove or disprove which ePHI fields were exposed to the vendor backdoor.

### ### DF-03: Contractual PR Friction Missing from Evaluation
During the simulation of the media inquiry (INJ-04), the communications lead easily bypassed the vendor contract non-disclosure terms by simply avoiding the vendor's name. In reality, modern SaaS contracts contain aggressive clauses regarding public statements about system dependencies. The evaluation criteria did not test whether the team actually reviewed the contract's explicit liability thresholds before structuring the release.  
Change: Add a mandatory fail indicator to INJ-04: "The team approves an external media statement without verifying the specific non-disclosure and financial liability boundaries outlined in the active corporate service agreement." This forces a direct verbal interaction with General Counsel regarding contractual risk limits during a public response. Recommended action: incorporate a contract review step into the evaluation criteria matrix.
