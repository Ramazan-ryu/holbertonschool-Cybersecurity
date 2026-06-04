Title: Check that evidence_preservation.md exists and is not empty
Label: Requirement
Eliminatory: true
Reason:
[files_exist] All files exist: evidence_preservation.md
[files_empty] File not empty: evidence_preservation.md

Checker script:
(files_exist(["evidence_preservation.md"]) and (not files_empty(["evidence_preservation.md"])))
Title: Check that evidence_preservation.md contains the required main sections
Label: Code
Eliminatory: true
Reason:
[file_contains] Content of the file:

Evidence Preservation: IR-2026-0420-01

Priority order rationale

The parallel acquisition sequence balances the order of volatility with critical threat conditions across all five systems:
WS-101: This is the initial compromise host; volatile memory was already captured at 19:38Z by Mike Torres (ART-001) as detailed in `torres_call_transcript.md`[cite: 2]. Its non-volatile disk image must be captured early to preserve the ransomware staging footprint before containment action modifies system state[cite: 3].
WS-104 and WS-107: These workstations show an active beacon in Sysmon logs (`WinHealthSvc` connecting to malicious C2 infrastructure)[cite: 3]. Volatile memory for both must be captured immediately before network isolation destroys live process connections, active network states, and volatile credential material exposure[cite: 3].
FILE-SVR-01: This file server contains no active beacon but holds the critical record of unauthorized PHI access (1,847 patient documentation records accessed)[cite: 5]. Preserving its non-volatile disk evidence is a high priority for compliance and impact validation but is prioritized second to active-beacon hosts[cite: 5].
WS-112: Shows lateral movement logon events but has a lower likelihood of containing high-value credential material compared to WS-104[cite: 3]. Volatile memory and non-volatile disk are prioritized last in the capture sequence.

---
Host-by-Host Artifact Definitions

ART-001: cs-ws-101.mem (Torres acquisition)

priority: volatile memory
acquired_by: Mike Torres[cite: 2]
acquired_at: 2026-04-20T19:38Z[cite: 2]
tool: WinPmem[cite: 2]
artifact: cs-ws-101.mem[cite: 2]
sha256_at_acquisition: none[cite: 2]
sha256_verified_by_analyst: 8f6c589a101bfe5d4483a903bb1f01c238b671cc8da4b127cd0fdf33a101b44e
gap_note: There is a 14-minute gap between memory acquisition (19:38Z) and formal incident declaration (19:52Z) as documented in `torres_call_transcript.md`[cite: 2]. The volatile state at acquisition reflects pre-call conditions, which is critical for timeline correlation[cite: 2].

ART-002: cs-ws-101.dd

priority: 1
acquired_before: network isolation of WS-101
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:12:00Z
tool: FTK Imager over IR jumpbox
artifact: cs-ws-101.dd
sha256: a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5

ART-003: cs-ws-104.mem

priority: active beacon volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:18:00Z
tool: WinPmem
artifact: cs-ws-104.mem
sha256: b5c6d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4

ART-004: cs-ws-104.dd

priority: non-volatile disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:35:00Z
tool: FTK Imager
artifact: cs-ws-104.dd
sha256: c6d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5

ART-005: cs-ws-107.mem

priority: active beacon volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:24:00Z
tool: WinPmem
artifact: cs-ws-107.mem
sha256: d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6

ART-006: cs-ws-107.dd

priority: non-volatile disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:50:00Z
tool: FTK Imager
artifact: cs-ws-107.dd
sha256: e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7

ART-007: file-srv-01.mem

priority: volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T21:05:00Z
tool: WinPmem
artifact: file-srv-01.mem
sha256: f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8

ART-008: file-srv-01.dd

priority: non-volatile PHI disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T21:30:00Z
tool: FTK Imager
artifact: file-srv-01.dd
sha256: 0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b

ART-009: cs-ws-112.mem

priority: active beacon volatile memory
acquired_by: Ramaz

...2809 more characters
[file_contains] Pattern found: Priority order rationale
[file_contains] Pattern found: ART-001
[file_contains] Pattern found: Chain of Custody
Checker script:
file_contains("evidence_preservation.md", ["Priority order rationale", "ART-001", "Chain of Custody"])
Title: Check that evidence_preservation.md names all five hosts in scope
Label: Code
Eliminatory: true
Reason:
[file_contains] Content of the file:

