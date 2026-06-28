## Framework Declaration
STRIDE

## Rationale
STRIDE is selected as the optimal framework for this engagement because it naturally aligns with the architectural decomposition of components found in the Migration architecture diagram. Since our objective is to supply the technical architecture team with actionable engineering requirements, a component-level analysis is required to identify flaws introduced during the hybrid transition state. Additionally, the Rules of Engagement strictly limit our scope to the domestic transition state environment rather than broader operational risks, making STRIDE's threat categorization perfectly suited for evaluating the temporary boundaries established during the six-week dual-running period.

## Framework Selection Feedback
A major strength of STRIDE for Meridian is its ability to map specific architectural data flows, such as the sync agents bridging the legacy mainframe and AWS, directly to structural vulnerabilities. A key limitation is that STRIDE evaluates structural design flaws but inherently lacks threat intelligence alignment, meaning it does not incorporate the real-world behaviors highlighted in the US financial-sector adversary threat briefing.

## Threat Model

| Architecture Element | STRIDE Category | Threat Description |
| :--- | :--- | :--- |
| AWS API Gateway | Spoofing | External attackers could spoof legitimate internal service calls if authentication mechanisms do not enforce strict identity verification on the cloud ingress point. |
| Legacy-to-AWS Sync Link | Tampering | In-transit transaction data bridging the legacy mainframe and AWS during the six-week dual-running phase could be modified if strong integrity controls or mTLS are absent. |
| Hybrid Transaction Logs | Repudiation | Differences in audit event handling between the on-premises mainframe and AWS CloudWatch could lead to an inability to definitively prove transaction trails, impacting SOX compliance. |
| Transitional VPC / S3 | Information Disclosure | Financial data or customer PII replicated during the active dual-run state could be exposed if misconfigured bucket policies or weak trust boundaries are deployed in AWS. |
| On-Premises VPN Gateway | Denial of Service | High-throughput synchronization data streams running concurrently over the transition window could saturate the network tunnel, disrupting branch connectivity. |
| Migration IAM Roles | Elevation of Privilege | Overly permissive temporary IAM policies bound to data replication services could allow a compromised service to manipulate the permanent production environment. |

## Identified Findings
1. **Critical: Lack of Integrity Verification in Mainframe Sync (Tampering)** - The replication agent bridging the legacy mainframe and AWS lacks packet-level integrity validation. This priority is justified by STRIDE's focus on data integrity, as altering financial balances during a hybrid state represents a catastrophic data flaw.
2. **High: Over-Privileged Migration IAM Roles (Elevation of Privilege)** - Temporary data synchronization containers use wildcard database permissions. Under STRIDE, this is a severe trust-boundary breach because an exploit could allow unauthorized configuration modifications across the permanent AWS infrastructure.
3. **Medium: Asymmetric Logging Architectures (Repudiation)** - The lack of a centralized, unified logging pipeline between on-premises and AWS creates compliance gaps under SOX. This is categorized as Medium since it represents a structural compliance and non-repudiation failure rather than a direct exploitation route.
