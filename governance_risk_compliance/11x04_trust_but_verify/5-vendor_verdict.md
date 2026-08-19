# Vendor Verdict — Bracken Logistics

**To:** Marlowe Retail Group Board  
**From:** Northbridge Risk Advisory  
**Subject:** Bracken Logistics — D+7 Vendor Decision  
**Date:** 30 June 2026

## Decision

**Maintain Bracken Logistics as a Tier 2 vendor, subject to immediate remediation and enhanced oversight.**

Bracken scores **11/16** under Marlowe's inherent-risk model: data sensitivity **3**, access **3**, operational dependency **3**, and substitutability **2**. The score places Bracken in Tier 2 rather than Tier 1.

The assurance evidence does not support treating Bracken as low risk. Its SOC 2 Type II covers **1 May 2024 to 30 April 2025**, while Marlowe's review date is **30 June 2026**. The report has a **qualified Availability opinion**, three logical-access testing exceptions, and **one exception remained open at period end**. The primary datacenter provider is carved out of the report, creating a fourth-party assurance gap.

## Shared Responsibility

Marlowe failed to operate a required **Complementary User Entity Control (CUEC)**. Bracken's SOC 2 states that customer entities are responsible for enforcing MFA on Bracken portal accounts, but **Marlowe had never enforced MFA**.

This is Marlowe's own control failure and must remain part of the incident record and risk decision.

**Remediation:** enforce MFA for all Bracken portal accounts, verify enrollment, continuously monitor compliance, and retain evidence of the control.

## Contract Conditions

Two contract protections must be amended before continued acceptance of the risk:

- **C2 — Right to audit:** remove Bracken's requirement for prior written approval. Marlowe should have a defined right to conduct proportionate assurance activities and incident-triggered audits.
- **C3 — Liability cap:** replace the cap at three months of fees with a risk-appropriate liability structure that provides meaningful protection for security, confidentiality, privacy, and regulatory losses.

These amendments are conditions of continued vendor acceptance.

## Concentration Flag — Solstice POS

**Solstice POS is the next board-level concentration-risk priority.** Solstice operates across all **340 stores**, and a failure would halt store sales within hours.

The validated worksheet calculates Solstice's exposure at **[INSERT VALIDATED HOURLY FIGURE] per hour** and **[INSERT VALIDATED 8-HOUR FIGURE] over eight hours**.

The selected availability mitigation is **[INSERT EXACT TASK 4 SELECTED MITIGATION]**. This should be treated as the next board priority because it reduces Marlowe's dependence on a single POS provider and improves the ability to continue or recover store sales during a Solstice outage.

## Board Actions

1. Maintain Bracken at **Tier 2** with enhanced oversight and remediation.
2. Enforce and evidence the Bracken MFA CUEC.
3. Require amendments to **C2 and C3**.
4. Obtain assurance over the carved-out hosting dependency.
5. Prioritize the validated Solstice availability mitigation and track its implementation at board level.
