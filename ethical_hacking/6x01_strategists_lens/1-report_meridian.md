# Vanguard Security: Threat Modeling Engagement Report
## Client: Meridian Federal Bank

Prepared by: Vanguard Junior Consultant
Date: October 24, 2024
Distribution: Meridian internal architecture team

## 1. Executive Summary
Vanguard Security conducted a threat modeling engagement to evaluate the architectural security posture of Meridian Federal Bank during its ongoing migration to a hybrid AWS and on-premises architecture. The primary objective is to identify technical vulnerabilities introduced specifically during the six-week dual-running phase where both the legacy mainframe and cloud environments are active. The assessment identified critical control gaps primarily concerning data synchronization integrity, identity boundary enforcement, and transit encryption. Addressing these findings immediately is required for the internal architecture team to ensure secure engineering decisions and compliance during the transition state.

## 2. Engagement Context
Meridian Federal Bank is currently mid-way through migrating its core banking infrastructure from a legacy mainframe to a modern AWS cloud architecture. To ensure zero downtime, the bank is operating a six-week dual-running period where data must be synchronized continuously between the legacy and cloud environments. Vanguard was engaged to assess this specific transitional state, identifying architectural and technical risks introduced before the legacy system is fully decommissioned.

## 3. Framework Choice and Rationale
Framework: STRIDE.
Rationale: STRIDE is selected as the framework for this engagement because it directly addresses the transition-state risk inherent in the hybrid migration from the legacy mainframe to AWS. The internal technical architecture team requires actionable engineering decisions, which STRIDE delivers by systematically analyzing the data flows found in the migration architecture diagram. Furthermore, this component-level approach perfectly aligns with the Rules of Engagement document, which restricts our focus strictly to the temporary integration points during the six-week dual-running period.

## 4. Threat Model
Element 1: AWS API Gateway. STRIDE Category: Spoofing. Threat: External actors could spoof legitimate internal service requests if identity verification relies solely on weak tokens rather than mutual TLS during the migration.
Element 2: Legacy-to-AWS Synchronization Link. STRIDE Category: Tampering. Threat: Data streams synchronizing account balances between the legacy mainframe and AWS during the six-week dual-running period could be intercepted and altered in transit.
Element 3: Hybrid Transaction Logs. STRIDE Category: Repudiation. Threat: Desynchronization between on-premises and AWS logging environments could result in lost transaction trails during the transition, violating compliance.
Element 4: Transitional VPC. STRIDE Category: Information Disclosure. Threat: Transition state repositories containing regulated data might be exposed if encryption is not enforced during automated deployment.
Element 5: On-Premises VPN Gateway. STRIDE Category: Denial of Service. Threat: The high volume of synchronization traffic during the dual-running period could saturate the VPN tunnel, disrupting legitimate branch banking operations.
Element 6: Migration IAM Roles. STRIDE Category: Elevation of Privilege. Threat: Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment.

## 5. Recommendations and Prioritization
Recommendation 1. Priority 1: Enforce Mutual TLS and Packet Integrity for the Replication Link. The architecture team must immediately implement mTLS with strict cryptographic signature verification on all synchronization streams between the on-premises mainframe agent and the AWS ingest gateway. This prevents tampering and interception of financial records during the dual-running phase.
Recommendation 2. Priority 1: Enforce Least-Privilege IAM Boundaries for Sync Services. The architecture team must redefine the IAM policies utilized by transitional migration containers. Eliminate wildcard statements and limit execution contexts strictly to required resource IDs to block elevation of privilege vectors.
Recommendation 3. Priority 2: Establish an Immutable Centralized Logging Pipeline. Deploy a dedicated transitional log harvester to ingest events from both AWS CloudWatch and the legacy mainframe into a unified, read-only SIEM bucket to preserve end-to-end auditability.

## 6. Limitations and Uncertainty
Per the explicit scope clauses in the signed Rules of Engagement, the European subsidiary operating in Luxembourg is strictly excluded from this engagement. Cross-border data flows, regional regulatory variances, and separate infrastructure stacks utilized by the Luxembourg entity were not reviewed. This assessment focuses solely on the domestic hybrid migration architecture within the defined scope.

## 7. Appendix: Sourced Findings
Finding A: During the interactive analysis of the Migration architecture diagram, an undocumented legacy SSH jump box at 10.4.50.12 was identified on the perimeter of the on-premises network with an active route map pointing directly into the new AWS transit gateway bypass controls. This unmonitored transition path breaks established network boundaries and must be decommissioned immediately.
