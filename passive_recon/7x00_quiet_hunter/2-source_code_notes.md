# Task 2 — Website Source-Code Archaeology

> What the page source, public scripts and headers disclose.

_Copy this file into `../my_notes/` and fill it in. Do not guess — every entry needs a source._

## Suggested sources

- View-source of /
- Public JS under /assets/
- Response headers (curl -I)
- /humans.txt

## Findings to record

### 1. Internal developer identifier (HTML comment)

- **Value:** `build pipeline maintained by: dvries (developer id DEV-2291)`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/` (HTML `<head>` section, block comment)
- **Justification (1 line):** An HTML comment left in the production source code's `<head>` section inadvertently exposes the internal username and developer ID of the pipeline maintainer.
- **Cross-reference / alternative ruled out:** Cross-referenced with the public `humans.txt` file, which confirms "dvries" is the alias for Senior Software Engineer Daan de Vries, validating this as a legitimate internal identifier.

### 2. Non-public API endpoint referenced in a script

- **Value:** `https://api-internal.helix-maritime.example/v2/quote-engine`
- **Exact source (URL / file / metadata field):** `/assets/legacy-app.js` (LEGACY configuration object)
- **Justification (1 line):** A legacy JavaScript file, discovered via `robots.txt` exclusion, contains hardcoded references to non-public, internal backend API endpoints used for quote pricing.
- **Cross-reference / alternative ruled out:** Corroborated by the developer note in `robots.txt` stating "Quote pricing runs on an internal service," ruling out a dummy or third-party API link. We also noted the v1 endpoint, but v2 is the active internal engine.

### 3. Exact content-platform / framework name + version

- **Value:** `Veridian CMS 5.2.1`
- **Exact source (URL / file / metadata field):** `/assets/legacy-app.js` (LEGACY.cms variable) & `/humans.txt`
- **Justification (1 line):** The exact content management system name and version are explicitly hardcoded into both the site's `humans.txt` file and legacy JavaScript variables.
- **Cross-reference / alternative ruled out:** Seeing the identical version string in both a text file and a JS configuration object confirms this is the actual production stack, eliminating the need to rely on potentially spoofed HTTP headers.

## Open questions / things to verify

- Do the `api-internal.helix-maritime.example` endpoints lack authentication or authorization checks if accessed directly, despite not being linked on the front end?
- Are there known vulnerabilities (CVEs) associated with Veridian CMS version 5.2.1 that the red team can leverage during the operational phase?
