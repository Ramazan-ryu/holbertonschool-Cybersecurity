# Board Memorandum: Bracken Logistics & Vendor Concentration Risk

**To:** Board of Directors, Marlowe  
**Date:** 30 June 2026  
**Subject:** Bracken Logistics D+7 Vendor Decision and Solstice POS Concentration Flag  

## 1. Bracken Logistics Decision
**Decision:** Maintain Bracken Logistics as a Tier 2 vendor, subject to immediate remediation and enhanced contractual oversight.

Bracken scores 11/16 under our inherent-risk model (data sensitivity 3, access 3, operational dependency 3, substitutability 2). This places Bracken securely in Tier 2. However, current assurance evidence does not support treating them as low risk. Their SOC 2 Type II report is stale, covering 1 May 2024 to 30 April 2025, leaving a 14-month gap to our 30 June 2026 review date. Furthermore, the report contains a qualified Availability opinion, three logical-access testing exceptions (with one remaining open at period end), and explicitly carves out their primary datacenter provider, creating a critical fourth-party assurance gap.

## 2. Shared Responsibility Failure
During the incident review, it was discovered that Marlowe failed to operate a required Complementary User Entity Control (CUEC). Bracken’s SOC 2 clearly states that customer entities are responsible for enforcing Multi-Factor Authentication (MFA) on Bracken portal accounts, yet Marlowe had never enforced MFA. 

This is Marlowe's own control failure and must permanently remain part of the incident record and risk decision. 
**Remediation:** We are immediately enforcing MFA for all Bracken portal accounts. We will verify enrollment, continuously monitor compliance, and retain evidence of this control's operation moving forward.

## 3. Contract Conditions
Two defanged contract clauses must be amended as a strict condition of continued vendor acceptance:
* **C2 — Right to Audit:** We must remove Bracken's requirement for "prior written approval." Marlowe must possess a defined right to conduct proportionate assurance activities and incident-triggered audits.
* **C3 — Liability Cap:** The current cap limited to "three months of fees" must be replaced with a risk-appropriate liability structure that provides meaningful, scaled protection for security, confidentiality, privacy, and regulatory losses.

## 4. Concentration Flag — Solstice POS
Solstice POS represents our next critical board-level concentration-risk priority. Solstice operates the point-of-sale across all 340 Marlowe stores; a vendor failure would halt store sales almost immediately. 

Based on the validated worksheet, Solstice’s operational exposure costs the business $850,000 per hour, scaling to a catastrophic $6,800,000 over an eight-hour outage. 

**Next Board Action:** The selected availability mitigation is implementing localized offline payment processing with batch synchronization for all point-of-sale terminals. This should be treated as the next board priority because it directly reduces Marlowe's dependence on a single POS provider's real-time uptime, ensuring our ability to continue store sales and recover gracefully during a Solstice outage.
