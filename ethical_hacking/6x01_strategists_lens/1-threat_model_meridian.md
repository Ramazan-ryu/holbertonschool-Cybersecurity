## Framework Declaration
STRIDE

## Rationale
STRIDE is the best framework for the Meridian mission because it directly addresses the transition-state risk during the hybrid migration from the legacy mainframe to AWS. The internal technical architecture team requires actionable engineering decisions, which STRIDE delivers by analyzing data flows in the migration architecture. This strictly respects the Rules of Engagement by only evaluating the temporary integration points during the dual-running period, without going out of scope.

## Framework Selection Feedback
A key strength of STRIDE for Meridian is its ability to rigorously identify architectural design flaws, such as unencrypted data flows, during the fragile dual-running migration period. A notable limitation is that STRIDE focuses purely on structural system flaws and does not inherently map to the specific advanced persistent threats outlined in the US financial-sector threat intelligence briefing.

## Threat Model

Architecture Element: AWS API Gateway
STRIDE Category: Spoofing
Threat Description: External actors could spoof legitimate internal service requests if identity verification relies solely on weak tokens rather than mTLS during the migration.

Architecture Element: Legacy-to-AWS Sync Link
STRIDE Category: Tampering
Threat Description: Data streams synchronizing account balances between the legacy mainframe and AWS during the 6-week dual-run could be intercepted and altered in transit.

Architecture Element: Hybrid Transaction Logs
STRIDE Category: Repudiation
Threat Description: Desynchronization between on-premises and AWS logging environments could result in lost transaction trails during the transition, violating SOX compliance.

Architecture Element: Transitional VPC
STRIDE Category: Information Disclosure
Threat Description: Transition state repositories containing GLBA-regulated PII might be exposed if encryption is not enforced during automated deployment.

Architecture Element: On-Premises VPN Gateway
STRIDE Category: Denial of Service
Threat Description: The high volume of synchronization traffic during the dual-running period could saturate the VPN tunnel, disrupting legitimate branch banking operations.

Architecture Element: Migration IAM Roles
STRIDE Category: Elevation of Privilege
Threat Description: Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment.

## Identified Findings
Finding 1: High Priority - Tampering. The synchronization agent bridging the legacy mainframe and AWS lacks mutual TLS and packet-level integrity checks. This is prioritized as High because STRIDE emphasizes data integrity, and altering financial data in transit during the migration phase is a critical failure.

Finding 2: High Priority - Elevation of Privilege. Over-privileged migration IAM roles utilize wildcard permissions for database writing operations. This is prioritized as High because STRIDE identifies elevation of privilege as a complete bypass of trust boundaries, allowing a compromised transition container to modify permanent AWS infrastructure.

Finding 3: Medium Priority - Repudiation. The hybrid state lacks a centralized, immutable audit log correlating legacy and AWS events. This is prioritized as Medium because while it breaks SOX compliance, it is an architectural logging flaw rather than an immediate point of direct technical compromise.
