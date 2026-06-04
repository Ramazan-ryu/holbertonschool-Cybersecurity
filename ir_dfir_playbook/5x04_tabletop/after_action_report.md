# After-Action Report: Nexus Supply Chain Compromise Tabletop

**Exercise date:** 2026-05-29
**Report date:** 2026-05-29
**Facilitator:** SOC Training Simulation Engine (ChatGPT)
**Participants:** James Chen, Sarah Park, Dr. Patricia Morales, Helena Reyes, Marcus Webb, Robert Kim, Clinical Director Representative
**Classification:** Internal

---

## Executive summary

The Nexus Supply Chain Compromise Tabletop Exercise evaluated MedDefense Health’s ability to respond to a healthcare-focused software supply-chain compromise involving the Nexus patient scheduling platform. The exercise tested incident declaration, vendor trust evaluation, clinical coordination, legal escalation, communications management, containment authority, and emergency remediation governance under active operational pressure.

Participants demonstrated strong cross-functional engagement during early incident triage and consistently escalated technical concerns into business, legal, and patient-safety discussions. Security and infrastructure teams effectively identified supply-chain compromise indicators, while Legal and Communications personnel appropriately integrated HIPAA, Business Associate, and public disclosure considerations into the response process.

The most significant gaps identified during the exercise involved unclear incident command authority, insufficient downtime operational procedures for scheduling disruption, and the absence of formal vendor remediation validation controls during emergency patch deployment scenarios. Multiple participants expressed uncertainty regarding who possessed final authority to isolate enterprise scheduling systems and whether emergency vendor patches could be trusted during an active compromise.

The single highest-priority recommendation is to establish a formal vendor compromise response governance model that defines isolation authority, emergency change-control requirements, vendor trust validation procedures, and clinical downtime escalation criteria for critical healthcare systems.

---

## Findings table

| Finding ID | Inject | Capability Tested                   | Gap Description                                                                                                                       | Severity | Recommended Action                                                                                  | Owner Role              | Deadline | Validation Method                             |
| ---------- | ------ | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------- | ----------------------- | -------- | --------------------------------------------- |
| F-001      | INJ-01 | CAP-02 Vendor Trust & Isolation     | No clearly defined authority existed for isolating a critical vendor-operated healthcare platform during active compromise conditions | P1       | Add vendor isolation authority matrix and escalation ownership to incident response playbooks       | IT Director             | 21 days  | Playbook review and tabletop retest           |
| F-002      | INJ-02 | CAP-06 Clinical Safety Coordination | No predefined patient-safety shutdown threshold existed for corrupted scheduling data                                                 | P1       | Create patient-safety escalation criteria for scheduling integrity failures                         | Clinical Director       | 30 days  | Clinical review and operational walkthrough   |
| F-003      | INJ-04 | CAP-04 Downtime Operations          | Manual scheduling and degraded-mode workflows were incomplete and inconsistently understood                                           | P1       | Develop formal downtime scheduling procedures and train clinical operations teams                   | Operations Director     | 45 days  | Downtime exercise validation                  |
| F-004      | INJ-06 | CAP-07 Remediation Governance       | Emergency vendor patch validation and rollback procedures were not formally documented                                                | P1       | Implement emergency remediation governance process with staged validation and rollback requirements | Infrastructure Lead     | 30 days  | Change-management review and patch simulation |
| F-005      | INJ-03 | CAP-05 Legal & Compliance           | Teams lacked shared understanding of breach-reporting thresholds for supply-chain signing compromise                                  | P2       | Publish legal guidance for Business Associate compromise interpretation scenarios                   | General Counsel         | 30 days  | Legal review acknowledgment                   |
| F-006      | INJ-05 | CAP-03 Crisis Communications        | Public communications approval workflow was not formally documented                                                                   | P2       | Define executive communications approval process for cyber incidents                                | Communications Director | 21 days  | Communications workflow review                |
| F-007      | INJ-00 | CAP-01 Initial Triage               | Initial responders showed bias toward endpoint malware instead of vendor compromise scenarios                                         | P3       | Add supply-chain compromise indicators to SOC triage checklist                                      | SOC Lead                | 14 days  | SOC checklist audit                           |
| F-008      | INJ-02 | CAP-06 Business Continuity          | Operational leaders lacked agreed prioritization model for partial isolation decisions                                                | P2       | Define continuity prioritization guidance for healthcare scheduling systems                         | IT Director             | 30 days  | Tabletop validation                           |
| F-009      | INJ-04 | CAP-07 Vendor Risk Management       | Vendor remediation trust decisions relied on ad hoc discussion rather than structured validation criteria                             | P2       | Create vendor remediation trust-validation checklist                                                | CISO                    | 30 days  | Governance review and exercise retest         |

