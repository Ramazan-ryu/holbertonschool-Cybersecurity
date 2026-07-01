# Task 4 — Web Archive & Historical Footprint

> Compare archived snapshots with the current site.

_Copy this file into `../my_notes/` and fill it in. Do not guess — every entry needs a source._

## Suggested sources

- /archive and its snapshots
- current /company/* pages for comparison

## Findings to record

### 1. Former executive no longer on the current team

- **Value:** `Reinier Hofstede`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/archive` -> Captured 2023-05-09 of `helix-maritime.example/team` (Listed under Chief Financial Officer)
- **Justification (1 line):** This finding was obtained from public URLs only, discovered by passively comparing the static archived 2023 team page against the current live page without any system interaction.
- **Cross-reference / alternative ruled out:** Cross-referenced with the current `http://[PROVIDED_IP]/company/team` page to confirm his removal, validating him as a former, rather than current, executive.

### 2. A removed strategic partner

- **Value:** `Nordstern Re`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/archive` -> Captured 2023-05-09 of `helix-maritime.example/partners` (Listed as Strategic reinsurer)
- **Justification (1 line):** This finding was obtained from public URLs only, discovered by passively comparing the static archived 2023 partners page against the current live page without any system interaction.
- **Cross-reference / alternative ruled out:** Ruled out "Calypso Underwriting Systems" because the archive explicitly notes it was an IT supplier and *not* a strategic partner. Cross-referenced with the current `http://[PROVIDED_IP]/company/partners` to confirm Nordstern Re's removal.

### 3. An older office address or phone number

- **Value:** `Scheepvaartkade 12, 3011 BR Rotterdam`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/archive` -> Captured 2022-08-14 of `helix-maritime.example/contact` (Listed under Office address)
- **Justification (1 line):** This older address was obtained from public URLs only, discovered by passively reading the static archived 2022 contact page without any system interaction.
- **Cross-reference / alternative ruled out:** Cross-referenced with the current `http://[PROVIDED_IP]/company/contact` page to confirm the address has since changed, verifying this as a historical rather than active location.

## Open questions / things to verify

- None. All historical findings were obtained from public URLs only and no requests were made to internal endpoints, directories, or discovered services.
