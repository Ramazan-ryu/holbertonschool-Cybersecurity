# Participant Guide: Nexus Supply Chain Compromise Tabletop

**Exercise date:** 2026-06-03  
**Classification:** Internal - Exercise Use Only  

---

## How this exercise works

This is a tabletop exercise. You will receive situation updates from the facilitator. You respond as you would in a real incident. The facilitator may probe decisions and challenge assumptions. The goal is not correctness, but to identify where coordination, authority, and decision-making break under pressure.

---

## James Chen - SOC Lead

**Exercise decisions you own:**
- Incident detection interpretation and declaration
- Initial severity classification
- Evidence collection and technical escalation

**Information you receive directly:**
- EDR alerts from Nexus Patient Scheduling servers
- Network telemetry and outbound connection data
- SIEM security logs showing system dependency metrics

**Success looks like:**
- Incident declared quickly with clear reasoning
- Vendor compromise hypothesis raised early
- Evidence preserved before containment actions disrupt systems

**Failure mode to watch for:**
- Treating this as routine malware and missing the supply chain compromise signal

---

## Sarah Park - IT Director

**Exercise decisions you own:**
- System isolation and shutdown decisions
- Rollback and recovery actions for Nexus integration
- Operational continuity decisions for scheduling systems

**Information you receive directly:**
- System availability dashboards showing the active Epic integration topology
- Infrastructure status across all three sites
- Reports from Infrastructure Lead (Robert Kim)

**Success looks like:**
- Makes timely containment decisions even under uncertainty
- Balances uptime with patient scheduling continuity risk
- Clearly documents operational impact decisions

**Failure mode to watch for:**
- Delaying containment because systems appear operational

---

## Dr. Patricia Morales - CISO

**Exercise decisions you own:**
- Security strategy during vendor compromise
- Risk acceptance decisions
- Final arbitration in security vs operations conflicts

**Information you receive directly:**
- SOC and IT incident summaries
- Vendor risk history and prior Nexus findings
- Executive-level incident updates

**Success looks like:**
- Identifies supply chain trust failure early
- Forces alignment across legal, clinical, and IT
- Prevents fragmented decision-making

**Failure mode to watch for:**
- Remaining passive while teams make inconsistent containment decisions

---

## Helena Reyes - General Counsel

**Exercise decisions you own:**
- HIPAA breach risk assessment initiation
- Business Associate Agreement interpretation
- Approval of external communications from legal perspective

**Information you receive directly:**
- Business Associate Agreement (BAA) obligations and compliance timelines
- Nexus vendor contact roster and legal escalation channels (`legal@nexushealth.io`)
- Draft incident summaries

**Success looks like:**
- Initiates HIPAA assessment based on suspicion, not confirmation
- Applies BA obligations correctly under uncertainty
- Ensures compliance decisions are timely

**Failure mode to watch for:**
- Waiting for confirmed breach before taking legal action

---

## Marcus Webb - Communications Director

**Exercise decisions you own:**
- External communication strategy
- Media response approval
- Internal vs external messaging alignment

**Information you receive directly:**
- Media inquiries and public relations outreach
- Legal-approved constraints and BAA confidentiality terms
- Executive summaries and primary vendor contact communication details

**Success looks like:**
- Issues controlled holding statements under pressure
- Avoids speculation in public communication
- Maintains alignment with Legal and Executive teams

**Failure mode to watch for:**
- Over-sharing unverified technical details or delaying too long

---

## Robert Kim - Infrastructure Lead

**Exercise decisions you own:**
- Technical containment execution
- Rollback feasibility decisions
- Infrastructure stability during response actions

**Information you receive directly:**
- Server and network logs from all affected hosts
- Integration health status and system dependency baselines between Nexus and Epic
- Deployment and configuration state of the site-to-site IPsec tunnel

**Success looks like:**
- Executes requested isolation protocols with zero unintended technical fallout
- Maps system dependency links to identify safe segregation boundaries
- Restores trusted core states during recovery phases safely

**Failure mode to watch for:**
- Destroying critical forensic evidence or volatile memory by impulsively rebooting systems to speed up restoration

---

## Clinical Director Representative

**Exercise decisions you own:**
- Patient care workflow survival modifications
- Downtime procedure activation thresholds
- Patient safety risk acceptance inside the clinics

**Information you receive directly:**
- Clinical throughput impacts across all three sites
- Front-line reports regarding missing or modified appointment data and scheduling errors
- Patient care status and safety dashboard feeds

**Success looks like:**
- Rapidly institutes manual scheduling fallbacks to keep clinics functioning safely
- Quantifies patient safety trade-offs clearly to the Incident Commander
- Prioritizes data verification workflows for critical care appointments

**Failure mode to watch for:**
- Refusing to allow integration shutdown despite clear evidence of active data corruption, prioritizing operational metrics over data safety

---

## Observer guidance

Thank you for attending this exercise as an observer. Your role is vital for capturing systemic observations during the hotwash, but you must respect the following rules:

- **Observers do not speak:** To preserve the realism and stress constraints of the simulation, observers must not participate, offer advice, or speak during the active session.
- **Focus on team dynamics:** Watch how information is communicated between the technical teams and administrative leaders, noting any structural delays or visibility silos.
