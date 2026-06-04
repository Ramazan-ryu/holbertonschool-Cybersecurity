# Hardening Updates – IR-2026-0420-01

## Gap ID: GAP-001 – Macro Execution Allowed in User Workstations

### Control
Block Office macro execution for non-developer endpoints using Group Policy / ASR rule.

### Exact configuration and GPO path
Computer Configuration → Administrative Templates → Microsoft Office 2016/2019 → Security Settings → "Block macros from running in Office files from the Internet" = ENABLED
ASR Rule (if Defender): Block Office applications from creating child processes = ENABLED

### Gap Closed
Prevents malicious Word documents from spawning PowerShell (observed initial execution vector).

### Validation Test
Open test phishing document → verify no powershell.exe spawn occurs.

---

## Gap ID: GAP-002 – NTLM Relay & Lateral Movement Exposure

### Control
Enforce SMB signing and restrict NTLM authentication.

### Exact configuration and GPO path
Computer Configuration → Windows Settings → Security Settings → Local Policies → Security Options → "Microsoft network server: Digitally sign communications (always)" = ENABLED
Also: "Network security: Restrict NTLM: Incoming NTLM traffic" = DENY ALL

### Gap Closed
Prevents lateral movement using NTLM credentials observed across WS-104, WS-107, WS-112.

### Validation Test
Attempt NTLM authentication replay between test hosts → must fail.

---

## Gap ID: GAP-003 – Process Masquerading Detection Gap

### Control
Enable enhanced process creation logging with command-line auditing and Defender PUA protection.

### Exact configuration and GPO path
Enable Sysmon Event ID 1 logging with full command line
Enable Microsoft Defender PUA protection = ON
Enable AMSI integration for PowerShell

### Gap Closed
Detects svchost32.exe-style masquerading and PowerShell-spawned binaries in user directories.

### Validation Test
Execute renamed benign binary in AppData → verify alert in SIEM.
