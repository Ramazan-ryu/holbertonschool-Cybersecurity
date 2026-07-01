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
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/` (HTML source code, inside the `<head>` tag, block comment immediately following the `<title>` element)
- **Justification (1 line):** The internal identifier was passively read from the public HTML source code of the index page.
- **Cross-reference / alternative ruled out:** Confirmed by passively reading `http://[PROVIDED_IP]/humans.txt`, which lists "dvries", ruling out a placeholder value.

### 2. Non-public API endpoint referenced in a script

- **Value:** `https://api-internal.helix-maritime.example/v2/quote-engine`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/assets/legacy-app.js` (Inside the `LEGACY` JavaScript object definition, specifically the `quoteEngine` property)
- **Justification (1 line):** The internal API URL was found by statically reading the text of a publicly accessible JavaScript file; the endpoint itself was not probed or accessed.
- **Cross-reference / alternative ruled out:** Corroborated by reading the public `http://[PROVIDED_IP]/robots.txt` file, which mentions the internal quote pricing service.

### 3. Exact content-platform / framework name + version

- **Value:** `Veridian CMS 5.2.1`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/humans.txt` (Inside the `/* SITE */` section, on the line starting with `Content platform:`)
- **Justification (1 line):** The specific CMS framework and version are explicitly published in the plain text of the `humans.txt` file.
- **Cross-reference / alternative ruled out:** Cross-referenced by statically reading `http://[PROVIDED_IP]/assets/legacy-app.js` which contains the same version string in the `LEGACY.cms` variable.

## Open questions / things to verify

- None.
