# Threat Model, Lumen Industrial Systems

## Framework Mix
This threat model utilizes a combination of STRIDE and MITRE ATT&CK. STRIDE is applied to decompose architectural and logic flaws within the web applications and public API layer, which is crucial for securing Lumen's multi-tenant cloud platform. MITRE ATT&CK is used to tag specific adversary-aligned exposures related to reconnaissance findings, mapping tactical exploitation paths against Lumen's external footprint and employee OSINT to evaluate external perimeter resilience.

## Threat Matrix

| # | Threat | Asset | Framework Tag | Severity | Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | API Authentication Bypass | Public API (api.lumen-industrial.com) | STRIDE-Spoofing | Critical | Unauthenticated v1 telemetry endpoints could allow adversaries to inject spoofed industrial sensor data into the core platform. |
| 2 | BOLA / IDOR on Telemetry | Public API (api.lumen-industrial.com) | STRIDE-Elevation | Critical | Predictable tenant IDs in API calls risk cross-tenant exposure, allowing one industrial client to view another's proprietary production line metrics. |
| 3 | Credential Stuffing | Internal Admin Panel | MITRE-T1110.004 | High | Identifiable Lumen engineers surfaced via OSINT can be targeted to gain an initial administrative foothold, threatening the zero-disruption mandate. |
| 4 | Denial of Service (Resource Exhaustion) | Public API (api.lumen-industrial.com) | STRIDE-Denial of Service | Critical | Lack of strict rate limiting on data-heavy endpoints could disrupt real-time industrial monitoring, violating NIS2 availability requirements. |
| 5 | Subdomain Takeover | Subdomains (*.lumen-industrial.com) | MITRE-T1190 | High | Dangling DNS records on abandoned QA environments could be hijacked to host phishing sites mimicking the legitimate Lumen SaaS login portal. |
| 6 | Server-Side Request Forgery (SSRF) | Cloud-Hosted Platform | STRIDE-Elevation | High | Webhook integrations in the client dashboard could be manipulated to probe Lumen's internal cloud infrastructure and AWS/OVH metadata services. |
| 7 | Information Disclosure | Public API (api.lumen-industrial.com) | STRIDE-Info Disclosure | Medium | Verbose error handling leaks internal microservice routing and database schemas used for processing industrial logs. |
| 8 | Targeted Spearphishing | Identifiable Employees | MITRE-T1566.002 | High | Specific employee roles (e.g., SOC analysts, engineers) surfaced via public sources enable targeted malware delivery to bypass the external perimeter. |
| 9 | Email Spoofing | Public DNS | MITRE-T1566.001 | Medium | Incomplete DMARC reject policies allow attackers to impersonate Lumen support, tricking industrial clients into resetting platform passwords. |
| 10 | Cross-Site Scripting (XSS) | Cloud-Hosted Platform | STRIDE-Spoofing | Medium | Unsanitized inputs in the client-facing reporting dashboard introduce session hijacking risks for authenticated industrial plant managers. |
| 11 | IDOR on Operational Reports | Cloud-Hosted Platform | STRIDE-Info Disclosure | High | Predictable URLs for monthly operational analytics reports expose sensitive customer production data to unauthorized users. |
| 12 | Exposed Staging Credentials | Public OSINT / Repositories | MITRE-T1552.005 | High | Hardcoded API keys found in public employee repositories could grant unauthorized access to Lumen's internal demo and QA infrastructure. |

## Prioritisation Note
The top three threats in operational and business-impact terms are BOLA on the Public API (Row 2), Denial of Service on the API (Row 4), and Credential Stuffing against the Admin Panel (Row 3). These outrank the others because they represent immediate, systemic failures of Lumen's core industrial SaaS value proposition. BOLA and DoS directly violate NIS2 strict liability mandates for confidentiality and availability; if telemetry is exposed or goes offline, physical industrial processes are blinded. Credential stuffing outranks lower-level app vulnerabilities (like XSS or SSRF) because it provides direct administrative access, instantly breaching the engagement's zero operational disruption requirement.
