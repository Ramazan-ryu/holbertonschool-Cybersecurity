# Vireo Payments — Readiness Verdict

**To:** Vireo Payments Board
**Purpose:** Series C Investor Due Diligence
**Assessment window:** 90 days to close

## Executive Verdict

Vireo has several effective controls, but it is **not currently ready to represent itself as fully compliant across PCI DSS, GDPR, DORA and SOC 2**. The strongest evidence is in secrets management [F01] and ledger recovery [F04]. The most material weaknesses are the absence of risk governance [F06], an overdue penetration test [F05], missing DORA governance and register of information, and inadequate third-party controls around Certeva ID [F03].

The recommended position is **transparent remediation, not cosmetic compliance**. Vireo can present a credible 90-day readiness programme, but it should not claim that all regulatory or assurance gaps will be closed by the Series C close.

## 1. Obligations

Vireo operates under four different obligation mechanisms.

**PCI DSS** applies through the payment-card ecosystem and contractual requirements governing the handling of cardholder data. Its control requirements concern payment-card security.

**GDPR** is directly applicable data-protection law. It governs Vireo's processing of personal data and creates specific obligations when personal-data breaches occur.

**DORA** is directly applicable EU regulation for in-scope financial entities and governs digital operational resilience, ICT risk management, incident management, resilience testing, third-party ICT risk and information sharing. Vireo has no identified owner for this obligation.

**SOC 2** is an independent assurance framework rather than an EU regulation. A SOC 2 report provides assurance over controls against the applicable Trust Services Criteria. Vireo has never opened a SOC 2 engagement.

The board currently has no formal risk register or appetite statement [F06]. Vireo must also establish and maintain the required **DORA Register of Information**. The absence of an owner and register is a material governance gap.

## 2. Risk

The quantified annualised exposure is:

| Scenario                    |     SLE | ARO |     ALE |
| --------------------------- | ------: | --: | ------: |
| S1 — Card-data breach       | €600000 | 0.2 | €120000 |
| S2 — Account-takeover fraud | €120000 | 1.5 | €180000 |
| S3 — Certeva KYC exposure   | €600000 | 0.5 | €300000 |

S3 is therefore the highest quantified annual risk at **€300000 ALE**.

The proposed Certeva control package costs **€45000/year** and reduces S3 ARO from 0.5 to 0.1. Its residual ALE becomes **€60000**, producing an annual risk reduction of **€240000**.

The resulting net annual economic benefit is:

**€240000 − €45000 = €195000**

The recommended treatment is therefore **treat S3** through the proposed vendor hardening package, contractual amendments, enforced SSO with MFA and continuous monitoring. The treatment should be assigned an owner, tracked to dated milestones and reviewed against the residual risk.

## 3. Evidence and Posture

The evidence pack produces both strengths and weaknesses.

**[F01] Secrets management — Green.** Vireo has a central vault, MFA for all access and signed quarterly access reviews. The latest review occurred five weeks ago. This is positive evidence of an operating control and should be certified as a strength.

**[F04] Ledger resilience — Green.** Vireo performs daily encrypted backups and monthly restore tests using a signed runbook. The latest test, three weeks ago, was successful. This is positive operating evidence and should also be certified as a strength.

**[F05] Security testing — Red.** Vireo's policy requires annual penetration testing, but the last recorded test was 26 months ago. This is a clear paper-compliance finding: the policy exists, but the required operating activity is overdue.

**[F02] Incident readiness — Amber/Red.** The 24/7 rota and tested escalation phone tree provide useful operational capability, but Vireo has no incident classification procedure, reporting templates or demonstrated awareness of the major-incident reporting process.

**[F03] Certeva — Red.** The vendor has only a March 2024 SOC 2 Type I report, has no contractual breach-notification clause with Vireo, and is absent from the vendor register. This is a significant third-party risk gap.

**[F06] Risk governance — Red.** There is no risk register, no appetite statement and no board risk agenda evidence for four consecutive quarters. Risk decisions being made verbally by the CTO are insufficient evidence of formal governance.

The evidence should therefore be mapped across both **NIST CSF 2.0** and the relevant DORA areas without treating either framework as proof that the other has been satisfied.

