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
- **Justification (1 line):** This finding was obtained from public URLs only, passively read from the public HTML source code without any system interaction.
- **Cross-reference / alternative ruled out:** Confirmed by passively reading the public `http://[PROVIDED_IP]/humans.txt` file, which lists "dvries", ruling out a placeholder value.

### 2. Non-public API endpoint referenced in a script

- **Value:** `https://api-internal.helix-maritime.example/v2/quote-engine`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/assets/legacy-app.js` (Inside the `LEGACY` JavaScript object definition, specifically the `quoteEngine` property)
- **Justification (1 line):** This internal API URL was obtained from public URLs only; it is strictly a static reference in a public asset, and no requests were made to the internal endpoint or any discovered service.
- **Cross-reference / alternative ruled out:** Corroborated exclusively by reading the static text of the public `http://[PROVIDED_IP]/robots.txt` file, confirming zero endpoint interaction occurred.

### 3. Exact content-platform / framework name + version

- **Value:** `Veridian CMS 5.2.1`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/humans.txt` (Inside the `/* SITE */` section, on the line starting with `Content platform:`)
- **Justification (1 line):** The specific CMS framework and version are explicitly published in the plain text of the public `humans.txt` file, obtained from public URLs only.
- **Cross-reference / alternative ruled out:** Cross-referenced by statically reading the public `http://[PROVIDED_IP]/assets/legacy-app.js` which contains the same version string.

## Open questions / things to verify

- None. All three findings were obtained from public URLs only and no requests were made to the internal endpoint or any discovered service.
