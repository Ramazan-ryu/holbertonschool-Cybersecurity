# Vanguard Security: Threat Modeling Engagement Report

## Client: Meridian Federal Bank

**Prepared by:** Vanguard Security, Junior Consultant  
**Date:** July 3, 2026  
**Distribution:** Meridian internal architecture team  

## 1. Executive Summary
This report details the security analysis of Meridian Federal Bank’s transition architecture during the critical six-week dual-running migration from a legacy on-premises mainframe to a hybrid AWS cloud environment. The primary objective is to identify engineering, integration, and architectural risks introduced specifically by this temporary coexistence state. Our analysis indicates that while the target cloud architecture is fundamentally sound, the dual-running data synchronization mechanisms lack adequate cryptographic enforcement and rate-limiting controls. Immediate engineering intervention is required to implement mutual TLS on the sync flows and to throttle cloud-to-mainframe API requests to prevent legacy system resource exhaustion and maintain GLBA/SOX compliance during the transition.

## 2. Engagement Context
Meridian Federal Bank is currently midway through a multi-year IT modernization effort, migrating its core banking infrastructure to a hybrid AWS architecture. To ensure zero downtime, the bank is operating a mandatory six-week dual-running period where data must be continuously synchronized between the legacy mainframe and the new cloud environment. Vanguard was engaged to assess this specific transitional state and identify technical vulnerabilities and architecture-level risks introduced before the legacy system is fully decommissioned.

## 3. Framework Choice and Rationale
We utilized the **STRIDE** threat modeling framework for this engagement. STRIDE was selected because its component-level focus directly addresses the technical and engineering needs of the internal architecture team. By systematically analyzing spoofing, tampering, and other threats across the trust boundaries shown in the **Migration architecture diagram**, we can pinpoint specific technical flaws in the transition infrastructure. Furthermore, this granular approach ensures we generate actionable mitigation strategies for the temporary dual-running state mandated in the **Rules of Engagement document**.

## 4. Threat Model

**Scope:** AWS hybrid cloud components, API Gateway, legacy mainframe, and synchronization flows.
*(Note: Luxembourg subsidiary is explicitly out of scope).*

**Architecture Element 1: Hybrid Data Synchronization Flow (AWS to Mainframe)**
* **Spoofing:** Internal services masquerading as the AWS sync agent to inject fraudulent records.
* **Tampering:** In-transit modification of financial data across the hybrid boundary due to weak transport encryption.
* **Repudiation:** Disjointed logging between AWS CloudTrail and legacy syslogs resulting in orphaned transaction trails.
* **Information Disclosure:** Cleartext exposure of GLBA-regulated data on internal network segments during the sync.
* **Denial of Service (DoS):** Aggressive cloud microservice polling exhausting legacy mainframe connection pools.
* **Elevation of Privilege:** Over-permissive temporary IAM sync roles accessing restricted legacy DB tables.

**Architecture Element 2: Cloud API Gateway**
* **Spoofing:** Weak JWT validation allowing session hijacking from external attackers.
* **Tampering:** Payload manipulation bypassing input validation at the transition boundary.
* **Repudiation:** Insufficient edge logging of transaction origin data prior to backend processing.
* **Information Disclosure:** Verbose API stack traces leaking hybrid architecture details on failure.
* **Denial of Service (DoS):** API layer resource exhaustion filtering down to the on-premises database.
* **Elevation of Privilege:** Broken object-level authorization (BOLA) at the gateway layer.

## 5. Recommendations and Prioritization
The following engineering recommendations are prioritized based on their potential to disrupt core banking operations or violate federal regulations during the dual-run window:

1. **Implement Rate Limiting and Circuit Breakers (Priority: Critical):** To prevent Denial of Service (DoS) against the legacy mainframe, the architecture team must immediately implement strict rate-limiting and circuit-breaker patterns on all AWS microservices polling the on-premises database. The legacy system cannot dynamically scale to meet cloud-native polling rates.
2. **Enforce Mutual TLS (mTLS) for Hybrid Sync Flows (Priority: High):** To mitigate Tampering and Information Disclosure, upgrade the data synchronization pipeline between AWS and the on-premises data center to require mTLS with strict certificate pinning. This ensures data integrity and encrypts GLBA-regulated data in transit across the hybrid boundary.
3. **Unify Audit Logging via Central SIEM (Priority: Medium):** To resolve Repudiation risks and maintain SOX compliance, stream both AWS CloudTrail logs and legacy mainframe syslogs into a centralized, immutable SIEM. Implement correlation IDs across the sync flow to trace transactions seamlessly between environments.
4. **Refine IAM Least Privilege for Sync Agents (Priority: Medium):** Audit the AWS IAM roles assigned to the synchronization containers. Scope permissions down to the exact database tables required for the dual-run sync to prevent Elevation of Privilege.

## 6. Limitations and Uncertainty
* **Jurisdictional and Scope Exclusions:** Per the strict limitations in the Rules of Engagement (RoE) and the business context document, Meridian’s European subsidiary located in Luxembourg is entirely out of scope for this threat model. We have not modeled cross-border data flows to the EU, GDPR compliance risks, or the subsidiary's localized infrastructure. The architecture team must assess the subsidiary separately.
* **Transition State Expiration:** This threat model is explicitly tailored to the six-week dual-running period. Once the legacy mainframe is fully decommissioned, the threat landscape will shift, and a new, cloud-native threat model must be developed for the final AWS architecture.

## 7. Appendix: Sourced Findings
* **Finding 1 - Cleartext Sync Flow Exposure:** Sourced from hovering over the hybrid synchronization link in the interactive *Migration architecture diagram*, which revealed that the legacy system defaults to unencrypted HTTP traffic over the internal network for the synchronization agent. 
* **Finding 2 - Elevated Transition State Targeting:** Sourced from the *Threat intelligence briefing*, which highlights a 40% increase over the last twelve months in US financial-sector adversaries actively targeting temporary IT migration states to exploit asynchronous logging gaps and hide fraudulent transactions.
* **Finding 3 - Strict Federal Audit Requirements:** Sourced from the *Business context document*, which outlines Meridian's US regulatory profile (SOX, GLBA, OCC), making the unified logging and transit encryption recommendations mandatory technical controls rather than optional enhancements.