## 4. Resilience

The ledger database is **1.08 TB**, equal to **1080000 MB** using the stated decimal units.

At **150 MB/s**, restore time is:

**1080000 / 150 = 7200 seconds = 2 hours**

Adding the fixed **1-hour validation period** gives a total recovery time of:

**3 hours**

The board's single-event threshold is:

**€240000 / €30000 per hour = 8 hours**

Vireo's policy requires RTO to be no more than 50% of MTPD. Therefore the implied maximum RTO is:

**8 hours × 50% = 4 hours**

The calculated recovery time of **3 hours** is below the 4-hour RTO limit. The resilience verdict is therefore **Green** and is supported by the successful restore evidence [F04].

The regulatory position is different. The incident process does not currently demonstrate the ability to initiate the required DORA major-incident reporting clock [F02]. The platform incident is detected at 09:20 and classified as major at 11:00. The initial DORA reporting deadline is therefore **15:00**, four hours after classification.

Vireo's recovery mechanics can therefore be green while its regulatory incident-readiness posture is red. These conclusions do not contradict each other.

## 5. Vendor

Certeva ID is a critical onboarding dependency and processes verification records belonging to Vireo end users. The incident therefore requires immediate escalation and documented assessment.

Under **GDPR**, Vireo must assess whether the incident constitutes a personal-data breach requiring notification to the competent data-protection authority. The GDPR notification clock is separate from DORA and runs from the relevant awareness of the personal-data breach.

Under **DORA**, Vireo must assess the incident under the major ICT-related incident framework and follow the applicable reporting process to its competent authority. The initial major-incident report has a four-hour deadline after classification, followed by the applicable intermediate and final reporting stages.

The vendor relationship itself requires remediation. Vireo should amend the Certeva agreement to include appropriate incident-notification obligations, place Certeva in the vendor inventory, obtain current assurance evidence, assess the service's criticality, implement the proposed SSO/MFA controls and establish continuous monitoring.

The recommended treatment is the **€45000/year vendor hardening package**, because it reduces S3 ALE by €240000 and produces a **€195000 net annual benefit**.

## 6. 90-Day Plan

### Month 1 — Establish and Stabilise

* Appoint accountable owners for DORA, risk governance and third-party risk.
* Create the formal enterprise risk register and risk appetite.
* Record S1, S2 and S3 with quantified exposure and treatment decisions.
* Open the Certeva incident assessment and regulatory workstreams.
* Establish DORA incident classification and reporting procedures.
* Begin the DORA Register of Information.
* Close the immediate contractual gap with Certeva.
* Commission the overdue penetration test [F05].
* Preserve and organise evidence for investor diligence.

### Month 2 — Remediate and Test

* Implement the approved Certeva hardening package.
* Enforce SSO and MFA for Certeva integrations.
* Establish continuous vendor monitoring.
* Complete the DORA Register of Information workstream to the extent supported by available data.
* Execute and document incident-reporting exercises.
* Complete or materially advance the penetration test.
* Establish board-level risk reporting.
* Start the SOC 2 readiness and gap-assessment programme.

### Month 3 — Validate and Package

* Validate remediation evidence.
* Recalculate residual risks.
* Confirm the effectiveness of implemented controls.
* Complete the investor evidence index.
* Finalise the DORA compliance posture and outstanding remediation register.
* Produce the SOC 2 roadmap and engagement status.
* Obtain board acknowledgement of residual risks and treatment owners.
* Assemble the final diligence package with traceable evidence.

## What Will Not Be True by Close

Vireo should **not** represent that a SOC 2 Type II report exists by the Series C close. The current position supports a roadmap and engagement, not a completed Type II examination.

DORA remediation will still be **in progress** where gaps identified during the 90-day programme require further implementation, validation or evidence.

The Certeva remediation milestones will remain subject to completion and validation. Vireo should not claim that the vendor risk has disappeared merely because contractual or technical remediation has started.

The investor package should therefore present Vireo as a company with **known, owned and quantified risks, supported by a dated remediation plan and evidence-backed strengths**. That is a defensible diligence position. Claiming complete readiness where the evidence does not support it would create a greater investor and regulatory risk than acknowledging the remaining gaps.

