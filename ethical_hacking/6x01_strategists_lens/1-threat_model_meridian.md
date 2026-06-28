## Framework Declaration
STRIDE

## Rationale
STRIDE was selected due to its component-centric approach, which aligns perfectly with analyzing the specific data flows highlighted in the provided Migration architecture diagram. Because the Rules of Engagement strictly restrict our focus to the technical transition state rather than broader business impacts, STRIDE allows us to systematically evaluate threats at each integration point. By applying STRIDE to the identified components bridging the legacy mainframe and AWS, we can supply the architecture team with precise, actionable engineering requirements to secure the migration window.

## Framework Selection Feedback
A key strength of STRIDE for Meridian is its ability to rigorously identify architectural design flaws, such as unencrypted data flows or weak boundaries, during the fragile six-week dual-running period. However, a primary limitation is its lack of built-in adversary context; STRIDE focuses purely on the system's structural flaws and does not inherently map to the specific advanced persistent threats outlined in the US financial-sector threat intelligence briefing.

## Threat Model

| Architecture Element | STRIDE Category | Threat Description |
| :--- | :--- | :--- |
| AWS API Gateway | Spoofing | External actors could spoof legitimate internal service requests if identity verification relies solely on weak tokens rather than mTLS. |
| Legacy-to-AWS Sync Link | Tampering | Data streams synchronizing account balances between the legacy mainframe and AWS during the 6-week dual-run could be intercepted and altered in transit. |
| Hybrid Transaction Logs | Repudiation | Desynchronization between on-premises and AWS logging environments could result in lost transaction trails, violating SOX compliance. |
| Transitional VPC/S3 | Information Disclosure | Transition state repositories containing GLBA-regulated PII might be exposed if encryption is not enforced during automated deployment. |
| On-Premises VPN Gateway | Denial of Service | The high volume of synchronization traffic during the dual-running period could saturate the VPN tunnel, disrupting legitimate branch operations. |
| Migration IAM Roles | Elevation of Privilege | Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment. |

## Identified Findings
1. [High - Tampering] The synchronization agent bridging the legacy mainframe and AWS lacks mutual TLS (mTLS) and packet-level integrity checks, posing a severe risk to transaction accuracy during the dual-running phase.
2. [High - Elevation of Privilege] Over-privileged migration IAM roles utilize wildcard permissions for database writing operations, allowing a compromised transition container to modify critical AWS infrastructure configurations.
3. [Medium - Repudiation] The hybrid state lacks a centralized, immutable audit log correlating legacy and AWS events, making it currently impossible to definitively prove transaction origins, violating SOX.