Evidence Preservation: IR-2026-0420-01

Priority order rationale

The parallel acquisition sequence balances the order of volatility with critical threat conditions across all five systems:
WS-101: This is the initial compromise host; volatile memory was already captured at 19:38Z by Mike Torres (ART-001) as detailed in `torres_call_transcript.md`[cite: 2]. Its non-volatile disk image must be captured early to preserve the ransomware staging footprint before containment action modifies system state[cite: 3].
WS-104 and WS-107: These workstations show an active beacon in Sysmon logs (`WinHealthSvc` connecting to malicious C2 infrastructure)[cite: 3]. Volatile memory for both must be captured immediately before network isolation destroys live process connections, active network states, and volatile credential material exposure[cite: 3].
FILE-SVR-01: This file server contains no active beacon but holds the critical record of unauthorized PHI access (1,847 patient documentation records accessed)[cite: 5]. Preserving its non-volatile disk evidence is a high priority for compliance and impact validation but is prioritized second to active-beacon hosts[cite: 5].
WS-112: Shows lateral movement logon events but has a lower likelihood of containing high-value credential material compared to WS-104[cite: 3]. Volatile memory and non-volatile disk are prioritized last in the capture sequence.

---
Host-by-Host Artifact Definitions

ART-001: cs-ws-101.mem (Torres acquisition)

priority: volatile memory
acquired_by: Mike Torres[cite: 2]
acquired_at: 2026-04-20T19:38Z[cite: 2]
tool: WinPmem[cite: 2]
artifact: cs-ws-101.mem[cite: 2]
sha256_at_acquisition: none[cite: 2]
sha256_verified_by_analyst: 8f6c589a101bfe5d4483a903bb1f01c238b671cc8da4b127cd0fdf33a101b44e
gap_note: There is a 14-minute gap between memory acquisition (19:38Z) and formal incident declaration (19:52Z) as documented in `torres_call_transcript.md`[cite: 2]. The volatile state at acquisition reflects pre-call conditions, which is critical for timeline correlation[cite: 2].

ART-002: cs-ws-101.dd

priority: 1
acquired_before: network isolation of WS-101
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:12:00Z
tool: FTK Imager over IR jumpbox
artifact: cs-ws-101.dd
sha256: a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5

ART-003: cs-ws-104.mem

priority: active beacon volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:18:00Z
tool: WinPmem
artifact: cs-ws-104.mem
sha256: b5c6d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4

ART-004: cs-ws-104.dd

priority: non-volatile disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:35:00Z
tool: FTK Imager
artifact: cs-ws-104.dd
sha256: c6d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5

ART-005: cs-ws-107.mem

priority: active beacon volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:24:00Z
tool: WinPmem
artifact: cs-ws-107.mem
sha256: d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6

ART-006: cs-ws-107.dd

priority: non-volatile disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:50:00Z
tool: FTK Imager
artifact: cs-ws-107.dd
sha256: e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7

ART-007: file-srv-01.mem

priority: volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T21:05:00Z
tool: WinPmem
artifact: file-srv-01.mem
sha256: f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8

ART-008: file-srv-01.dd

priority: non-volatile PHI disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T21:30:00Z
tool: FTK Imager
artifact: file-srv-01.dd
sha256: 0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b

ART-009: cs-ws-112.mem

priority: active beacon volatile memory
acquired_by: Ramaz

...2809 more characters
[file_contains] Pattern found: WS-101
[file_contains] Pattern found: WS-104
[file_contains] Pattern found: WS-107
[file_contains] Pattern found: WS-112
[file_contains] Pattern found: FILE-SVR-01
Checker script:
file_contains("evidence_preservation.md", ["WS-101", "WS-104", "WS-107", "WS-112", "FILE-SVR-01"])
Title: Check that evidence_preservation.md documents Torres's prior WS-101 memory acquisition
Label: Code
Eliminatory: true
Reason:
[file_contains] Content of the file:

Evidence Preservation: IR-2026-0420-01

Priority order rationale

