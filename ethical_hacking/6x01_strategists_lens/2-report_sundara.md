# Vanguard Security: Threat Modeling Engagement Report
## Client: Sundara Lifestyle

Prepared by: Vanguard Junior Consultant
Date: October 24, 2024
Distribution: Sundara board (CFO, CEO, independent directors)

## 1. Executive Summary
Vanguard Security conducted a comprehensive risk assessment to inform the board's critical decision regarding whether to proceed with the European retail expansion as planned or delay the launch by six months for security hardening. Following the severe loyalty-data breach suffered by a major Asian competitor, our audit evaluated the security posture of Sundara's mobile application ecosystem under both Singapore PDPA and European GDPR regimes. We identified critical structural deficiencies in cross-border data synchronization and API authorization that create immediate regulatory and operational liability. Proceeding with the launch in the current state exposes Sundara to catastrophic data exposure and prohibitive global regulatory fines, which would effectively destroy the company's upcoming IPO credibility. Vanguard strongly recommends delaying the European launch to remediate these structural gaps and safeguard corporate value.

## 2. Engagement Context
Sundara Lifestyle is preparing for an aggressive market expansion into Europe alongside an impending IPO. Weeks before launch, a direct regional competitor suffered a catastrophic loyalty-data breach that severely damaged its market viability. Vanguard was engaged to perform a comprehensive threat modeling assessment on Sundara's multi-jurisdictional mobile application architecture to identify similar systemic gaps, manage cross-border data transfer compliance risks, and provide the executive leadership team with clear data to decide the timeline of the European expansion.

## 3. Framework Choice and Rationale
Framework: PASTA.
Rationale: PASTA is selected as the framework for this engagement because its risk-centric approach directly ties cybersecurity risks to core business objectives, which is required for the Sundara board of directors evaluating the high-stakes EU expansion and upcoming IPO timeline. The framework uses business impact analysis to evaluate how data exposure threatens compliance across multiple jurisdictions, specifically referencing the Singapore PDPA and European GDPR requirements found in the business context document. By focusing on asset objectives and impact, PASTA systematically addresses the cross-border data flows in the mobile application architecture diagram without introducing scope creep into third-party perimeters.

## 4. Threat Model
Stage 1: Define Objectives. Secure the European launch while protecting the loyalty data of 12 million active accounts to satisfy both Singapore PDPA and EU GDPR compliance. Third-party POS hardware operations are explicitly out of scope for first-party modeling.
Stage 2: Define Technical Scope. Focus on the mobile application architecture, cross-border reservations module, integrated payments, geolocation data, and transit boundaries between Asian operational hubs and European cloud repositories.
Stage 3: Application Decomposition. Analyze user profile ingestion, cross-jurisdictional replication, and API integrations. Trust boundaries exist between the user device, domestic Singapore databases, and new EU data stores.
Stage 4: Threat Analysis. Threat actors include cybercriminal syndicates targeting retail loyalty PII via automated scraping. Attackers exploit the cross-border reservations module to harvest PII, triggering simultaneous compliance failures under both PDPA and GDPR.
Stage 5: Vulnerability Analysis. Gaps include weak backend API authorization on the cross-border synchronization link and a lack of unified cross-regional data encryption at rest within temporary cloud cache layers.
Stage 6: Attack Modeling. Attack vectors focus on the exploitation of broken object-level authorization within the mobile backend API to mass-exfiltrate European and Asian customer profiles.
Stage 7: Risk and Impact Analysis. A successful breach results in maximum regulatory fines under GDPR and PDPA, halting the IPO process and destroying international expansion credibility.

## 5. Recommendations and Prioritization
Recommendation 1. Priority 1: Implement Zero-Trust API Gateways with Strict Object-Level Validation. The engineering team must immediately refactor authorization controls within the cross-border reservations module. Every incoming API call must be cryptographically validated against the requesting session to completely eliminate data scraping vectors.
Recommendation 2. Priority 1: Enforce Automated Cross-Regional Encryption and Key Lifecycle Isolation. Implement separate, localized KMS encryption keys for the European and Asian cloud storage repositories. Ensure all synchronized customer data is encrypted at rest and in transit using certified cryptographic standards before crossing international borders.
Recommendation 3. Priority 2: Deploy a Unified Cross-Jurisdictional Privacy Consent Platform. Implement a centralized consent ledger that dynamically adjusts data collection, processing, and retention behaviors based on user location to seamlessly handle the interaction between PDPA and strict GDPR opt-in rules.

## 6. Limitations and Uncertainty
This assessment is strictly constrained to Sundara's first-party digital ecosystem and mobile application backend. Per the business context and rules of engagement, all Point-of-Sale (POS) hardware infrastructure is exclusively built, operated, and maintained by a third-party vendor. Consequently, physical POS tampering, hardware-level skimming, and local terminal network security were not modeled as Sundara's first-party responsibility. Additionally, this report addresses the structural intersection of Singapore PDPA and EU GDPR regarding cross-border data flows, but does not account for localized municipal compliance variances within separate European nations.

## 7. Appendix: Sourced Findings
Finding A: During the comprehensive review of the mobile application architecture diagram, an unencrypted telemetry endpoint was discovered mapping active GPS location records from European app sessions back to a legacy analytics cluster hosted outside the EU boundary. This unmapped cross-jurisdictional data relationship violates basic GDPR data residency requirements and must be rerouted through localized anonymization filters immediately.
