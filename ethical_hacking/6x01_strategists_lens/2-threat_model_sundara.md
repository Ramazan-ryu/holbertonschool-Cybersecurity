## Framework Declaration
PASTA

## Rationale
PASTA is selected as the framework for this engagement because its risk-centric approach directly ties cybersecurity risks to core business objectives, which is required for the Sundara board of directors evaluating the high-stakes EU expansion and upcoming IPO timeline. The framework uses business impact analysis to evaluate how data exposure threatens compliance across multiple jurisdictions, specifically referencing the Singapore PDPA and European GDPR requirements found in the business context document. By focusing on asset objectives and impact, PASTA systematically addresses the cross-border data flows in the mobile application architecture diagram without introducing scope creep into third-party perimeters.

## Framework Selection Feedback
A key strength of PASTA for Sundara is its inherent focus on mapping technical vulnerabilities directly to financial and regulatory business impacts, allowing non-technical board members to make informed launch decisions. A notable limitation is that its thorough seven-stage progression requires significant upfront documentation and business context analysis, making it more time-intensive than purely engineering-focused checklist frameworks.

## Threat Model
Stage 1: Define Objectives
The primary business objective is to securely launch the European expansion while protecting the loyalty data of 12 million active accounts to preserve IPO credibility and satisfy both Singapore PDPA and EU GDPR compliance. Third-party POS hardware operations are completely out of scope for first-party modeling.

Stage 2: Define Technical Scope
The technical scope focuses on the mobile application architecture, specifically the cross-border reservations module, integrated payments, geolocation data, and the data transit boundaries between Asian operational hubs and new European cloud repositories.

Stage 3: Application Decomposition
Data flows involve customer loyalty profile ingestion, cross-jurisdictional profile replication, and API integrations. Trust boundaries exist between the user mobile device, domestic Singapore databases, and the newly deployed EU data stores.

Stage 4: Threat Analysis
Threat Actor Group 1: Cybercriminal syndicates targeting retail loyalty data and customer PII via automated API scraping and credential stuffing.
Threat Scenario 1: Attackers exploit the cross-border reservations module to harvest PII, triggering simultaneous compliance breaches under both PDPA and GDPR due to unmonitored cross-border synchronization channels.

Stage 5: Vulnerability Analysis
Vulnerability 1: Weak backend API authorization on the cross-border database synchronization link.
Vulnerability 2: Lack of unified, cross-regional data encryption at rest within temporary cloud cache layers during multi-jurisdictional user sessions.

Stage 6: Attack Modeling
Attack Vector 1: Exploitation of broken object-level authorization (BOLA) within the mobile backend API to mass-exfiltrate European and Asian customer profiles.

Stage 7: Risk and Impact Analysis
A successful breach of loyalty data during launch preparation would result in maximum regulatory fines under GDPR (up to 4% of global turnover) and PDPA, destroying the market credibility needed for the scheduled IPO.

## Identified Findings
Finding 1. Critical Priority - Cross-Border API Authorization Flaw. The API endpoints driving the cross-border reservations module lack object-level validation. This is prioritized as Critical because a breach immediately exposes both PDPA and GDPR regulated data, mimicking the competitor breach precedent and directly threatening the viability of the EU expansion and IPO.

Finding 2. High Priority - Unencrypted Cross-Regional Data Transit Cache. Customer profile tokens and loyalty metrics are cached in cleartext during synchronization between Asian and European cloud nodes. This is prioritized as High due to severe non-compliance under GDPR cross-border data transfer mandates, exposing the firm to massive regulatory liabilities before launch.

Finding 3. Medium Priority - Fragmented Consent Tracking Management. The application lacks a centralized ledger to synchronize user privacy choices between Singapore PDPA constraints and European GDPR strict opt-in requirements. This is prioritized as Medium because it represents a systemic compliance design defect rather than an active technical channel for immediate data exfiltration.
