## Framework Declaration
STRIDE

## Rationale
STRIDE is the optimal framework for this engagement due to its native alignment with architectural decomposition and the engineering focus of the target audience. The provided **migration architecture diagram** highlights complex new trust boundaries established during the six-week dual-running period, specifically the data flows bridging the legacy on-premises mainframe and the AWS environment. Furthermore, the **Rules of Engagement** strictly constrain our analysis to the technical transition state rather than broader business impacts or active adversary simulation, making a component-level analysis essential. By applying STRIDE to the identified components and data flows, we can supply the internal architecture team with precise, actionable engineering requirements to secure the migration window.

## Threat Model

| Architecture Element | STRIDE Category | Threat Description |
| :--- | :--- | :--- |
| **AWS API Gateway** | Spoofing | External actors could spoof legitimate internal service requests if identity verification relies solely on IP whitelisting rather than strong authentication. |
| **Legacy-to-Cloud Sync Agent** | Tampering | Data streams synchronizing account balances between the legacy mainframe and AWS during the 6-week dual-run could be intercepted and altered in transit. |
| **Transaction Logs (Hybrid)** | Repudiation | Desynchronization between on-premises and AWS logging environments could result in lost transaction trails, violating SOX compliance. |
| **Temporary S3 Data Lake** | Information Disclosure | Transition state data repositories containing GLBA-regulated PII might be exposed if default bucket policies are incorrectly applied during automated deployment. |
| **On-Premises VPN Gateway** | Denial of Service | The high volume of synchronization traffic during the dual-running period could saturate the VPN tunnel, disrupting legitimate branch banking operations. |
| **Migration Service IAM Roles** | Elevation of Privilege | Overly permissive temporary IAM roles assigned to transition services could be exploited to gain administrative control over the permanent AWS environment. |

## Identified Findings
1. **Critical: Lack of Integrity Verification in Mainframe Sync (Tampering).** The synchronization agent bridging the legacy mainframe and AWS lacks packet-level integrity checks, posing a severe risk to transaction accuracy during the dual-running phase.
2. **High: Over-Privileged Migration IAM Roles (Elevation of Privilege).** The transition state utilizes wildcard permissions for database writing operations, which could allow a compromised transition container to modify critical AWS infrastructure configurations.
3. **Medium: Asymmetric Logging Architectures (Repudiation).** The hybrid state lacks a centralized, immutable audit log, making it currently impossible to definitively prove the origin of a transaction if the mainframe and AWS database records disagree.
