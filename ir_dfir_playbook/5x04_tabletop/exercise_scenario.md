# Tabletop Exercise: Nexus Supply Chain Compromise

**Date:** June 3, 2026  
**Classification:** Internal - Exercise Use Only  
**Facilitator:** Dr. Patricia Morales  
**Scenario Version:** 1.2  

---

## Organization background

MedDefense is a healthcare provider operating three outpatient sites: West Campus, Main Campus, and North Site. The organization delivers high-volume ambulatory care services and manages thousands of patient interactions each week, processing approximately 3,500 patient-facing interactions weekly. A critical dependency across all sites is a centralized patient scheduling system, which governs appointment booking, pre-registration, and insurance eligibility workflows. As a HIPAA-covered entity, MedDefense is responsible for maintaining continuity of care while protecting patient information, specifically electronic Protected Health Information (ePHI).

---

## Vendor background

Nexus Patient Scheduling is a third-party multi-tenant SaaS and hybrid platform used by MedDefense for outpatient scheduling, appointment management, and pre-registration workflows across all clinical sites. The platform processes sensitive data including patient demographics, appointment data, and staff rostering, which constitute protected health information (PHI) under HIPAA. 

The platform features a tight Epic integration, interacting with MedDefense’s electronic health record system using HL7 FHIR R4 APIs over HTTPS. Data flows outbound from MedDefense (demographics, eligibility queries) and inbound to MedDefense (confirmed appointments, automated schedule updates) over a secure site-to-site IPsec tunnel. 

Nexus operates under a Business Associate Agreement (BAA) and a strict SLA. As a Business Associate, Nexus has a key BAA obligation to notify MedDefense within 24 hours of discovering any potential security incident involving PHI. Nexus also distributes automated, digitally signed software updates to on-premises Nexus agent hosts deployed at MedDefense sites. These updates are signed with a corporate code-signing certificate ("Nexus Health Technologies, Inc.") and are implicitly trusted by the system.

---

## Opening situation

Exactly **three days ago**, Nexus Patient Scheduling experienced a supply chain compromise affecting its software **build infrastructure**. A **threat actor** successfully inserted malicious logic into a legitimate software update pipeline. The resulting **signed malicious update** was distributed **automatically** to all customer environments. 

This malicious **backdoor** has been running silently on MedDefense's Nexus agent hosts across **all three sites** since deployment:
* `SCHED-SVR-01` (Main Campus)
* `SCHED-SVR-02` (West Campus)
* `SCHED-SVR-03` (North Site)

Today, exactly **45 minutes ago**, the Security Operations Center (SOC) flagged unusual outbound traffic from the scheduling server to an **unknown external IP** address.

---

## Known facts

At the start of this exercise, participants are provided with the confirmed **traffic alert**, the specific **Nexus server** **host** names listed above, and the **EDR alert** showing **periodic outbound connections** at **four-hour intervals**, and **nothing else**.

---

## Strategic Dilemmas & Ambiguities

### 1. The Trust Ambiguity
The vendor issued a **signed update** using their valid, legitimate code-signing certificate. This introduces an **ambiguity** and organizational paradox: Does that make it more or less trustworthy going forward? This leaves the team with no clear right answer on whether to **trust** subsequent vendor patches or isolate the system entirely.

### 2. Operational Continuity vs. Containment
Severing network access or blocking the Nexus agent hosts will instantly isolate the threat and stop potential data exfiltration. However, disabling the hosts completely breaks the **Epic integration**, halting patient intake, insurance verification, and scheduling workflows for thousands of patients. The team must debate whether to maintain a live, compromised connection to preserve clinical throughput or sever it entirely.

### 3. Patient Safety Dimension
Because the backdoor has been active for a three-day window with active FHIR API integration, the **patient safety** dimension must be addressed. Critical **appointment records** may have been **modified** or deleted during the compromise window, directly threatening patient safety and clinical workflow continuity.

### 4. HIPAA & BAA Regulatory Tension
Nexus is a **Business Associate** handling patient demographics and scheduling data. Under **HIPAA** obligations, a confirmed **supply chain** compromise of this data triggers strict, time-sensitive **notification obligations**. Because Nexus has not yet officially declared a breach or responded to our telemetry, MedDefense faces a severe regulatory tension: do we initiate our own public and legal notification obligations immediately based on our internal alerts, or do we wait for formal vendor verification?
