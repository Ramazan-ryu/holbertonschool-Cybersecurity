# Vanguard Security: Threat Modeling Engagement Report
## Client: Meridian Federal Bank

**Prepared by:** Vanguard Junior Consultant
**Date:** October 24, 2024
**Distribution:** Meridian internal architecture team

## 1. Executive Summary
Vanguard Security conducted a threat modeling engagement to evaluate the architectural security posture of Meridian Federal Bank’s ongoing migration to a hybrid AWS/on-premises architecture. The primary objective was to identify technical vulnerabilities introduced during the six-week dual-running phase where both the legacy mainframe and cloud environments are active. The assessment identified critical control gaps primarily concerning data synchronization integrity, identity boundary enforcement, and transit encryption. Addressing these findings immediately is required to ensure compliance with SOX and GLBA mandates during the transition state.

## 2. Engagement Context
Meridian Federal Bank is currently mid-way through migrating its core banking infrastructure from a legacy mainframe to a modern AWS cloud architecture. To ensure zero downtime, the bank is operating a six-week dual-running period where data must be synchronized continuously between the legacy and cloud environments. Vanguard was engaged to assess this specific transitional state, identifying architectural and technical risks introduced before the legacy system is fully decommissioned.

## 3. Framework Choice and Rationale
**Framework:** STRIDE
**Rationale:** STRIDE was selected due to its component-centric approach, which aligns perfectly with analyzing the specific data flows highlighted in the provided Migration architecture diagram. Because the Rules of Engagement strictly restrict our focus to the technical transition state rather than broader business impacts, STRIDE allows us to systematically evaluate threats at each integration point. By applying STRIDE to the identified components bridging the legacy mainframe and AWS, we can supply the architecture team with precise, actionable engineering requirements to secure the migration window.

## 4. Threat Model

| Architecture Element | STRIDE Category | Threat Description |
| :--- | :--- | :--- |
| AWS API Gateway | Spoofing | External actors could spoof legitimate internal service requests if identity verification relies solely on weak tokens rather than mTLS. |
| Legacy-to-AWS Sync Link | Tampering | Data streams synchronizing account balances between the legacy mainframe and AWS during the 6-week dual-run could be intercepted and altered in transit. |
| Hybrid Transaction Logs | Repudiation | Desynchronization between on-premises and AWS logging environments could result in lost transaction trails, violating SOX compliance. |
| Transitional VPC/S3 | Information Disclosure | Transition state repositories containing GLBA-regulated PII might be exposed if encryption is not enforced during automated deployment. |
| On-Premises VPN Gateway | Denial of Service | The high volume of synchronization traffic during the dual-running period could saturate the VPN tunnel, disrupting legitimate branch operations. |
| Migration IAM Roles | Elevation of Privilege | Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment. |

## 5. Recommendations and Prioritization
1. **[Priority 1] Enforce Mutual TLS (mTLS) on the Replication Pipeline:** Immediately configure mTLS for all traffic flowing between the legacy mainframe synchronization agents and the AWS ingest gateways to ensure cryptographic transit security and endpoint authentication.
2. **[Priority 1] Restrict IAM Roles for Transitional Infrastructure:** Audit and scope down the IAM policies attached to the AWS migration functions. Remove wildcards (`*`) from trust policies to ensure compromised transitional components cannot elevate privileges into the production VPC.
3. **[Priority 2] Unify Audit Logging for the Transition Window:** Stream AWS CloudWatch logs and legacy mainframe transaction logs to a centralized, immutable SIEM to satisfy SOX/GLBA auditability requirements and prevent repudiation during the dual-run phase.

## 6. Limitations and Uncertainty
In strict adherence to the signed Rules of Engagement (RoE) and jurisdictional boundaries, Meridian's European subsidiary located in Luxembourg was entirely excluded from this threat model. Interactions, data flows, and shared infrastructure between the US hybrid environment and the Luxembourg entity were not assessed. Furthermore, this assessment models the transition state only; the final post-migration AWS architecture will require a dedicated follow-up review.

## 7. Appendix: Sourced Findings
* **Hidden Finding (Architecture Diagram Interactive Discovery):** During hover-state analysis of the Migration architecture diagram, an undocumented legacy SSH jump box (`10.4.50.12`) was found persisting on the edge of the on-premises network with a direct route into the new AWS transit gateway. This asset bypasses the primary VPN tunnel and must be decommissioned immediately.
