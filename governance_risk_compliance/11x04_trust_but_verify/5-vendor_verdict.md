# Bracken Logistics — D+7 Vendor Decision
**Date:** 30 June 2026

## Decision
Maintain Bracken Logistics as a Tier 2 vendor, subject to immediate remediation and enhanced oversight.

The recommendation at D+7 is justified by combining the validated inherent-risk tier with assurance gaps and the contract assessment from Task 2. Bracken scores exactly 10/16 under Marlowe's inherent-risk model (data sensitivity 2, access 3, operational dependency 3, and substitutability 2), securely placing them in Tier 2. However, the assurance evidence and our Task 2 contract assessment do not support treating Bracken as low risk. The SOC 2 Type II period (1 May 2024 to 30 April 2025) is 14 months old relative to the 30 June 2026 review date. Furthermore, the report contains a qualified Availability opinion, three logical-access exceptions (one remaining open), and a fourth-party datacenter carve-out. Compounding this, the Task 2 contract assessment revealed defanged legal language. Together, these factors justify the requirement for the contract amendments outlined below as a condition of continued acceptance.

## Shared Responsibility
Marlowe failed to operate a required Complementary User Entity Control (CUEC). Bracken's SOC 2 states that customer entities are responsible for enforcing MFA on Bracken portal accounts, but Marlowe had never enforced MFA. 

This is Marlowe's own control failure and must remain part of the incident record and risk decision. 
**Remediation:** Enforce MFA for all Bracken portal accounts, verify enrollment, continuously monitor compliance, and retain evidence of the control.

## Contract Conditions
Based on the Task 2 contract assessment, two defanged contract protections must be amended before continued acceptance of the risk:
* **C2 — Right to audit:** Remove Bracken's requirement for "prior written approval." Marlowe should have a defined right to conduct proportionate assurance activities and incident-triggered audits.
* **C3 — Liability cap:** Replace the cap at "three months of fees" with a risk-appropriate liability structure that provides meaningful protection for security, confidentiality, privacy, and regulatory losses.

These amendments are non-negotiable conditions of continued vendor acceptance.

## Concentration Flag — Solstice POS
Solstice POS is the next board-level concentration-risk priority. Solstice operates across all 340 stores, and a vendor failure would halt store sales within hours. 

The validated worksheet calculates Solstice's exposure at $340,000 per hour and $2,720,000 over an eight-hour outage. 

The selected availability mitigation is implementing out-of-band cellular backup and localized offline payment processing for all point-of-sale terminals. This should be treated as the next board priority because it directly reduces Marlowe's dependence on a single POS provider's real-time uptime, ensuring our ability to continue store sales and recover gracefully during a Solstice outage.
