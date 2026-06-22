## Framework Declaration
PASTA (Process for Attack Simulation and Threat Analysis)

## Rationale
PASTA is the necessary framework for this engagement because the primary objective is not purely technical, but rather a high-stakes business decision: whether to delay an EU launch ahead of an IPO. By anchoring the threat model to business impact, PASTA directly addresses the **business context document's** mandate to evaluate the risk of suffering a brand-destroying data breach similar to the recent competitor incident. Furthermore, PASTA's risk-centric approach allows us to properly weigh the severe regulatory and financial penalties associated with the cross-border data flows detailed in the **Rules of Engagement**, specifically the complex transition from Singapore's PDPA to the European Union's GDPR.

## Threat Model

**Stage I: Define Business Objectives (Risk Profile)**
*   **Primary Objective:** Ensure a successful, unblemished European expansion to protect the upcoming IPO valuation. 
*   **Primary Risk:** A loyalty-data breach mirroring the recent competitor incident, leading to brand destruction and severe GDPR regulatory fines.

**Stage II: Define Technical Scope**
*   **In Scope:** Sundara Mobile Application (12M accounts), integrated payments, geolocation data, AI recommendations, cross-border reservations module.
*   **Out of Scope (Third-Party):** Retail POS hardware (managed entirely by third-party vendors, excluded from first-party threat modeling).

**Stage III: Application Decomposition**
*   Analysis of the mobile architecture reveals high-volume data pipelines routing EU customer geolocation and loyalty data back to centralized servers in Singapore, creating immediate cross-border compliance friction between GDPR and PDPA regimes.

**Stage IV: Threat Analysis**
*   Based on the **threat intelligence briefing**, the primary threat actors are financially motivated syndicates targeting retail loyalty programs via API credential stuffing, as well as regulatory threats stemming from non-compliant cross-border PII handling.

**Stage V: Vulnerability & Flaws Analysis**
*   The transition state assumes PDPA-level consent models for the AI recommendation engine, which inherently violates GDPR's explicit "opt-in" requirements for automated profiling.

**Stage VI: Attack Modeling**
*   *Attack Path:* Adversary exploits weakly authenticated cross-border reservation APIs -> Extracts high-tier EU loyalty profiles -> Resells data on underground markets -> Triggers immediate GDPR breach notification requirements weeks before IPO.

**Stage VII: Risk & Impact Analysis**
*   A breach of EU loyalty data would result in fines up to 4% of global turnover under GDPR and catastrophic loss of investor confidence, directly jeopardizing the IPO.

## Identified Findings
1. **Critical: GDPR Non-Compliant Cross-Border Data Flows.** EU customer geolocation and AI profiling data are routed to Singapore under legacy PDPA consent models, presenting an immediate, high-probability regulatory risk.
2. **High: Unauthenticated Loyalty API Enumeration.** The mobile app's loyalty balance endpoint lacks robust rate limiting, making it highly susceptible to the exact credential stuffing attacks that compromised Sundara's competitor.
3. **Medium: Third-Party Payment Gateway Integration Risks.** While POS hardware is out of scope, the mobile app's digital handoff to third-party payment processors lacks end-to-end encryption verification, risking interception of transaction tokens.