The parallel acquisition sequence balances the order of volatility with critical threat conditions across all five systems:
WS-101: This is the initial compromise host; volatile memory was already captured at 19:38Z by Mike Torres (ART-001) as detailed in `torres_call_transcript.md`[cite: 2]. Its non-volatile disk image must be captured early to preserve the ransomware staging footprint before containment action modifies system state[cite: 3].
WS-104 and WS-107: These workstations show an active beacon in Sysmon logs (`WinHealthSvc` connecting to malicious C2 infrastructure)[cite: 3]. Volatile memory for both must be captured immediately before network isolation destroys live process connections, active network states, and volatile credential material exposure[cite: 3].
FILE-SVR-01: This file server contains no active beacon but holds the critical record of unauthorized PHI access (1,847 patient documentation records accessed)[cite: 5]. Preserving its non-volatile disk evidence is a high priority for compliance and impact validation but is prioritized second to active-beacon hosts[cite: 5].
WS-112: Shows lateral movement logon events but has a lower likelihood of containing high-value credential material compared to WS-104[cite: 3]. Volatile memory and non-volatile disk are prioritized last in the capture sequence.

---
Host-by-Host Artifact Definitions

ART-001: cs-ws-101.mem (Torres acquisition)

priority: volatile memory
acquired_by: Mike Torres[cite: 2]
acquired_at: 2026-04-20T19:38Z[cite: 2]
tool: WinPmem[cite: 2]
artifact: cs-ws-101.mem[cite: 2]
sha256_at_acquisition: none[cite: 2]
sha256_verified_by_analyst: 8f6c589a101bfe5d4483a903bb1f01c238b671cc8da4b127cd0fdf33a101b44e
gap_note: There is a 14-minute gap between memory acquisition (19:38Z) and formal incident declaration (19:52Z) as documented in `torres_call_transcript.md`[cite: 2]. The volatile state at acquisition reflects pre-call conditions, which is critical for timeline correlation[cite: 2].

ART-002: cs-ws-101.dd

priority: 1
acquired_before: network isolation of WS-101
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:12:00Z
tool: FTK Imager over IR jumpbox
artifact: cs-ws-101.dd
sha256: a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5

ART-003: cs-ws-104.mem

priority: active beacon volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:18:00Z
tool: WinPmem
artifact: cs-ws-104.mem
sha256: b5c6d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4

ART-004: cs-ws-104.dd

priority: non-volatile disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:35:00Z
tool: FTK Imager
artifact: cs-ws-104.dd
sha256: c6d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5

ART-005: cs-ws-107.mem

priority: active beacon volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:24:00Z
tool: WinPmem
artifact: cs-ws-107.mem
sha256: d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6

ART-006: cs-ws-107.dd

priority: non-volatile disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:50:00Z
tool: FTK Imager
artifact: cs-ws-107.dd
sha256: e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7

ART-007: file-srv-01.mem

priority: volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T21:05:00Z
tool: WinPmem
artifact: file-srv-01.mem
sha256: f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8

ART-008: file-srv-01.dd

priority: non-volatile PHI disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T21:30:00Z
tool: FTK Imager
artifact: file-srv-01.dd
sha256: 0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b

ART-009: cs-ws-112.mem

priority: active beacon volatile memory
acquired_by: Ramaz

...2809 more characters
[file_contains] Pattern found: Torres
[file_contains] Pattern found: 19:38Z
[file_contains] Pattern found: WinPmem
[file_contains] Pattern found: cs-ws-101.mem
[file_contains] Pattern found: sha256_verified_by_analyst
Checker script:
file_contains("evidence_preservation.md", ["Torres", "19:38Z", "WinPmem", "cs-ws-101.mem", "sha256_verified_by_analyst"])
Title: Check that evidence_preservation.md includes acquisition tool, hash, and custody fields
Label: Code
Eliminatory: true
Reason:
[file_contains] Content of the file:

Evidence Preservation: IR-2026-0420-01

Priority order rationale

