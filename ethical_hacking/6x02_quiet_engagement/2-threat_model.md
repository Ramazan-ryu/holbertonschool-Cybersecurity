# Threat Model, Lumen Industrial Systems

## Framework Mix
This threat model utilizes a hybrid framework approach tailored specifically for Lumen's external footprint and industrial risk profile. **MITRE ATT&CK** is used to map direct adversarial techniques against the exposed infrastructure discovered during our reconnaissance—specifically the public-facing MQTT broker, demo edge gateways, and staging surfaces—where tactical exploitation could bridge the gap from public assets to Lumen's internal IT network. **STRIDE** is applied to decompose logic and architectural flaws within the surfaced public API and customer web portals, which are critical to protecting Lumen's multi-tenant data and upholding the engagement's mandate of zero operational disruption.

## Threat Matrix

| # | Threat | Asset | Framework Tag | Severity | Rationale |
| --- | --- | --- | --- | --- | --- |
| 1 | Exposed Hardcoded Credentials | Exposed repository | MITRE-T1552.005 | Critical | OSINT surfaced a public code repository containing legacy Lumen integration scripts with hardcoded staging credentials. |
| 2 | Unauthenticated Topic Subscription | MQTT broker | MITRE-T1190 | Critical | Recon surfaced an external-facing MQTT broker without TLS mutual authentication, risking unauthorized access to industrial telemetry. |
| 3 | Message Injection / Tampering | MQTT broker | STRIDE-Tampering | Critical | The lack of strict message signing and authentication on the broker allows potential spoofing of sensor data fed to the core platform. |
| 4 | Remote Code Execution via Diagnostics | Staging surface | MITRE-T1190 | Critical | The discovered staging environment exposes internal diagnostic endpoints that may allow unauthorized command execution. |
| 5 | Default Administrative Credentials | Demo edge gateway | MITRE-T1078.001 | High | A publicly reachable demo instance of the edge gateway was found; such instances frequently retain default vendor credentials. |
| 6 | API Authentication Bypass | Public API | STRIDE-Spoofing | High | Recon surfaced fragmented authentication schemas across different versions of the public API, risking unauthorized access to platform logic. |
| 7 | BOLA / IDOR on Sensor Data | Public API | STRIDE-Elevation | High | Predictable endpoint structures in the API documentation suggest the potential for accessing cross-tenant industrial data. |
| 8 | Credential Stuffing / Password Spraying | Admin panel | MITRE-T1110.004 | High | The admin panel login is exposed without visible CAPTCHA or rate-limiting, and employee email formats were surfaced via OSINT. |
| 9 | Configuration File Extraction | Demo edge gateway | STRIDE-Info Disclosure | High | The web interface of the demo gateway may allow unauthenticated or low-privileged extraction of backup configuration files. |
| 10 | Cross-Site Scripting (XSS) | Web portal | STRIDE-Spoofing | Medium | Input fields on the customer web portal lack strict sanitization, introducing a risk of session hijacking for authenticated industrial clients. |
| 11 | Information Disclosure via Debug Flags | Staging surface | STRIDE-Info Disclosure | Medium | Verbose error handling on the staging surface leaks internal file paths, internal routing, and backend framework versions. |
| 12 | Resource Exhaustion (DoS) | Public API | STRIDE-Denial of Service | Medium | The lack of strict rate limiting on data-heavy API endpoints makes the primary management service susceptible to Layer 7 denial of service. |

## Prioritisation Note
The top three threats in terms of business impact are the **Exposed Hardcoded Credentials** (Threat 1), **Unauthenticated Topic Subscription on the MQTT broker** (Threat 2), and **Remote Code Execution on the Staging Surface** (Threat 4). Compromising the MQTT broker directly undermines the integrity of Lumen's industrial data pipeline, a worst-case scenario for an industrial systems provider. Furthermore, if the exposed repository credentials or the staging surface vulnerabilities provide a pivot point into the production environment, Lumen's core mandate of zero operational disruption will be critically breached.
