## Framework Declaration
The chosen framework for Sundara is PASTA.

## Rationale
PASTA is the selected framework because its risk-centric approach directly ties cybersecurity risks to core business objectives. This is required for the Sundara board of directors evaluating the high-stakes EU expansion and upcoming IPO. PASTA systematically addresses cross-border data flows found in the mobile application architecture diagram. It explicitly evaluates how data exposure threatens compliance across multiple jurisdictions, specifically referencing both the Singapore PDPA and European GDPR requirements from the business context document.

## Framework Selection Feedback
A key strength of PASTA for Sundara is its focus on mapping technical vulnerabilities directly to financial and regulatory business impacts, allowing the board to make informed delay-versus-proceed decisions. A notable limitation is that its thorough seven-stage progression requires significant upfront documentation, making it time-intensive.

## Threat Model
This threat model follows the PASTA seven-stage progression anchored in business objectives.

Stage 1: Define Objectives. Secure the European expansion while protecting loyalty data to preserve IPO credibility. This requires satisfying both Singapore PDPA and EU GDPR compliance. Third-party POS hardware operations are explicitly out of scope for Sundara's first-party threat perimeter.

Stage 2: Define Technical Scope. The technical scope focuses on the mobile application architecture, specifically evaluating cross-border data flows between Asian operations and EU-facing expansion features.

Stage 3: Application Decomposition. The application relies on cross-border reservations. Trust boundaries exist between the user device, domestic Singapore databases, and EU data stores, creating a complex interaction between PDPA and GDPR compliance regimes.

Stage 4: Threat Analysis. The threat reasoning explicitly considers cross-border data flows. Attackers can exploit unmonitored synchronization channels between Asia and the EU to harvest PII, triggering simultaneous compliance breaches under both PDPA and GDPR.

Stage 5: Vulnerability Analysis. There is weak backend API authorization on the cross-border database synchronization link.

Stage 6: Attack Modeling. Attackers exploit broken object-level authorization within the mobile backend API to mass-exfiltrate European and Asian customer profiles across jurisdictions.

Stage 7: Risk and Impact Analysis. A successful breach of cross-border data flows results in massive fines under the interaction of GDPR and PDPA regulations, destroying the market credibility needed for the board's delay-versus-proceed IPO decision.

## Identified Findings
Finding 1. Critical Priority - Cross-Border API Authorization Flaw. The API endpoints driving the cross-border reservations module lack object-level validation. This is prioritized as Critical because a breach immediately exposes regulated data through cross-border data flows, directly threatening the viability of the EU expansion and tying into the board-level delay-versus-proceed decision.

Finding 2. High Priority - Unencrypted Cross-Regional Data Transit Cache. Customer profile tokens are cached in cleartext during synchronization between Asian and EU cloud nodes. This is prioritized as High due to severe non-compliance under GDPR cross-border data transfer mandates and PDPA interaction.

Finding 3. Medium Priority - Fragmented Consent Tracking Management. The application lacks a centralized ledger to synchronize user privacy choices. This is prioritized as Medium because it is a systemic compliance design defect rather than an active channel for immediate data exfiltration.
