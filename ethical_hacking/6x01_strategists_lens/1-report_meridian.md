# Vanguard Security: Threat Modeling Engagement Report

## Client: Meridian Federal Bank

**Prepared by:** Junior Consultant, Vanguard Security  
**Date:** June 22, 2026  
**Distribution:** Meridian internal architecture team  

---

## 1. Executive Summary
Vanguard Security was engaged by Meridian Federal Bank to conduct a comprehensive threat modeling assessment of the institution's upcoming hybrid cloud migration architecture. The primary objective was to identify and mitigate structural vulnerabilities introduced during the highly sensitive six-week dual-running transition phase between the legacy mainframe and the new AWS environment. Utilizing an architecture-centric methodology, our analysis identified critical engineering gaps regarding data synchronization integrity, IAM role scoping, and audit trail consistency. Addressing these findings immediately will secure the transition state and ensure that the final cloud architecture does not inherit foundational security debt.

## 2. Engagement Context
Meridian Federal Bank is currently mid-way through a multi-year technological modernization, moving from a legacy on-premises mainframe to a hybrid AWS infrastructure. This engagement focuses specifically on the most vulnerable phase of this migration: the six-week dual-running window where both systems must remain synchronized and operational. As a federally regulated entity (SOX, GLBA, OCC), Meridian must maintain strict data integrity and access controls across this ephemeral hybrid state. This audit is designed to provide the internal architecture team with actionable, engineering-level insights to secure data-in-transit and data-at-rest before legacy decommissioning occurs.

## 3. Framework Choice and Rationale
**Framework:** STRIDE

STRIDE is the optimal framework for this engagement due to its native alignment with architectural decomposition and the engineering focus of the target audience. The provided **migration architecture diagram** highlights complex new trust boundaries established during the six-week dual-running period, specifically the data flows bridging the legacy on-premises mainframe and the AWS environment. Furthermore, the **Rules of Engagement** strictly constrain our analysis to the technical transition state rather than broader business impacts or active adversary simulation, making a component-level analysis essential. By applying STRIDE to the identified components and data flows, we can supply the internal architecture team with precise, actionable engineering requirements to secure the migration window.

## 4. Threat Model
The following matrix details the architectural elements analyzed during the transition state, evaluated against the STRIDE methodology (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege):

| Architecture Element | STRIDE Category | Threat Description |
| :--- | :--- | :--- |
| **AWS API Gateway** | Spoofing | External actors could spoof legitimate internal service requests if identity verification relies solely on IP whitelisting. |
| **Legacy-to-Cloud Sync Agent** | Tampering | Data streams synchronizing account balances between systems could be intercepted and altered in transit. |
| **Transaction Logs (Hybrid)** | Repudiation | Desynchronization between logging environments could result in lost transaction trails. |
| **Temporary S3 Data Lake** | Information Disclosure | Transition state repositories containing PII might be exposed due to misconfigured bucket policies. |
| **On-Premises VPN Gateway** | Denial of Service | Synchronization traffic spikes could saturate the tunnel, disrupting branch operations. |
| **Migration Service IAM Roles** | Elevation of Privilege | Overly permissive temporary IAM roles could be exploited to gain administrative cloud control. |

## 5. Recommendations and Prioritization
The following engineering recommendations are prioritized based on their potential impact on regulatory compliance and data integrity during the migration:

1. **Implement mTLS for the Sync Agent (Priority: Critical)**
   * **Finding:** The data stream between the legacy mainframe and AWS is vulnerable to tampering.
   * **Action:** Enforce mutual TLS (mTLS) for all communications bridging the on-premises and cloud environments. Deploy certificate pinning for the sync agent to guarantee that the AWS ingestion pipeline only accepts data from cryptographically verified internal sources.

2. **Refactor Migration IAM Policies to Least Privilege (Priority: High)**
   * **Finding:** Transition IAM roles currently possess overly broad write permissions.
   * **Action:** Replace wildcard permissions in the migration deployment scripts with explicit, resource-bound policies. Implement strict conditional access, ensuring these roles can only interact with designated transition S3 buckets and databases.

3. **Deploy a Centralized, Immutable Logging Pipeline (Priority: Medium)**
   * **Finding:** Disparate logging mechanisms prevent unified transaction auditing (Repudiation risk).
   * **Action:** Route all authentication and transaction logs from both the mainframe and AWS to an isolated, append-only centralized logging bucket. This ensures SOX compliance and non-repudiation during the dual-running phase.

## 6. Limitations and Uncertainty
* **Jurisdictional Scope:** As explicitly defined in the engagement parameters, Meridian's European subsidiary operating in Luxembourg is entirely out of scope for this threat model. Cross-border data flows or GDPR compliance implications related to the subsidiary have not been assessed.
* **Transition State Exclusivity:** This model strictly analyzes the six-week dual-running architecture. Post-migration configurations and the final decommissioning processes are not covered by this assessment.
* **Physical Security:** In accordance with the Rules of Engagement, the physical security controls of the on-premises legacy mainframe facilities were excluded from this analysis.

## 7. Appendix: Sourced Findings
* **Undocumented API Endpoint Discovered:** While analyzing the interactive **Migration architecture diagram**, an unlisted hover-state label revealed an undocumented API gateway endpoint (`api-legacy-bridge-v2.meridian.internal`). Review of the deployment scripts indicates this endpoint currently lacks rate limiting, posing an unmitigated Denial of Service (DoS) risk not covered in the initial architecture documentation.
