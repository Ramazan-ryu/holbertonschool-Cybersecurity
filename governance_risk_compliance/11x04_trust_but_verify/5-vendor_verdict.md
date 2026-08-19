# Vendor Verdict — Bracken Logistics

**To:** Marlowe Retail Group Board  
**From:** Northbridge Risk Advisory  
**Subject:** Bracken Logistics — D+7 Vendor Decision  
**Date:** 30 June 2026

## Decision

Maintain Bracken as a **Tier 2 vendor**, subject to immediate remediation and enhanced oversight.

Bracken scores **11/16** under Marlowe's inherent-risk model: data sensitivity 3, access 3, operational dependency 3, and substitutability 2. The score reflects meaningful customer-data exposure and EDI integration, but not the Tier 1 threshold.

The assurance evidence does not support treating Bracken as low risk. Its SOC 2 Type II covers 1 May 2024–30 April 2025 and is more than a year old at the review date. The report contains a **qualified Availability opinion**, three logical-access exceptions, and one exception still open at period end. The hosting provider is carved out of the report, leaving a fourth-party assurance gap.

## Shared Responsibility

Marlowe also failed to operate a required Complementary User Entity Control. Bracken's SOC 2 identifies MFA enforcement for Bracken portal accounts as a customer responsibility, but Marlowe had never enforced MFA.

This is a Marlowe control failure and must be recorded as part of the incident chain, not attributed solely to Bracken.

**Remediation:** enforce MFA on all Bracken portal accounts, verify enrollment, monitor compliance, and retain evidence of the control.

## Contract Conditions

Two contractual protections must be amended before the relationship is treated as adequately controlled:

- **C2 — Right to audit:** remove the requirement for Bracken's prior written approval. Marlowe should retain a defined right to conduct proportionate assessments and incident-triggered audits.
- **C3 — Liability cap:** replace the three-month-fees cap with a risk-appropriate liability structure that provides meaningful recovery for security, confidentiality, privacy, and regulatory losses.

These amendments should be conditions of continued acceptance of the vendor risk.

## Concentration Flag

**Solstice POS is the board's concentration-risk priority.** Solstice supports POS operations across all 340 stores and failure would halt store sales within hours.

Validated worksheet figures show an exposure of **[HOURLY FIGURE] per hour** and **[8-HOUR FIGURE] over eight hours**.

The recommended mitigation is to reduce single-vendor dependency through a tested alternative POS capability and an executable migration/continuity strategy. The objective is availability resilience, not financial compensation after an outage.

## Board Action

1. Maintain Bracken at Tier 2 with enhanced oversight and remediation.
2. Enforce MFA and evidence the CUEC remediation.
3. Require amendments to C2 and C3.
4. Obtain assurance over the carved-out hosting dependency.
5. Treat Solstice concentration and POS resilience as the next board-level risk item.
