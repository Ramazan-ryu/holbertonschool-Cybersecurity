## Framework Declaration
PASTA

## Rationale
PASTA is the selected framework because its risk-centric approach directly ties cybersecurity risks to core business objectives. This is required for the Sundara board of directors evaluating the high-stakes EU expansion and upcoming IPO. PASTA systematically addresses cross-border data flows found in the mobile application architecture diagram. It explicitly evaluates how data exposure threatens compliance across multiple jurisdictions, specifically referencing both the Singapore PDPA and European GDPR requirements from the business context document. 

## Framework Selection Feedback
A key strength of PASTA for Sundara is its inherent focus on mapping technical vulnerabilities directly to financial and regulatory business impacts, allowing non-technical board members to make informed launch decisions. A notable limitation is that its thorough seven-stage progression requires significant upfront documentation and business context analysis, making it more time-intensive than purely engineering-focused checklist frameworks.

## Threat Model
This threat model follows the PASTA seven-stage progression anchored in business objectives.

Stage 1: Define Objectives. The primary business objective is to securely launch the European expansion while protecting loyalty data to preserve IPO credibility. This requires satisfying both Singapore PDPA and EU GDPR compliance. Third-party POS hardware operations are explicitly out of scope.

Stage 2: Define Technical Scope. The technical scope focuses on the mobile application architecture, specifically evaluating cross-border data flows between Asian operational hubs and new European cloud repositories.

Stage 3: Application Decomposition. The application relies on cross-border reservations and integrated payments. Trust boundaries exist between the user device, domestic Singapore databases, and EU data stores, creating a complex interaction between PDPA and GDPR compliance regimes.

Stage 4: Threat Analysis. Cybercriminal syndicates are targeting retail loyalty data. The threat reasoning explicitly considers cross-border data flows: attackers can exploit unmonitored synchronization channels between Asia and the EU to harvest PII, triggering simultaneous compliance breaches under both the PDPA and GDPR regulations.

Stage 5: Vulnerability Analysis. There is weak backend API authorization on the cross-border database synchronization link, and a lack of cross-regional data encryption at rest.

Stage 6: Attack Modeling. Attackers exploit broken object-level authorization within the mobile backend API to mass-exfiltrate European and Asian customer profiles across jurisdictions.

Stage 7: Risk and Impact Analysis. A successful breach of cross-border data flows results in massive fines under the interaction of GDPR and PDPA regulations, destroying the market credibility needed for the IPO.

## Identified Findings
Finding 1. Critical Priority - Cross-Border API Authorization Flaw. The API endpoints driving the cross-border reservations module lack object-level validation. This is prioritized as Critical because a breach immediately exposes regulated data through cross-border data flows, directly threatening the viability of the EU expansion and IPO.

Finding 2. High Priority - Unencrypted Cross-Regional Data Transit Cache. Customer profile tokens are cached in cleartext during synchronization between Asian and EU cloud nodes. This is prioritized as High due to severe non-compliance under GDPR cross-border data transfer mandates and PDPA interaction, exposing the firm to massive regulatory liabilities.

Finding 3. Medium Priority - Fragmented Consent Tracking Management. The application lacks a centralized ledger to synchronize user privacy choices between Singapore PDPA constraints and European GDPR strict opt-in requirements. This is prioritized as Medium because it is a systemic compliance design defect rather than an active channel for immediate data exfiltration.
