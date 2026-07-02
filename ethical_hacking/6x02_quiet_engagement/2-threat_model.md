# Threat Model, Lumen Industrial Systems

## Framework Mix
This threat model utilizes a combination of STRIDE and MITRE ATT&CK. STRIDE is applied to decompose architectural and logic flaws within the web applications and API layer, which is natural for the cloud-platform layer. MITRE ATT&CK is used to tag specific adversary-aligned exposures related to reconnaissance findings, mapping tactical exploitation paths against Lumen's external footprint and employee OSINT.

## Threat Matrix

| Row Index | Threat Description | Asset Surfaced | Framework Tag | Severity | Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | API Authentication Bypass | Public API surface | STRIDE-Spoofing | Critical | Recon surfaced public API endpoints without strict authentication schemas, risking unauthorized access to the industrial platform. |
| 2 | Credential Stuffing | Identifiable employees | MITRE-T1110.004 | High | Publicly identifiable employee email addresses found via OSINT can be used in credential spraying against corporate portals. |
| 3 | BOLA / IDOR | Public API surface | STRIDE-Elevation | Critical | API endpoint structures discovered during recon suggest predictable tenant data structures, risking cross-tenant data exposure. |
| 4 | Subdomain Takeover | Subdomains | MITRE-T1190 | High | Staging subdomains surfaced in DNS records may host vulnerable legacy applications or dangling DNS pointers. |
| 5 | Information Disclosure | Public API surface | STRIDE-Info Disclosure | Medium | Verbose error handling on the API surface leaks internal backend framework versions and internal routing paths. |
| 6 | Targeted Spearphishing | Identifiable employees | MITRE-T1566.002 | High | Employee roles and departments surfaced via public sources provide targets for highly targeted phishing campaigns. |
| 7 | Cross-Site Scripting (XSS) | Marketing surface | STRIDE-Spoofing | Medium | Input fields on the public marketing web surface lack strict sanitization, introducing session hijacking risks. |
| 8 | Layer 7 Denial of Service | Public API surface | STRIDE-Denial of Service | Medium | The public API surface lacks strict rate limiting, making the primary management service susceptible to resource exhaustion. |
| 9 | Email Spoofing | Public DNS | MITRE-T1566.001 | Medium | Cached DNS records show incomplete SPF and DMARC configurations, allowing adversaries to spoof Lumen communications. |
| 10 | Server-Side Request Forgery | Subdomains | STRIDE-Elevation | High | Staging surface web applications interact with internal endpoints, potentially allowing bypass of the external perimeter. |

## Prioritisation Note
The top three threats in business-impact terms for Lumen are BOLA on the Public API (Row 3), API Authentication Bypass (Row 1), and Credential Stuffing against employees (Row 2). An API BOLA or authentication bypass directly jeopardizes multi-tenant data isolation, triggering severe NIS2 regulatory penalties and loss of customer trust. Successful credential stuffing would breach Lumen's zero operational disruption mandate, allowing adversaries a foothold to pivot into the core industrial network.