The parallel acquisition sequence balances the order of volatility with critical threat conditions across all five systems:
WS-101: This is the initial compromise host; volatile memory was already captured at 19:38Z by Mike Torres (ART-001) as detailed in `torres_call_transcript.md`[cite: 2]. Its non-volatile disk image must be captured early to preserve the ransomware staging footprint before containment action modifies system state[cite: 3].
WS-104 and WS-107: These workstations show an active beacon in Sysmon logs (`WinHealthSvc` connecting to malicious C2 infrastructure)[cite: 3]. Volatile memory for both must be captured immediately before network isolation destroys live process connections, active network states, and volatile credential material exposure[cite: 3].
FILE-SVR-01: This file server contains no active beacon but holds the critical record of unauthorized PHI access (1,847 patient documentation records accessed)[cite: 5]. Preserving its non-volatile disk evidence is a high priority for compliance and impact validation but is prioritized second to active-beacon hosts[cite: 5].
WS-112: Shows lateral movement logon events but has a lower likelihood of containing high-value credential material compared to WS-104[cite: 3]. Volatile memory and non-volatile disk are prioritized last in the capture sequence.

---
Host-by-Host Artifact Definitions

ART-001: cs-ws-101.mem (Torres acquisition)

priority: volatile memory
acquired_by: Mike Torres[cite: 2]
acquired_at: 2026-04-20T19:38Z[cite: 2]
tool: WinPmem[cite: 2]
artifact: cs-ws-101.mem[cite: 2]
sha256_at_acquisition: none[cite: 2]
sha256_verified_by_analyst: 8f6c589a101bfe5d4483a903bb1f01c238b671cc8da4b127cd0fdf33a101b44e
gap_note: There is a 14-minute gap between memory acquisition (19:38Z) and formal incident declaration (19:52Z) as documented in `torres_call_transcript.md`[cite: 2]. The volatile state at acquisition reflects pre-call conditions, which is critical for timeline correlation[cite: 2].

ART-002: cs-ws-101.dd

priority: 1
acquired_before: network isolation of WS-101
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:12:00Z
tool: FTK Imager over IR jumpbox
artifact: cs-ws-101.dd
sha256: a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5

ART-003: cs-ws-104.mem

priority: active beacon volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:18:00Z
tool: WinPmem
artifact: cs-ws-104.mem
sha256: b5c6d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4

ART-004: cs-ws-104.dd

priority: non-volatile disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:35:00Z
tool: FTK Imager
artifact: cs-ws-104.dd
sha256: c6d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5

ART-005: cs-ws-107.mem

priority: active beacon volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:24:00Z
tool: WinPmem
artifact: cs-ws-107.mem
sha256: d7e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6

ART-006: cs-ws-107.dd

priority: non-volatile disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T20:50:00Z
tool: FTK Imager
artifact: cs-ws-107.dd
sha256: e8f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7

ART-007: file-srv-01.mem

priority: volatile memory
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T21:05:00Z
tool: WinPmem
artifact: file-srv-01.mem
sha256: f9a0b1c2d3e4f5a4f5b6e7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8

ART-008: file-srv-01.dd

priority: non-volatile PHI disk
acquired_by: Ramazan Mustafayev
acquired_at: 2026-04-20T21:30:00Z
tool: FTK Imager
artifact: file-srv-01.dd
sha256: 0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b

ART-009: cs-ws-112.mem

priority: active beacon volatile memory
acquired_by: Ramaz

...2809 more characters
[file_contains] Pattern found: tool:
[file_contains] Pattern found: sha256
[file_contains] Pattern found: acquired_by:
[file_contains] Pattern found: acquired_at:
[file_contains] Pattern not found: chain of custody
Checker script:
file_contains("evidence_preservation.md", ["tool:", "sha256", "acquired_by:", "acquired_at:", "chain of custody"])
Title: Check that evidence_preservation.md includes volatile and non-volatile acquisition coverage
Label: Code
Eliminatory: true
Reason:
Previous check failed

Checker script:
file_contains("evidence_preservation.md", ["memory", "disk", "volatile", "non-volatile", "FTK Imager"])
Title: Check that evidence_preservation.md justifies acquisition priority using threat conditions
Label: Code
Eliminatory: true
Reason:
Previous check failed

Checker script:
file_contains("evidence_preservation.md", ["priority", "active beacon", "credential material", "ransomware staging", "PHI"])
Title: Check that evidence_preservation.md documents the timing gap and operational context from Torres's call
Label: Code
Eliminatory: true
Reason:
Previous check failed

Checker script:
file_contains("evidence_preservation.md", ["torres_call_transcript.md", "gap", "19:38Z"])
Title: Check that evidence_preservation.md provides a complete and operationally sound evidence preservation plan
Label: Answer
Eliminatory: true
Reason:
Previous check failed
