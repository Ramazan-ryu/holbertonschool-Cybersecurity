## Framework Declaration
PASTA

## Rationale
PASTA is the optimal framework for this engagement because the primary objective is a board-level business decision regarding the IPO timeline, rather than purely technical architecture validation. By anchoring the analysis in business impact, PASTA directly addresses the business context document's mandate to evaluate the reputational and financial risks of a loyalty-data breach mirroring the recent competitor incident. Furthermore, this risk-centric approach correctly weights the severe compliance penalties associated with cross-border data flows detailed in the Rules of Engagement, specifically the friction between Singapore's PDPA and the incoming GDPR regime.

## Threat Model

**Stage I: Define Business Objectives (Risk Profile)**
Primary Objective: Ensure a secure European expansion to protect market credibility and the upcoming IPO valuation.
Primary Risk: A first-party loyalty data breach or severe GDPR regulatory enforcement resulting in financial penalties and loss of investor confidence.

**Stage II: Define Technical Scope**
In Scope (First-Party): Sundara Mobile Application (12M active accounts), API backends, cross-border reservation modules, integrated payments, and AI recommendation engines.
Out of Scope (Third-Party Perimeter): Retail POS hardware. As this is entirely managed by third-party vendors, Sundara holds no first-party responsibility for its operational security.

**Stage III: Application Decomposition**
Data pipelines route EU customer geolocation and loyalty data back to centralized servers in Singapore, highlighting immediate cross-jurisdictional friction between legacy PDPA handling and strict GDPR frameworks.

**Stage IV: Threat Analysis**
The threat intelligence briefing highlights two attack vectors: retail-sector skimmers and loyalty-data compromise. The skimmer activity targets third-party-managed POS hardware, placing it strictly outside Sundara's first-party responsibility perimeter. Consequently, we explicitly exclude skimmers from our model. The loyalty-data activity directly targets our first-party mobile APIs; this is our primary modeled threat, alongside regulatory exposure.

**Stage V: Vulnerability & Flaws Analysis**
The current architecture applies legacy PDPA consent models to the AI recommendation engine and cross-border pipelines, failing GDPR's explicit "opt-in" requirements. Additionally, first-party mobile loyalty endpoints lack strict rate limiting.

**Stage VI: Attack Modeling**
Adversaries exploit weakly authenticated first-party APIs to scrape high-tier EU loyalty profiles, or regulatory bodies detect non-compliant cross-border telemetry, triggering mandatory breach notifications ahead of the IPO.

**Stage VII: Risk & Impact Analysis**
GDPR fines up to 4% of global turnover and catastrophic brand destruction, directly jeopardizing the board's IPO strategy.

## Identified Findings
1. Critical: First-Party GDPR Non-Compliance in Cross-Border Flows. EU customer geolocation and AI data are routed to Singapore under legacy PDPA consent models, posing an unacceptable regulatory risk that necessitates delaying the EU launch until localized, GDPR-compliant infrastructure is established.
2. High: First-Party Loyalty API Vulnerability. The mobile application's loyalty balance endpoints lack robust rate limiting, making them highly susceptible to the exact credential stuffing attacks that compromised Sundara's competitor.
