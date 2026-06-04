# Chain of Custody: LH-2026-0414-01

## Case Header

- **Case number:** LH-2026-0414-01
- **Incident ID:** IR-2026-0414-01
- **Lead investigator:** Forensic Analyst
- **Date opened:** 2026-04-14
- **Litigation hold reference:** Memo from Helena Reyes, 2026-04-14T07:30Z

---

## Custody Management Rules
> **CRITICAL:** This document is strictly **append-only** for the duration of the investigation. Every artifact and every access event must be logged here.
> 
> **Hash Verification Policy:** > - Compute and record the **SHA-256** hash for each artifact before the **first analysis access**.
> - Every **subsequent access** adds a new access log row, regardless of how brief.
> - Deviations from the expected hash value at any access event are flagged immediately and appended as a `DEVIATION` note.
> - Registry details, acquisition timestamps, and handling notes are cross-referenced with `acquisition_notes.md`.

---

## Artifact Registry

| Artifact ID | Artifact Name | Format | Acquired By | Acquisition Timestamp (UTC) | Acquisition Tool | SHA-256 at Acquisition | Storage Path | Access Controls |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| ART-001 | wst-ws-031.dd | RAW/dd | Mike Torres | 2026-04-14T06:14Z | FTK Imager | NOT_COMPUTED_BY_ACQUIRER | /evidence/share/IR-2026-0414-01/wst-ws-031.dd | read-only, IR team only |
| ART-002 | wst-ws-031.mem | RAW | Mike Torres | 2026-04-14T03:02Z | WinPmem v3.3-rc3 | NOT_COMPUTED_BY_ACQUIRER | /evidence/share/IR-2026-0414-01/wst-ws-031.mem | read-only, IR team only |
| ART-003 | wst-ws-017.mem | RAW | Mike Torres | 2026-04-14T03:38Z | WinPmem v3.3-rc3 | NOT_COMPUTED_BY_ACQUIRER | /evidence/share/IR-2026-0414-01/wst-ws-017.mem | read-only, IR team only |

---

## Evidence Acquisition Confirmation
* **2026-04-14T03:02Z** - ART-002 memory acquisition completed using WinPmem v3.3-rc3 (Ref: acquisition_notes.md handling notes)
* **2026-04-14T03:38Z** - ART-003 memory acquisition completed using WinPmem v3.3-rc3 (Ref: acquisition_notes.md handling notes)
* **2026-04-14T06:14Z** - ART-001 disk acquisition completed using FTK Imager (Ref: acquisition_notes.md handling notes)

---

## Access Log

| Timestamp (UTC) | Actor | Artifact ID | Action | Tool Used | Hash Verified | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 2026-04-14T03:02Z | Mike Torres | ART-002 | memory_acquisition | WinPmem | no | Initial volatile memory capture from WST-WS-031 |
| 2026-04-14T03:38Z | Mike Torres | ART-003 | memory_acquisition | WinPmem | no | Initial volatile memory capture from WST-WS-017 |
| 2026-04-14T04:51Z | Mike Torres | ART-001 | read-write_mount | FTK Imager / OS Mount | no | DEVIATION: live filesystem mounted in read-write mode to inspect update.xml prior to imaging |
| 2026-04-14T06:14Z | Mike Torres | ART-001 | disk_acquisition | FTK Imager | no | Full disk image acquisition completed successfully |
| 2026-04-14T07:42Z | Mike Torres | ART-001 | evidence_transfer | Secure Network Copy | no | Evidence transferred to centralized evidence repository |
| 2026-04-14T07:42Z | Mike Torres | ART-002 | evidence_transfer | Secure Network Copy | no | Evidence transferred to centralized evidence repository |
| 2026-04-14T07:42Z | Mike Torres | ART-003 | evidence_transfer | Secure Network Copy | no | Evidence transferred to centralized evidence repository |
| 2026-04-14T08:00Z | Forensic Analyst | ART-001 | hash_verify | sha256sum | yes | Baseline integrity verification completed; first analysis access baseline established |
| 2026-04-14T08:05Z | Forensic Analyst | ART-002 | hash_verify | sha256sum | yes | Baseline integrity verification completed; first analysis access baseline established |
| 2026-04-14T08:10Z | Forensic Analyst | ART-003 | hash_verify | sha256sum | yes | Baseline integrity verification completed; first analysis access baseline established |
