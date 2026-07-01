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
- **Justification (1 line):** An HTML comment left in the production source code's `<head>` section exposes the internal username and developer ID of the pipeline maintainer.
- **Cross-reference / alternative ruled out:** Cross-referenced with the public `humans.txt` file, which confirms "dvries" is the alias for Senior Software Engineer Daan de Vries, validating the identifier via purely public files.

### 2. Non-public API endpoint referenced in a script

- **Value:** `https://api-internal.helix-maritime.example/v2/quote-engine`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/assets/legacy-app.js` (LEGACY configuration object)
- **Justification (1 line):** The legacy JavaScript file explicitly lists a non-public backend API URL used for the quote engine.
- **Cross-reference / alternative ruled out:** Sourced entirely from public script inspection; corroborates the `robots.txt` statement that quote pricing runs on an internal service without requiring any connection attempts to the endpoint itself.

### 3. Exact content-platform / framework name + version

- **Value:** `Veridian CMS 5.2.1`
- **Exact source (URL / file / metadata field):** `http://[PROVIDED_IP]/assets/legacy-app.js` (LEGACY.cms variable) & `http://[PROVIDED_IP]/humans.txt`
- **Justification (1 line):** The exact content management system name and version are explicitly hardcoded into public text files and legacy JavaScript variables.
- **Cross-reference / alternative ruled out:** Seeing the identical version string in both public files confirms this is the documented stack, found purely through passive file reading.

## Open questions / things to verify

- Can the `api-internal.helix-maritime.example` subdomain be correlated with passive DNS records (like we did in Task 1) to identify its hosting IP without executing a live DNS query?
