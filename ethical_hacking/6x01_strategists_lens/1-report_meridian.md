# Vanguard Security: Threat Modeling Engagement Report
## Client: Meridian Federal Bank

**Prepared by:** Vanguard Junior Consultant
**Date:** October 24, 2024
**Distribution:** Meridian internal architecture team

## 1. Executive Summary
Vanguard Security conducted a threat modeling engagement to evaluate the architectural security posture of Meridian Federal Bank's migration to a hybrid AWS and on-premises architecture. The primary objective is to equip the internal architecture team with actionable engineering requirements to secure the six-week dual-running phase. The assessment identified critical control gaps primarily concerning data synchronization integrity, identity boundary enforcement, and transit encryption. Addressing these transition-state risks immediately is required to ensure compliance with SOX and GLBA mandates before the legacy mainframe is decommissioned.

## 2. Engagement Context
Meridian Federal Bank is currently mid-way through migrating its core banking infrastructure from a legacy mainframe to a modern AWS cloud architecture. To ensure zero downtime, the bank is operating a six-week dual-running period where data must be synchronized continuously between the legacy and cloud environments. Vanguard was engaged to assess this specific transitional state, identifying architectural and technical risks introduced by bridging systems before the legacy system is fully retired.

## 3. Framework Choice and Rationale
STRIDE was selected as the optimal framework due to its component-centric approach, which aligns perfectly with analyzing the data flows highlighted in the provided migration architecture diagram. Because the signed Rules of Engagement strictly restrict our focus to the technical transition state rather than broader business impacts, STRIDE allows us to systematically evaluate threats at each temporary integration point. By applying STRIDE, we can supply the internal architecture team with precise, actionable engineering requirements to secure the migration window.

## 4. Threat Model

Element: AWS API Gateway
STRIDE Category: Spoofing
Threat: External actors could spoof legitimate internal service requests if identity verification relies solely on weak tokens rather than mTLS.

Element: Legacy-to-AWS Sync Link
STRIDE Category: Tampering
Threat: Data streams synchronizing account balances between the legacy mainframe and AWS during the 6-week dual-run could be intercepted and altered in transit.

Element: Hybrid Transaction Logs
STRIDE Category: Repudiation
Threat: Desynchronization between on-premises and AWS logging environments could result in lost transaction trails, violating SOX compliance.

Element: Transitional VPC
STRIDE Category: Information Disclosure
Threat: Transition state repositories containing GLBA-regulated PII might be exposed if encryption is not enforced during automated deployment.

Element: Migration IAM Roles
STRIDE Category: Elevation of Privilege
Threat: Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment.

## 5. Recommendations and Prioritization
1. Priority 1 (Actionable Engineering Step): Enforce Mutual TLS (mTLS) on the Replication Pipeline. Architecture leads must immediately configure mTLS for all traffic flowing between the legacy mainframe synchronization agents and the AWS ingest gateways.
2. Priority 1 (Actionable Engineering Step): Restrict IAM Roles for Transitional Infrastructure. Engineering teams must audit and scope down the IAM policies attached to the AWS migration functions, removing wildcards from trust policies.
3. Priority 2 (Actionable Engineering Step): Unify Audit Logging for the Transition Window. Stream AWS CloudWatch logs and legacy mainframe transaction logs to a centralized, immutable SIEM to satisfy SOX auditability requirements.

## 6. Limitations and Uncertainty
In strict adherence to the signed Rules of Engagement (RoE) and jurisdictional boundaries, Meridian's European subsidiary located in Luxembourg was entirely excluded from this threat model. Interactions, data flows, and shared infrastructure between the US hybrid environment and the Luxembourg entity were not assessed, as they are out of scope. Furthermore, this assessment models the transition state only; the final post-migration AWS architecture will require a dedicated review.

## 7. Appendix: Sourced Findings
Hidden Finding (Architecture Diagram Interactive Discovery): During hover-state analysis of the migration architecture diagram, an undocumented legacy SSH jump box (10.4.50.12) was found persisting on the edge of the on-premises network with a direct route into the new AWS transit gateway. This asset bypasses the primary VPN tunnel and must be decommissioned immediately.
