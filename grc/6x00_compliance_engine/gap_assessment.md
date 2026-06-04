# NIST CSF 2.0 Gap Assessment: MedDefense Health Systems

**Assessment date:** 2026-06-01  
**Assessor:** Lead Compliance Auditor  
**Framework version:** NIST CSF 2.0  
**Regulatory context:** HIPAA Security Rule, 45 CFR Part 164 Subpart C  

## Gap Assessment Matrix

| CSF Function | Subcategory ID | Subcategory title | Implementation status | Evidence reference | Gap severity | Gap description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| GOVERN | GV.OC-01 | Org risk strategy established | Partial | `risk_register_updates.yaml` | High | Risk register exists and is updated post-incident; no board-approved risk appetite statement or formal governance charter. |
| GOVERN | GV.PO-01 | Cybersecurity policy established | Not Implemented | None | Critical | Acceptable Use, Data Classification, and Vendor Management policies do not exist in written, enforceable form. |
| GOVERN | GV.SC-04 | Suppliers inventoried by criticality | Not Implemented | None | High | No formal vendor inventory; clinical and ePHI-adjacent third parties are not tiered or catalogued. |
| GOVERN | GV.SC-07 | Supplier risks managed | Partial | `risk_register_updates.yaml` | High | Vendor risks identified post-incident (Risk ID R-001) but missing formal risk review workflows and explicit BAA enforcement gates. |
| IDENTIFY | ID.AM-01 | Asset inventory maintained | Partial | `endpoint_hardening_baseline.md` | Medium | Workstation inventory captures 280 clinical endpoints but excludes unmanaged biomedical devices and network equipment. |
| IDENTIFY | ID.RA-01 | Vulnerabilities identified and recorded | Implemented | `risk_register_updates.yaml`, `forensic_findings_summary.md` | None | Vulnerability identification and operational context established through post-incident analysis and active risk tracking. |
| IDENTIFY | ID.RA-06 | Risk responses tracked | Partial | `risk_treatment_plan.md` | Medium | Treatment plans exist post-incident but lack active CISO sign-off, Board review, or formal tracking cadence. |
| PROTECT | PR.AA-01 | Identity and credential management | Partial | `ir_playbook_index.md`, `endpoint_hardening_baseline.md` | High | Credential procedures exist within incident response playbooks and basic GPOs, but no proactive IAM program or privileged access policy exists. |
| PROTECT | PR.AA-05 | Access permissions reviewed | Not Implemented | None | High | No regular, documented access review process or enforcement mechanism for least privilege exists for core clinical infrastructure. |
| PROTECT | PR.AT-01 | Workforce awareness and training | Partial | `security_awareness_training_status.md` | Critical | Total completion rate is at 73% (below the 95% target), contractor data is incomplete, and role-based tracking is absent. |
| PROTECT | PR.DS-01 | Data-at-rest protected | Partial | `endpoint_hardening_baseline.md` | Medium | BitLocker encryption is only confirmed on 173 out of 280 Windows clinical endpoints, leaving 107 workstations unverified. |
| PROTECT | PR.PS-01 | Secure configurations established | Partial | `endpoint_hardening_baseline.md` | Medium | Baseline deployed across support servers and 231 workstations, but older legacy Group Policy Objects still override settings. |
| PROTECT | PR.PS-04 | Logs generated and reviewed | Partial | `sigma_detection_catalog.md`, `endpoint_hardening_baseline.md` | High | Endpoint logs are generated via Sysmon and auditd, but coverage is under 80% on clinical systems and missing on medical networks. |
| DETECT | DE.CM-01 | Networks and endpoints monitored | Partial | `sigma_detection_catalog.md`, `endpoint_hardening_baseline.md` | High | SOC monitors active rules via SIEM, but lack of Script Block Logging and limited endpoint scope restrict visibility. |
| DETECT | DE.CM-06 | External providers monitored | Partial | `sigma_detection_catalog.md` | High | CloudTrail monitoring is limited to production, leaving external provider activities completely unmonitored in the disaster recovery region. |
| DETECT | DE.AE-02 | Adverse events analyzed | Implemented | `forensic_findings_summary.md`, `sigma_detection_catalog.md` | None | Security events are analyzed against active Sigma rules and post-incident forensic telemetry with weekly SOC performance reviews. |
| RESPOND | RS.MA-01 | Incident response plan executed | Partial | `ir_playbook_index.md` | Medium | Post-incident playbooks are actively maintained and deployed by IT Security but lack formal CISO approval and sign-off. |
| RESPOND | RS.AN-03 | Analysis supports response | Implemented | `forensic_findings_summary.md`, `ir_playbook_index.md` | None | Forensic logs, LSASS access events, and playbook playbooks demonstrate robust tactical incident analysis capabilities. |
| RESPOND | RS.CO-02 | Incident communication performed | Partial | `ir_playbook_index.md` | Low | Internal reporting workflows exist for active playbooks, but formal communication testing evidence remains a low severity gap. |
| RECOVER | RC.RP-01 | Recovery plan executed | Partial | `recovery_validation_summary.md` | High | Disaster recovery validation for the Laboratory Information System was executed but exceeded the 30-minute target RTO by 11 minutes. |
| RECOVER | RC.CO-01 | Recovery communication performed | Partial | `recovery_validation_summary.md` | Medium | LIS recovery tabletop occurred, but crucial clinical notification language was entirely missing from the workflow. |

## Summary

**Implementation counts:**
- Implemented: 3
- Partial: 15
- Not Implemented: 3

**Top 3 pre-audit priorities:**
1. **GV.PO-01 (Critical):** Author, approve, and distribute the three missing organization-wide written security policies (Acceptable Use, Data Classification, and Vendor Management) to satisfy primary administrative safeguards.
2. **PR.AT-01 (Critical):** Execute targeted remediation training for all overdue workforce divisions to elevate the security awareness training completion rate from 73% to the internal target of 95% or higher.
3. **RC.RP-01 (High):** Re-test and update disaster recovery runbooks for the Laboratory Information System to successfully close the 11-minute RTO overrun gap and formalize an annual test calendar.

**Connection to upcoming governance work:**
The Critical and High gaps identified above are not incidental. They represent structural deficiencies in administrative, physical, and technical safeguards where operational controls exist in isolation without formalized policy backing or compliance oversight. This matrix outlines the exact control areas this compliance initiative will remediate. Specifically, the imminent drafting of the missing core corporate policies, the introduction of a rigorous Vendor Management Policy featuring an explicit Business Associate Agreement (BAA) checkpoint, and the formalization of CISO-signed, board-ready risk treatments will transform MedDefense's post-incident security posture from an ad-hoc technical state into an auditable, fully compliant governance program.
