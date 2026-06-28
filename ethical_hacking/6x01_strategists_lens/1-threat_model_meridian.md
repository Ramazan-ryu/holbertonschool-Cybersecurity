## Framework Declaration
STRIDE

## Rationale
STRIDE is the optimal framework for Meridian Federal Bank because it directly addresses the transition-state risk inherent in the hybrid migration from the legacy mainframe to AWS. The internal architecture team requires technical, actionable engineering decisions, which STRIDE delivers by systematically analyzing the data flows found in the migration architecture diagram. Furthermore, this component-level approach perfectly aligns with the Rules of Engagement, which restrict our focus strictly to the temporary integration points during the six-week dual-running period.

## Framework Selection Feedback
A key strength of STRIDE for Meridian is its ability to rigorously identify architectural design flaws, such as unencrypted data flows, during the fragile dual-running migration period. A notable limitation is that STRIDE focuses purely on structural system flaws and does not inherently map to the specific advanced persistent threats outlined in the US financial-sector threat intelligence briefing.

## Threat Model

Element 1: AWS API Gateway
STRIDE Category: Spoofing
Threat Description: External actors could spoof legitimate internal service requests if identity verification relies solely on weak tokens rather than mTLS during the migration transition state.

Element 2: Legacy-to-AWS Sync Link
STRIDE Category: Tampering
Threat Description: Data streams synchronizing account balances between the legacy mainframe and AWS during the 6-week dual-run could be intercepted and altered in transit.

Element 3: Hybrid Transaction Logs
STRIDE Category: Repudiation
Threat Description: Desynchronization between on-premises and AWS logging environments could result in lost transaction trails during the transition, violating SOX compliance.

Element 4: Transitional VPC
STRIDE Category: Information Disclosure
Threat Description: Transition state repositories containing GLBA-regulated PII might be exposed if encryption is not enforced during automated deployment.

Element 5: On-Premises VPN Gateway
STRIDE Category: Denial of Service
Threat Description: The high volume of synchronization traffic during the dual-running period could saturate the VPN tunnel, disrupting legitimate branch banking operations.

Element 6: Migration IAM Roles
STRIDE Category: Elevation of Privilege
Threat Description: Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment.

## Identified Findings

1. Priority: High. Finding: The synchronization agent bridging the legacy mainframe and AWS lacks mutual TLS and packet-level integrity checks. Framework Reasoning: Under STRIDE, this is categorized as Tampering. Altering financial data in transit during the migration phase is a critical failure of trust boundaries, justifying a high priority.

2. Priority: High. Finding: Over-privileged migration IAM roles utilize wildcard permissions for database writing operations. Framework Reasoning: Under STRIDE, this is an Elevation of Privilege vulnerability. This allows a compromised transition container to modify permanent AWS infrastructure, justifying immediate engineering remediation.

3. Priority: Medium. Finding: The hybrid state lacks a centralized, immutable audit log correlating legacy and AWS events. Framework Reasoning: Under STRIDE, this is a Repudiation risk. While it breaks SOX compliance, it is an architectural logging flaw rather than an immediate point of direct technical compromise, placing it at a medium priority.
