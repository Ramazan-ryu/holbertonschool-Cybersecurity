## Framework Declaration
PASTA

## Rationale
PASTA is the chosen framework because its risk-centric approach translates technical flaws into business impacts for the Sundara board of directors. This addresses the high-stakes European expansion and IPO timeline mentioned in the business context document. Furthermore, PASTA effectively evaluates the cross-border data flows shown in the mobile application architecture diagram. It allows us to systematically model the compliance risks and interactions between the Singapore PDPA and the European GDPR regimes.

## Framework Selection Feedback
A key Sundara-specific strength of PASTA is its ability to map technical vulnerabilities to regulatory impacts, empowering the board to make informed delay-versus-proceed decisions. A limitation is that its comprehensive seven-stage process requires deep business context analysis, making it highly time-intensive.

## Threat Model
Stage 1: Define Objectives. Secure the EU expansion and protect loyalty data to preserve IPO credibility, satisfying PDPA and GDPR. Third-party POS hardware operations are explicitly out of scope for our first-party perimeter.
Stage 2: Define Technical Scope. The scope is the mobile application architecture, focusing on cross-border data flows between Asian hubs and European cloud environments.
Stage 3: Application Decomposition. Trust boundaries exist between user devices, Singapore databases, and EU data stores, creating complex interactions between PDPA and GDPR.
Stage 4: Threat Analysis. Attackers can exploit unmonitored cross-border data flows to harvest PII, causing simultaneous PDPA and GDPR compliance breaches.
Stage 5: Vulnerability Analysis. We identified weak API authorization on the cross-border synchronization link and missing encryption for data in transit.
Stage 6: Attack Modeling. Attackers exploit broken object-level authorization to mass-exfiltrate European and Asian customer profiles.
Stage 7: Risk and Impact Analysis. A successful breach of cross-border data flows results in massive GDPR and PDPA fines, destroying the market credibility required for the IPO.

## Identified Findings
1. Critical Priority: Cross-Border API Flaw. The API lacks object-level validation, exposing regulated data through cross-border data flows. This directly threatens the EU expansion viability, requiring the board to delay the launch to remediate.
2. High Priority: Unencrypted Transit Cache. Customer tokens are cached in cleartext during Asian and EU synchronization. This violates GDPR cross-border data transfer mandates and PDPA interaction rules, requiring remediation before proceeding.
3. Medium Priority: Consent Tracking. The app lacks a centralized ledger to synchronize user privacy choices across jurisdictions. As a systemic compliance defect rather than an active exfiltration channel, the board can proceed with the launch while patching this.