---

## P1 Finding narratives

### F-001: No defined authority for vendor system isolation

During INJ-01, participants debated whether to isolate the Nexus integration environment after confirmation of a vendor code-signing compromise. Sarah Park proposed immediate isolation, while Dr. Patricia Morales requested executive-level validation before operational shutdown occurred. The discussion revealed uncertainty regarding who possessed final authority to disable critical healthcare scheduling systems during a live supply-chain compromise. This gap matters because delayed isolation decisions during healthcare incidents can increase both compromise spread and patient-safety exposure. MedDefense Health should update its incident response governance model to explicitly define isolation authority, executive escalation requirements, and operational approval thresholds for vendor-operated healthcare platforms.

### F-002: No patient-safety shutdown threshold for corrupted scheduling data

During INJ-02, the Clinical Director identified risks involving delayed oncology treatments, duplicate medication administration, and incorrect patient scheduling caused by corrupted appointment records. Despite recognition of patient impact, participants could not identify a predefined threshold for when scheduling integrity failures required full operational shutdown. This gap increases the likelihood of inconsistent emergency decisions during high-pressure clinical incidents. MedDefense Health should establish formal patient-safety escalation criteria tied to scheduling corruption severity, including mandatory shutdown triggers, escalation timelines, and clinical approval workflows.

### F-003: Downtime scheduling procedures were incomplete

During INJ-04, participants discussed manual scheduling fallback operations after ongoing appointment corruption and potential full system isolation. Multiple teams acknowledged that downtime workflows were poorly documented and inconsistently understood across hospital sites. The absence of mature degraded-mode operations increases operational disruption risk during healthcare cyber incidents and may directly impact patient care continuity. MedDefense Health should create standardized downtime scheduling playbooks, conduct staff training exercises, and validate manual scheduling workflows through operational simulations.

### F-004: Emergency patch governance controls were insufficient

During INJ-06, Nexus released an emergency remediation patch while independent researchers questioned the integrity of the update. Participants recognized the need for isolated testing and change-control review but could not reference a documented emergency remediation governance process. This gap creates risk of deploying untrusted vendor code into already compromised healthcare environments. MedDefense Health should implement formal emergency patch governance procedures that require staged testing, integrity validation, rollback planning, and executive approval before deployment into production systems.

---

## What worked

* James Chen rapidly established incident command discipline during INJ-00 by verbally declaring a SEV2 incident, assigning evidence preservation actions, and escalating supply-chain concerns early in the response timeline.

* Helena Reyes consistently integrated Business Associate, HIPAA, and legal exposure considerations into operational decision-making throughout the exercise, particularly during INJ-03 and INJ-05.

* The Clinical Director effectively translated technical scheduling corruption into real patient-care consequences during INJ-02, helping the exercise move beyond purely technical incident handling into healthcare operational risk management.

---

## Exercise design feedback

### DF-01: Earlier patient-safety escalation

The original inject timeline delayed healthcare operational impact until later stages of the scenario. Appointment corruption indicators were moved earlier into the exercise flow so clinical risk could influence containment decisions sooner.

### DF-02: Expanded governance pressure

The exercise design was updated to include more explicit governance conflicts involving isolation authority, executive approval, and vendor trust decisions in order to better simulate real healthcare crisis escalation.

### DF-03: Improved downtime realism

Additional degraded-mode operational discussion prompts were added after simulation revealed weak manual scheduling familiarity among participants.

### DF-04: More realistic communications pressure

Media engagement was expanded to include frontline staff pressure, patient concerns, and hospital administrator escalation rather than relying only on external press inquiries.

### DF-05: Stronger remediation decision testing

The remediation phase was expanded to test emergency patch governance, rollback planning, and integrity validation under active compromise conditions.

