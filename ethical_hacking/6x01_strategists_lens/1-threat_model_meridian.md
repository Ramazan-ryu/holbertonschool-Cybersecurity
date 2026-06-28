## Framework Declaration
STRIDE

## Rationale
STRIDE is selected as the framework for this engagement because it directly addresses the transition-state risk inherent in the hybrid migration from the legacy mainframe to AWS. The internal technical architecture team requires actionable engineering decisions, which STRIDE delivers by systematically analyzing the data flows found in the migration architecture diagram. Furthermore, this component-level approach perfectly aligns with the Rules of Engagement document, which restricts our focus strictly to the temporary integration points during the six-week dual-running period.

## Framework Selection Feedback
A key strength of STRIDE for Meridian is its ability to rigorously identify architectural design flaws, such as unencrypted data flows, during the fragile dual-running migration period. A notable limitation is that STRIDE focuses purely on structural system flaws and does not inherently map to the specific advanced persistent threats outlined in the US financial-sector threat intelligence briefing.

## Threat Model
Element 1: AWS API Gateway
STRIDE Category: Spoofing
Threat: External actors could spoof legitimate internal service requests if identity verification relies solely on weak tokens rather than mutual TLS during the migration.

Element 2: Legacy-to-AWS Synchronization Link
STRIDE Category: Tampering
Threat: Data streams synchronizing account balances between the legacy mainframe and AWS during the six-week dual-running period could be intercepted and altered in transit.

Element 3: Hybrid Transaction Logs
STRIDE Category: Repudiation
Threat: Desynchronization between on-premises and AWS logging environments could result in lost transaction trails during the transition, violating compliance.

Element 4: Transitional VPC
STRIDE Category: Information Disclosure
Threat: Transition state repositories containing regulated data might be exposed if encryption is not enforced during automated deployment.

Element 5: On-Premises VPN Gateway
STRIDE Category: Denial of Service
Threat: The high volume of synchronization traffic during the dual-running period could saturate the VPN tunnel, disrupting legitimate branch banking operations.

Element 6: Migration IAM Roles
STRIDE Category: Elevation of Privilege
Threat: Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment.

## Identified Findings
Finding 1. High Priority - Tampering. The synchronization agent bridging the legacy mainframe and AWS lacks mutual TLS and packet-level integrity checks. This is prioritized as High because STRIDE emphasizes data integrity, and altering financial data in transit during the migration phase is a critical failure.

Finding 2. High Priority - Elevation of Privilege. Over-privileged migration IAM roles utilize wildcard permissions for database writing operations. This is prioritized as High because STRIDE identifies elevation of privilege as a complete bypass of trust boundaries, allowing a compromised transition container to modify permanent AWS infrastructure.

Finding 3. Medium Priority - Repudiation. The hybrid state lacks a centralized audit log correlating legacy and AWS events. This is prioritized as Medium because while it breaks compliance, it is an architectural logging flaw rather than an immediate point of direct technical compromise.
