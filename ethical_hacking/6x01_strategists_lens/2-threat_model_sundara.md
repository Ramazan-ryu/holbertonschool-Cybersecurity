## Framework Declaration
PASTA (Process for Attack Simulation and Threat Analysis)

## Rationale
PASTA is the chosen framework because its risk-centric approach translates technical flaws into direct business impacts, satisfying the Sundara board's need to evaluate the high-stakes European expansion and upcoming IPO timeline outlined in the Business context document. Furthermore, it systematically models the specific cross-border data flows shown in the Mobile application architecture diagram, explicitly highlighting the regulatory interactions between the Singapore PDPA and the European GDPR regimes. This ensures that the active retail-sector threats mentioned in the Threat intelligence briefing are evaluated within the correct cross-jurisdictional context.

## Framework Selection Feedback
A key Sundara-specific strength of PASTA is its ability to directly map technical API vulnerabilities to regulatory compliance impacts, empowering the board to make an informed delay-versus-proceed decision regarding the EU launch. A notable limitation is that its comprehensive seven-stage process requires deep, continuous business context analysis, which can be highly time-intensive given the tight pre-IPO schedule.

## Threat Model

**Stage 1: Define Objectives**
Secure the aggressive EU expansion and protect the 12M active loyalty accounts to preserve the IPO credibility, satisfying both PDPA (Singapore) and GDPR (EU) mandates. Third-party POS hardware operations are strictly out of scope for Sundara's first-party technical perimeter modeling.

**Stage 2: Define Technical Scope**
The scope encompasses Sundara's first-party mobile application architecture, focusing specifically on the cross-border data flows between the Asian hubs and European user environments. This includes the integrated payment API, geolocation features, AI recommendations, and the cross-border reservations module.

**Stage 3: Application Decomposition**
Critical trust boundaries exist between EU user mobile devices, cross-border reservations APIs, and the centralized Singapore databases. Commingling user data across these zones creates complex, high-risk interactions between PDPA's baseline privacy rules and GDPR's stringent data localization and consent requirements.

**Stage 4: Threat Analysis**
Based on the threat intelligence briefing, retail-sector attackers are actively targeting loyalty data through API scraping and skimmer activity. Attackers can exploit unmonitored cross-border data flows to harvest PII, mimicking the comparable competitor breach and causing simultaneous PDPA and GDPR compliance failures.

**Stage 5: Vulnerability Analysis**
We identified weak API object-level authorization on the cross-border reservations module and a lack of explicit, granular consent mechanisms for AI recommendations and geolocation tracking in EU environments. Additionally, transit caches lack encryption when syncing data between EU and Asian hubs.

**Stage 6: Attack Modeling**
Attackers bypass the reservations API authorization checks to mass-exfiltrate European and Asian customer profiles. Because the central AI engine does not compartmentalize data jurisdictions, a single point of compromise yields both PDPA- and GDPR-regulated records.

**Stage 7: Risk and Impact Analysis**
A successful breach of cross-border data flows results in massive GDPR fines (up to 4% of global revenue) and devastating reputational damage in the new EU market. This completely destroys the market credibility required for a successful IPO.

## Identified Findings

1. **Critical Priority: Unrestricted Cross-Border Reservations API.** The API lacks object-level validation, exposing GDPR-regulated loyalty data through cross-border flows to the exact scraping techniques that breached the competitor. This directly threatens the EU expansion viability, requiring the board to delay the launch to remediate and secure customer trust.
2. **High Priority: Unencrypted Transit Cache across Jurisdictions.** Customer tokens are cached in cleartext during Asian and EU synchronization. This violates strict GDPR cross-border data transfer mandates and PDPA interaction rules, presenting significant regulatory exposure that must be patched before proceeding.
3. **Medium Priority: Unified Consent Tracking.** The app currently uses Asian PDPA-level consent defaults for all users, lacking granular opt-in ledgers for EU geolocation and AI tracking. As a systemic compliance defect rather than an active exfiltration vulnerability, the board can proceed with the launch with the condition that a dedicated GDPR consent update is pushed immediately post-launch.
