# Containment Decision: IR-YYYY-MMDD-01

## Candidate strategies

### A. Network isolation (quarantine VLAN)
- action: move WST-WS-031 to VLAN 999, block all outbound, allow IR jumpbox access only
- attacker effect: C2 severed; attacker on-host observation paused
- evidence effect: volatile state preserved
- patient care effect: one lab workstation unavailable; site has four spare workstations available
- time to execute: ~5 min
- reversibility: fully reversible

### B. Host power-off
- action: immediate hard power-off / pull the plug on WST-WS-031
- attacker effect: attacker access terminated instantly
- evidence effect: volatile evidence destroyed immediately; unallocated space and disk safe
- patient care effect: clinical impact is monitored; site has four spare workstations available
- time to execute: ~1 min
- reversibility: irreversible for memory state

### C. Selective process kill + egress block
- action: terminate rogue powershell.exe and msbuild.exe processes and implement network firewall block
- attacker effect: current C2 channels killed, but backdoors or hidden persistence might remain
- evidence effect: modifies process tree telemetry context and flushes targeted process memory states
- patient care effect: low immediate clinical impact; spare workstation options remain unaffected
- time to execute: ~10 min
- reversibility: partially reversible via process relaunch

## Chosen: A
Rationale: Choice A preserves volatile evidence for later forensic analysis, severs C2 immediately, remains fully reversible, and bounds the clinical impact because spare workstations are available in the lab. Option B destroys volatile evidence. Option C risks missed processes and does not address persistence.

## Execution window
- Evidence preservation end: 03:14Z
- Containment execution start: 03:16Z

## Approval
- Action authorized by James Chen, IR Commander, at 03:10Z

## Rollback plan
- If lab operations are blocked and spare workstations are unavailable, revert VLAN assignment within five minutes and fall back to Option C.


Repo:

GitHub repository: holbertonschool-cybersecurity
Directory: ir_dfir_playbook/5x01_Contain_Control
File: containment_decision.md
