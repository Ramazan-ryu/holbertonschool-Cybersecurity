## Framework Declaration
STRIDE

## Rationale
STRIDE is the optimal framework for Meridian Federal Bank because it directly addresses the transition-state risk inherent in the hybrid migration from the legacy mainframe to AWS. The internal architecture team requires technical, actionable engineering decisions, which STRIDE delivers by systematically analyzing the data flows in the migration architecture diagram. Furthermore, this component-level approach perfectly aligns with the Rules of Engagement, which restrict our focus strictly to the temporary integration points during the six-week dual-running period. 

## Framework Selection Feedback
A key strength of STRIDE for Meridian is its ability to rigorously identify architectural design flaws—such as unencrypted data flows—during the fragile dual-running migration period. A notable limitation is that STRIDE focuses purely on structural system flaws and does not inherently map to the specific advanced persistent threats outlined in the US financial-sector threat intelligence briefing.

## Threat Model

| Architecture Element | STRIDE Category | Threat Description |
| :--- | :--- | :--- |
| AWS API Gateway | Spoofing | External actors could spoof legitimate internal service requests if identity verification relies solely on weak tokens rather than mTLS. |
| Legacy-to-AWS Sync Link | Tampering | Data streams synchronizing account balances between the legacy mainframe and AWS during the 6-week dual-run could be intercepted and altered in transit. |
| Hybrid Transaction Logs | Repudiation | Desynchronization between on-premises and AWS logging environments could result in lost transaction trails, violating SOX compliance. |
| Transitional VPC / S3 | Information Disclosure | Transition state repositories containing GLBA-regulated PII might be exposed if encryption is not enforced during automated deployment. |
| On-Premises VPN Gateway | Denial of Service | The high volume of synchronization traffic during the dual-running period could saturate the VPN tunnel, disrupting legitimate branch banking operations. |
| Migration IAM Roles | Elevation of Privilege | Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment. |

## Identified Findings
1. [High - Tampering] The synchronization agent bridging the legacy mainframe and AWS lacks mutual TLS (mTLS) and packet-level integrity checks, posing a severe risk to transaction accuracy during the dual-running phase.
2. [High - Elevation of Privilege] Over-privileged migration IAM roles utilize wildcard permissions for database writing operations, allowing a compromised transition container to modify critical AWS infrastructure configurations.
3. [Medium - Repudiation] The hybrid state lacks a centralized, immutable audit log correlating legacy and AWS events, making it currently impossible to definitively prove transaction origins.
