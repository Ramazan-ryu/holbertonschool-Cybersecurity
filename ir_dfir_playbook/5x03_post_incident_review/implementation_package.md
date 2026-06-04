# Improvement Implementation Package: IR-2026-0414-01

This package consolidates every tactical and strategic remediation asset formulated across the post-incident review phase into a cohesive, trackable roadmap for deployment and leadership evaluation.

---

## Implementation Table

| Improvement ID | Type | Title | Source | Owner Role | Target Deadline (days) | Success Criterion | Validation Method | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **IMP-001** | detection | Deploy `sigma_powershell_msbuild_lolbin.yml` | Task 3 / GAP-005 | SOC Lead | 7 | Rule active in SIEM; fires on synthetic test execution events | Run `sigma-cli` evaluation against artifact source `rule_validation_report.md` | pending |
| **IMP-002** | detection | Deploy `sigma_msbuild_network_connection.yml` | Task 4 / GAP-006 | SOC Lead | 7 | Rule active in SIEM; baseline alerts verified | Match synthetic network process connection events mapped in `rule_validation_report.md` | pending |
| **IMP-003** | hardening | Enforce PowerShell Constrained Language Mode | Task 5 / Task 6 / GAP-005 | Infrastructure Lead | 14 | `__PSLockdownPolicy` registry parameter set to `4` for standard users | Audit registry targets defined within baseline `hardening_updates.md` using GPO compliance review | pending |
| **IMP-004** | hardening | Implement AppLocker Rules for `MSBuild.exe` | Task 5 / Task 6 / GAP-006 | Infrastructure Lead | 14 | Execution blocked for standard users across clinical workstations | Verify explicit rule paths inside `hardening_updates.md` against XML config | pending |
| **IMP-005** | hardening | Enforce Entra ID Geofencing & Step-Up MFA | Task 5 / Task 6 / GAP-003 | Identity Manager | 10 | Block or require phishing-resistant MFA from unapproved countries | Test programmatic VPN login rules configured within `hardening_updates.md` | pending |
| **IMP-006** | hardening | Enable Windows Credential Guard via VBS | Task 5 / Task 6 / GAP-008 | Workstation Engineering Lead | 21 | Virtualization-Based Security isolates host LSASS secrets | Query `Win32_DeviceGuard` based on criteria in `hardening_updates.md` | pending |
| **IMP-007** | playbook | Update `playbook_credential_exposure.yaml` Triggers | Task 9 / GAP-002 | Incident Response Commander | 5 | Playbook includes impossible-travel and anomalous VPN alerts | Verify change signatures listed inside `playbook_updates.md` repo | pending |
| **IMP-008** | playbook | Integrate Containment Scope Expansion Protocol | Task 9 / GAP-005 | Incident Response Commander | 5 | Procedures define rapid blast-radius isolation for Pass-the-Ticket | Review playbooks for the added multi-host scoping checklist in `playbook_updates.md` | pending |
| **IMP-009** | playbook | Inject Mandatory `krbtgt` Double-Reset Step | Task 9 / GAP-008 | Active Directory Team Lead | 5 | Remediation workflows strictly enforce Kerberos token invalidation | Confirm inclusion of two discrete `krbtgt` resets in `playbook_updates.md` | pending |
| **IMP-010** | playbook | Add HIPAA Four-Factor Assessment Decision Node | Task 9 / GAP-009 | Compliance Officer | 5 | Incident classification branches to regulatory reviews for ePHI | Check that the HIPAA review trigger condition is present in `playbook_updates.md` | pending |
| **IMP-011** | risk | Revise Organizational Strategic Risk Register | Task 7 / Task 8 | Chief Information Security Officer | 3 | Real-world likelihood and impact matrices updated | Audit `risk_register_updates.yaml` and enrich via `threat_intel_brief.md` threat intelligence review | pending |

---

## Deployment Sequence

The execution framework below outlines the specific recommended timeline, establishing how tasks must precede subsequent elements to address technical dependency constraints and logic paths:

1. **IMP-011** (Risk Register Update) — Deployed first using references from Task 7 (`risk_register_updates.yaml`) and Task 8 (`threat_intel_brief.md`). This must happen **before** other changes to align high-level policy and get budgetary authorization.
2. **IMP-007, IMP-008, IMP-009, and IMP-010** (Incident Response Playbook Updates) — These Task 9 updates to `playbook_updates.md` and `playbook_credential_exposure.yaml` must be completed **before** technical engineering modifications begin, defining how to handle the operational dependency for containment.
3. **IMP-001 and IMP-002** (Detection Rule Deployment) — These Task 3 and Task 4 rules must be active in SIEM to baseline log sources **before** new hardening modifies event paths. Validation relies on `rule_validation_report.md` from Task 5.
4. **IMP-005** (Entra ID Geofencing and Step-Up MFA Configuration) — This Task 6 identity hardening from `hardening_updates.md` is applied **after** detection rules are verified but **before** endpoint changes to isolate external vectors.
5. **IMP-003** (PowerShell Constrained Language Mode Verification) — This Task 6 hardening is deployed **after** detection rules are active, ensuring baseline logging parameters capture the configuration change.
6. **IMP-004** (AppLocker Enforcement for MSBuild) — This Task 6 endpoint restriction is implemented **after** PowerShell language constraints are stable to prevent telemetry pollution.
7. **IMP-006** (Windows Credential Guard Isolation Activation) — This Task 6 system change is deployed last due to hardware firmware dependency constraints, requiring systematic verification and reboots **after** all previous baseline tasks are confirmed stable.
