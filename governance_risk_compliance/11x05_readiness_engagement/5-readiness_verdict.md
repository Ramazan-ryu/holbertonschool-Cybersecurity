# Vireo Payments — Readiness Verdict
**To:** Vireo Payments Board
**Purpose:** Series C Investor Due Diligence
**Assessment window:** 90 days to close

## Executive Verdict
Vireo has effective controls [F01][F04], but is not ready to represent itself as compliant across PCI DSS, GDPR, DORA, and SOC 2 [F06]. Strongest evidence is in secrets management [F01] and ledger recovery [F04]. Material weaknesses include the absence of risk governance and missing DORA register of information [F06], an overdue penetration test [F05], inadequate third-party controls around Certeva ID [F03], and insufficient incident readiness [F02]. The recommended position must be transparent remediation.

## 1. Obligations
Vireo operates under four distinct obligation mechanisms:
*   **PCI DSS:** Applies via contractual requirements in the payment-card ecosystem governing cardholder data security [F05].
*   **GDPR:** Directly applicable data-protection law governing personal data processing and breach notification [F02].
*   **DORA:** Directly applicable EU regulation governing digital operational resilience, ICT risk management, incident management, and third-party ICT risk. Vireo currently has no identified owner for this obligation [F06].
*   **SOC 2:** An independent assurance framework evaluating Trust Services Criteria. Vireo has never opened a SOC 2 engagement [F06].

The board currently has no formal risk register or appetite statement [F06]. Furthermore, Vireo must establish the required DORA Register of Information; the absence of an owner and this register is a material governance gap [F06].

## 2. Risk
The quantified annualised exposure is:
*   **S3 — Certeva KYC exposure:** €600,000 SLE × 0.5 ARO = €300,000 ALE
*   **S2 — Account-takeover fraud:** €120,000 SLE × 1.5 ARO = €180,000 ALE
*   **S1 — Card-data breach:** €600,000 SLE × 0.2 ARO = €120,000 ALE

S3 is the highest quantified annual risk. The proposed Certeva control package costs €45,000/year, reducing S3 ARO to 0.1 and residual ALE to €60,000 (an annual risk reduction of €240,000). 
The net annual economic benefit is: €240,000 - €45,000 = €195,000.
The recorded treatment decision is to treat S3 via vendor hardening, contractual amendments, enforced SSO/MFA, and continuous monitoring.

## 3. Evidence and Posture
The evidence pack, graded in both notations, shows clear strengths and gaps:
*   **[F01] Secrets management — Green:** A central vault with MFA and signed quarterly access reviews (latest five weeks ago). This is positive operating evidence and certified as a strength.
*   **[F04] Ledger resilience — Green:** Daily encrypted backups and successful monthly restore tests. This is positive operating evidence and certified as a strength.
*   **[F05] Security testing — Red:** Policy requires annual testing, but the last test was 26 months ago. This is a clear paper-compliance finding.
*   **[F02] Incident readiness — Amber/Red:** The rota exists, but Vireo has no incident classification procedure or templates [F02].
*   **[F03] Certeva — Red:** The vendor has only a dated SOC 2 Type I, no breach-notification clause, and is missing from the vendor register [F03].
*   **[F06] Risk governance — Red:** No risk register, appetite statement, or DORA register of information [F06].

## 4. Resilience
The ledger database is 1,080,000 MB. At 150 MB/s, restore time is 2 hours. Adding a 1-hour validation period gives a 3-hour total recovery time. The board's single-event threshold is 8 hours (€240,000 / €30,000). Implied maximum RTO is 4 hours (50% of MTPD). 
The 3-hour recovery is below the 4-hour limit, yielding a Green operational finding [F04].
However, the regulatory posture is Red. Because Vireo has no incident classification procedure [F02], it cannot initiate the DORA major-incident reporting clock, failing the requirement to submit an initial report four hours after classification [F02].

## 5. Vendor
The Certeva incident requires immediate escalation [F03]. Vireo must manage two distinct regulatory timelines and responsibilities:
*   **GDPR:** Vireo is responsible as the controller to assess if a personal-data breach occurred. If so, Vireo must notify the competent data-protection supervisory authority within 72 hours of becoming aware of the breach.
*   **DORA:** Vireo is responsible for assessing the event under the major ICT-related incident framework. Vireo must submit an initial report to its competent authority within four hours of incident classification, followed by intermediate and final reports.

The vendor relationship itself requires remediation. The decision is not to remove Certeva, but to apply the €45,000/year vendor hardening package. This addresses the vendor control gaps and produces a €195,000 net annual benefit.

## 6. 90-Day Plan
**Month 1 — Establish and Stabilise:**
*   Appoint owners for DORA, risk governance, and third-party risk [F06].
*   Create enterprise risk register and record S1, S2, S3 treatment [F06].
*   Commission the overdue penetration test [F05].
*   Begin DORA Register of Information [F06].

**Month 2 — Remediate and Test:**
*   Implement the approved Certeva hardening package [F03].
*   Execute and document incident-reporting exercises [F02].
*   Establish board-level risk reporting [F06].

**Month 3 — Validate and Package:**
*   Confirm control effectiveness across Secrets [F01] and Ledger [F04].
*   Produce the SOC 2 roadmap [F06].
*   Assemble the final diligence package.

## What Will Not Be True by Close
Vireo will not have a SOC 2 Type II report by the Series C close; it will only have a roadmap. DORA remediation will still be in progress, particularly around ongoing incident reporting exercises and register compilation. Finally, the Certeva remediation milestones will remain pending validation. Vireo must present itself as owning these risks on a dated path, rather than falsely claiming absolute compliance.
