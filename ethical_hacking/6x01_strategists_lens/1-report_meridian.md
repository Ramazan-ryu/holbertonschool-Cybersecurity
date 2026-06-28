# Vanguard Security: Threat Modeling Engagement Report
## Client: Meridian Federal Bank

**Prepared by:** Vanguard Junior Consultant
**Date:** June 28, 2026
**Distribution:** Meridian internal architecture team

## 1. Executive Summary
Vanguard Security conducted a technical threat modeling assessment focused exclusively on the risks introduced during the six-week dual-running migration window from Meridian's legacy mainframe to the hybrid AWS / on-premises cloud infrastructure. The assessment identifies significant architectural gaps across trust boundaries, particularly regarding synchronization data integrity, identity isolation, and logging uniformity. Addressing these deficiencies immediately at the engineering layer is critical to mitigating systemic transition-state risks and maintaining compliance with regulatory mandates including SOX and GLBA.

## 2. Engagement Context
Meridian Federal Bank is executing a multi-year cloud migration strategy that involves a temporary six-week dual-running window where the legacy mainframe and the new AWS environment handle data concurrently. Vanguard has been engaged to evaluate the specific architectural and structural vulnerabilities native to this active transition state. The objective is to provide the internal architecture team with granular, technical insights to drive immediate engineering remediations before decommissioning occurs.

## 3. Framework Choice and Rationale
**Framework:** STRIDE
**Rationale:** STRIDE is chosen as the optimal framework for this engagement because it naturally aligns with the architectural decomposition of components found in the Migration architecture diagram. Since our objective is to supply the technical architecture team with actionable engineering requirements, a component-level analysis is required to identify flaws introduced during the hybrid transition state. Additionally, the Rules of Engagement strictly limit our scope to the domestic transition state environment rather than broader operational risks, making STRIDE's threat categorization perfectly suited for evaluating the temporary boundaries established during the six-week dual-running period.

## 4. Threat Model

| Architecture Element | STRIDE Category | Threat Description |
| :--- | :--- | :--- |
| AWS API Gateway | Spoofing | External attackers could spoof legitimate internal service calls if authentication mechanisms do not enforce strict identity verification on the cloud ingress point. |
| Legacy-to-AWS Sync Link | Tampering | In-transit transaction data bridging the legacy mainframe and AWS during the six-week dual-running phase could be modified if strong integrity controls or mTLS are absent. |
| Hybrid Transaction Logs | Repudiation | Differences in audit event handling between the on-premises mainframe and AWS CloudWatch could lead to an inability to definitively prove transaction trails, impacting SOX compliance. |
| Transitional VPC / S3 | Information Disclosure | Financial data or customer PII replicated during the active dual-run state could be exposed if misconfigured bucket policies or weak trust boundaries are deployed in AWS. |
| On-Premises VPN Gateway | Denial of Service | High-throughput synchronization data streams running concurrently over the transition window could saturate the network tunnel, disrupting branch connectivity. |
| Migration IAM Roles | Elevation of Privilege | Overly permissive temporary IAM policies bound to data replication services could allow a compromised service to manipulate the permanent production environment. |

## 5. Recommendations and Prioritization
1. **[Priority 1] Enforce Mutual TLS (mTLS) and Packet Integrity for the Replication Link:** Implement mTLS with strict cryptographic signature verification on all synchronization streams between the on-premises mainframe agent and the AWS ingest gateway. This prevents tampering and interception of financial records during the dual-running phase.
2. **[Priority 1] Enforce Least-Privilege IAM Boundaries for Sync Services:** Redefine the IAM policies utilized by transitional migration containers. Eliminate wildcard (`*`) statements and limit execution contexts strictly to required resource IDs to block elevation of privilege vectors.
3. **[Priority 2] Establish an Immutable Centralized Logging Pipeline:** Deploy a dedicated transitional log harvester to ingest events from both AWS CloudWatch and the legacy mainframe into a unified, read-only SIEM bucket. This preserves end-to-end auditability and fulfills SOX compliance requirements.

## 6. Limitations and Uncertainty
Per the explicit scope clauses in the signed Rules of Engagement, Meridian Federal Bank's European subsidiary operating in Luxembourg was strictly excluded from this engagement. Cross-border data flows, regional regulatory variances (such as GDPR), and separate infrastructure stacks utilized by the Luxembourg entity were not reviewed. This assessment focuses solely on the domestic hybrid migration architecture within the defined scope.

## 7. Appendix: Sourced Findings
* **Undocumented Infrastructure Finding:** During the interactive analysis of the Migration architecture diagram, an undocumented legacy SSH jump box (`10.4.50.12`) was identified on the perimeter of the on-premises network with an active route map pointing directly into the new AWS transit gateway bypass controls. This unmonitored transition path breaks established network boundaries and should be decommissioned immediately.
