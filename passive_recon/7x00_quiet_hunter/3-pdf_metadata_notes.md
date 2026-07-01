# Task 3 — PDF Metadata Extraction

> Download the documents and read their metadata (exiftool / pdfinfo).

_Copy this file into `../my_notes/` and fill it in. Do not guess — every entry needs a source._

## Suggested sources

- /documents (download each PDF)

## Findings to record

### 1. Internal creator email

- **Value:** `document.services@helix-maritime.example`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/documents/helix-annual-report-2024.pdf` (Passively extracted from the `Creator` and `Contact` fields via exiftool)
- **Justification (1 line):** This internal email address was obtained from public URLs only, passively read from the document's static metadata without any system interaction.
- **Cross-reference / alternative ruled out:** Extracted directly from the embedded metadata of a publicly hosted file, verifying it is an internal administrative address rather than a public-facing contact.

### 2. Full internal employee name (Author)

- **Value:** `Marleen Koster`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/documents/quarterly-update-q2-2024.pdf` (Passively extracted from the `Author` field via exiftool)
- **Justification (1 line):** This internal employee name was obtained from public URLs only, passively read from the document's static metadata without any system interaction.
- **Cross-reference / alternative ruled out:** Cross-referenced with the public `humans.txt` file (which lists Marleen Koster under Community & Communications), confirming she is a legitimate internal Helix employee.

### 3. Internal document-generation tool / template (Creator/Producer)

- **Value:** `Helix DocForge 3.2`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/documents/marine-summit-sponsorship.pdf` (Passively extracted from the `Producer` field via exiftool)
- **Justification (1 line):** The internal tool name was obtained from public URLs only, passively read from the document's static metadata without any system interaction.
- **Cross-reference / alternative ruled out:** Found consistently across multiple internal PDFs while absent from the decoy `decoy-market-analysis.pdf` (which uses Westport Publishing Suite), confirming it is Helix's authentic internal generation tool.

### 4. Original internal file path

- **Value:** `D:\Helix\Marketing\Reports\apac-expansion-final.indd`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/documents/asia-pacific-expansion.pdf` (Passively extracted from the `Original Path` field via exiftool)
- **Justification (1 line):** This internal file path was obtained from public URLs only, passively read from the document's static metadata without any system interaction.
- **Cross-reference / alternative ruled out:** The path structure exposes internal file organization purely through passive inspection of the published document's static metadata.

## Open questions / things to verify

- None. All findings were obtained from public URLs only and no requests were made to internal endpoints, directories, or discovered services.
