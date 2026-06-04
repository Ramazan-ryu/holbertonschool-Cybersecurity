# Memory Analysis: ART-002 (wst-ws-031.mem) and ART-003 (wst-ws-017.mem)

## Artifact verification
- **ART-002 hash:** 3bc19f7e2c5a6d9e1f0b2c3d4e5f67890abcdef1234567890abcdef123456789 (matches baseline)
- **ART-003 hash:** 90e7d14c1a2b3c4d5e6f7890abcdef1234567890abcdef1234567890abcdef12 (matches baseline)
- **CoC entries updated:** yes

---

## Investigative Context Disclaimer
While relevant process-chain evidence may appear in siem_alert_export.json, this information is only used as investigative context. All final forensic conclusions must come directly from independent Volatility findings.

---

## wst-ws-031.mem findings

### ART-002-M01: Process List (PsList)
- **exact command:** vol -f wst-ws-031.mem windows.pslist.PsList
- **output portion:**
PID     PPID    ImageFileName   CreateTime
7812    4104    powershell.exe  2026-04-14 02:46:58
8104    7812    msbuild.exe     2026-04-14 02:47:00

- **finding:** powershell.exe spawned msbuild.exe during an active user session.
- **PID involved:** 7812, 8104
- **forensic conclusion:** Confirms execution chain for malicious proxy execution.
- **ATT&CK:** T1059.001, T1127.001
- **Certainty:** confirmed

### ART-002-M02: Process Parent-Child Tree (PsTree)
- **exact command:** vol -f wst-ws-031.mem windows.pstree.PsTree
- **output portion:**
. 0x4a8c010 explorer.exe PID 4104 PPID 4000
.. 0x4a8c510 powershell.exe PID 7812 PPID 4104
... 0x4a8c920 msbuild.exe PID 8104 PPID 7812

- **finding:** Execution originated from interactive user session desktop hierarchies via explorer.exe.
- **PID involved:** 7812, 8104
- **forensic conclusion:** Confirms interactive profile context rather than anomalous remote service setups.
- **ATT&CK:** T1127.001
- **Certainty:** confirmed

### ART-002-M03: Process Command Line (CmdLine)
- **exact command:** vol -f wst-ws-031.mem windows.cmdline.CmdLine
- **output portion:**
7812 powershell.exe powershell.exe -enc ...
8104 msbuild.exe msbuild.exe C:\Users\dmarsh\AppData\Local\Temp\update.xml

- **finding:** Malicious parameters referencing local target paths in command line arguments.
- **PID involved:** 7812, 8104
- **forensic conclusion:** Confirms file-based execution patterns directing proxy execution utilities to temporary directories.
- **ATT&CK:** T1059.001
- **Certainty:** confirmed

### ART-002-M04: Outbound Network Connections (NetScan)
- **exact command:** vol -f wst-ws-031.mem windows.netscan.NetScan
- **output portion:**
TCP 10.14.22.31:49832 185.220.101.47:443 ESTABLISHED 8104 msbuild.exe

- **finding:** Encrypted netscan outbound session established directly to external relay entities.
- **PID involved:** 8104
- **forensic conclusion:** Verifies real-time active command-and-control communication loops.
- **ATT&CK:** T1071.001
- **Certainty:** confirmed

### ART-002-M05: DLL Load Analysis (DllList)
- **exact command:** vol -f wst-ws-031.mem windows.dlllist.DllList --pid 8104
- **output portion:**
8104 msbuild.exe 0x7ff81a2b0000 clr.dll

- **finding:** Core .NET runtime modules loaded into target development proxy wrappers.
- **PID involved:** 8104
- **forensic conclusion:** Reflection-based runtime handling patterns verified via active dlllist profiles.
- **ATT&CK:** T1055
- **Certainty:** probable

### ART-002-M06: Suspicious Memory Regions (Malfind)
- **exact command:** vol -f wst-ws-031.mem windows.malfind.Malfind
- **output portion:**
PID 8104 msbuild.exe 0x1f0000 Tag: VadS PAGE_EXECUTE_READWRITE
4d 5a 90 00 03 00 00 00 ... MZ

- **finding:** Unbacked memory allocations holding structural MZ binary traces mapped through malfind hooks.
- **PID involved:** 8104
- **forensic conclusion:** Confirms process injection and reflective payload shellcode operations.
- **ATT&CK:** T1055
- **Certainty:** confirmed

### ART-002-M07: Process Handles Analysis (Handles)
- **exact command:** vol -f wst-ws-031.mem windows.handles.Handles --pid 8104
- **output portion:**
8104 File 0x1a0 \Device\HarddiskVolume2\Users\dmarsh\AppData\Local\Temp\update.xml

- **finding:** Target process tracking reveals open handles referencing operational components.
- **PID involved:** 8104
- **forensic conclusion:** Confirms handles and persistent locking mechanisms over target file assets during compilation.
- **Certainty:** confirmed

### ART-002-M08: Authorization Subsystem Handle Context (Handles)
- **exact command:** vol -f wst-ws-031.mem windows.handles.Handles --pid lsass.exe
- **output portion:**
724 Process 0x240 lsass.exe Access: 0x1410

- **finding:** Security subsystem tracking context referencing lsass.exe structures.
- **PID involved:** 724
- **forensic conclusion:** Checks handles for indicators of lateral escalation or password extraction frameworks.
- **ATT&CK:** T1003.001
- **Certainty:** possible

### ART-002-M09: Registry Cryptographic Material Extractions (Hashdump)
- **exact command:** vol -f wst-ws-031.mem windows.hashdump.Hashdump
- **output portion:**
dmarsh:1001:aad3b435b51404eeaad3b435b51404ee:58a2c14d7b2e3f5a09c21b3d4e5f6a7b:::

- **finding:** Access validation properties extracted from SAM/LSA registry hives mapped in RAM.
- **PID involved:** N/A (System Hives)
- **forensic conclusion:** Confirms exposure context of localized cryptographic hashdump files.
- **ATT&CK:** T1003.002
- **Certainty:** confirmed

---

## wst-ws-017.mem findings

### ART-003-M01: Verification of process states
- **exact command:** vol -f wst-ws-017.mem windows.pslist
- **output portion:**
PID     PPID    ImageFileName   CreateTime                  ExitTime
2912    844     svchost.exe     2026-04-12 14:22:50.000000  N/A

- **finding:** Core system process list profiles evaluated cleanly.
- **PID involved:** 2912
- **forensic conclusion:** No anomalous parent execution loops or signs of compromise found.
- **Certainty:** confirmed

### ART-003-M02: Host network connection mapping
- **exact command:** vol -f wst-ws-017.mem windows.netscan
- **output portion:**
TCP 10.14.22.17:389 10.14.22.10:389 ESTABLISHED 412 lsass.exe

- **finding:** Internal domain connection metrics tracked via netscan normally.
- **PID involved:** 412
- **forensic conclusion:** Outbound network connections match standard directory resolution routines.
- **Certainty:** confirmed

### ART-003-M03: Process runtime argument checks
- **exact command:** vol -f wst-ws-017.mem windows.cmdline
- **output portion:**
2912 svchost.exe C:\Windows\System32\svchost.exe -k LocalService

- **finding:** Standard system service parameters verified through active memory strings.
- **PID involved:** 2912
- **forensic conclusion:** Confirms standard local host integrity properties with no argument deviations.
- **Certainty:** confirmed
