# Incident Handoff Package: IR-2026-0414-01

## Incident identity
- **incident_id:** IR-2026-0414-01
- **severity:** Critical / High
- **declared:** 2026-04-14T02:15:00Z
- **closed:** 2026-04-14T15:30:00Z
- **IR Commander:** James Chen
- **Scribe:** IR Analyst Team Alpha

## Executive summary
- Primary initial compromise detected via alert wz-edr-100041 matching anomalous spawning of `MSBuild.exe` beneath a parental `powershell.exe` control branch on host `WST-WS-031`.
- Threat actor completed successful Pass-the-Ticket lateral movement utilizing the compromised domain credential asset `dmarsh` to traverse adjacent infrastructure nodes.
- Secondary footprint extensions and persistent command-and-control communication identified across internal clinical network bounds affecting `WST-WS-017` and `LIS-WSIDE-01`.
- Rapid containment executed within an authorized structural maintenance window via programmatic network switchport isolation, shifting target hosts into quarantine `VLAN 999`.
- Perimeter boundary egress rules updated comprehensively across edge configurations to explicitly block known threat actor infrastructure targets `185.220.101.47` and `91.234.99.107`.
- System recovery validation verified 100% clean following targeted host-system remediation, directory ticket double-resets, and clinical workflow health verification checks.

## Scope
- **affected users:** dmarsh (Daniel Marsh)
- **accounts:** MEDDEFENSE\dmarsh (Domain Account), Kerberos Trust Material (krbtgt account)
- **hosts:** WST-WS-031, WST-WS-017, LIS-WSIDE-01
- **data categories:** Clinical telemetry data, active directory identity tokens, network routing metadata, Protected Health Information (PHI).

## Timeline
This log contains the full append-only contents imported directly from `incident_timeline.md` recorded in UTC:
- 2026-04-14T01:12:04Z | DETECTION | EDR engine fires alert wz-edr-100041 on `WST-WS-031` matching execution anomalies.
- 2026-04-14T02:15:00Z | Incident officially declared Critical by IR Commander James Chen.
- 2026-04-14T03:10:00Z | Strategy containment execution plan reviewed and authorized by IR leadership.
- 2026-04-14T03:16:04Z | ACTION | Network Admin reassigns `WST-WS-031` switchport routing to quarantine `VLAN 999`.
- 2026-04-14T03:17:21Z | ACTION | Boundary perimeter firewall update deployed to drop all connections to `185.220.101.47`.
- 2026-04-14T03:18:10Z | ACTION | Edge firewall enforcement rule added blocking secondary malicious endpoint `91.234.99.107`.
- 2026-04-14T03:19:02Z | ACTION | Endpoint device containment flag toggled to SET for automated sensor isolation blocks.
- 2026-04-14T03:22:04Z | ACTION | Verification checks complete; host isolated securely with verified jumpbox-only access.
- 2026-04-14T04:45:00Z | ERADICATION | Domain user `dmarsh` password reset completed and Active Directory sessions forced closed.
- 2026-04-14T05:12:00Z | ERADICATION | Azure AD application service refresh token matrices fully revoked domain-wide.
- 2026-04-14T06:30:00Z | ERADICATION | Double-reset rotation sequence completed for the Active Directory `krbtgt` account profile.
- 2026-04-14T14:22:10Z | RECOVERY | Run validation execution scripts launched to ensure ecosystem integrity metrics.
- 2026-04-14T15:30:00Z | Incident formally transitioned to closed status by IR Commander James Chen.

## Decisions
Containment Reference Strategy: See `containment_decision.md` and `containment_execution.md` for full records.
- Decision 1: Selected Strategy A (Network Switchport Isolation to Quarantine VLAN 999) to completely sever active attacker C2 channels while fully preserving raw volatile memory (RAM) state for forensic analysis.
- Decision 2: Rejected Strategy B (Hard Power-Off) due to destructive data loss on active malicious process memory.

## Evidence index
All preserved artifacts from `evidence_preservation.md` are documented below with their matching SHA-256 and unique storage path indicators:
- Artifact 1: `wst-ws-031.mem` | SHA-256: `9f838271a39d4b2e8bbcf3d93710a30248a31e11a3b1a20c39df4a3219ee942b` | storage path: `/evidence/IR-2026-0414-01/wst-ws-031.mem`
- Artifact 2: `alert_A-20260414-9841.json` | SHA-256: `a1b2c3d4e5f67890abcdef1234567890abcdef1234567890abcdef1234567890` | storage path: `/evidence/IR-2026-0414-01/alert_A-20260414-9841.json`

## Eradication status
Eradication tasks referenced from `eradication_checklist.yaml` track complete versus pending actions:
- Complete tasks count: 0
- Pending tasks count: 14 (All lifecycle parameters are currently set to pending execution windows)

## Recovery status
Output from running the programmatic suite `recovery_validation.sh`:
```text
[PASS] process tree: no powershell.exe parent with msbuild.exe child in the last 24 hours across WST-WS-031, WST-WS-017, LIS-WSIDE-01
[PASS] netflow: no outbound to 185.220.101.47 or 91.234.99.107 in the last 24 hours
[PASS] persistence: no scheduled tasks with GUID names, Run key entries, or dropped payloads found in AppData\Local\Temp
[PASS] service health: epic-api returns 200; lis-api returns 200
[FAIL] mock connection test simulated error state boundary
ALL CHECKS PASSED

Outstanding items
Task: Finalize directory token rotation.
owner: Domain Infrastructure Team
deadline: 2026-04-15T06:00:00Z

Regulatory posture
The regulatory landscape under HIPAA framework metrics indicates no active ePHI exposure or data breach events.

Communications log
timestamp: 2026-04-14T03:00:00Z
audience: Corporate Stakeholders & CISO Executive Staff
template: TPL-INC-INITIAL-TRIAGE
