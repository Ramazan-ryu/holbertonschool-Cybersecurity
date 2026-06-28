# Penetration Test Report, Lumen Industrial Systems

**Engagement reference:** LIS-PT-2026Q2  
**Reporting period:** July 6, 2026 – July 17, 2026  
**Prepared by:** Junior Consultant, Vanguard Security  
**Distribution:** Lumen CISO, downstream NIS2 conformity packet recipients  

## 1. Executive Summary

During the engagement window, Vanguard Security conducted an external, grey-box penetration test of Lumen Industrial Systems' central management infrastructure. Commissioned to validate perimeter resilience ahead of critical NIS2 conformity audits, the assessment confirmed that while live industrial assets remained secure and operational disruption was successfully avoided, a critical architectural vulnerability exists within the central administrative portal. This flaw allows unauthorized external actors to bypass perimeter security controls, compromise the internal IoT management plane, and access centralized operational configurations. For Lumen's industrial clients, this represents a severe supply chain risk that undermines the integrity of their OT environments. Immediate remediation of the identified perimeter vulnerabilities and the implementation of a centralized secrets management architecture are required to satisfy NIS2 compliance obligations and ensure the ongoing security of the management platform.

## 2. Scope and Methodology

This engagement was governed by a strict Rules of Engagement (RoE) designed to explicitly isolate Lumen’s central IT/OT bridging infrastructure from downstream customer-premises equipment. 

**In-Scope Assets:**
- Central Admin Panel (`admin.lumen.example`)
- Public REST API (`api.lumen.example`)
- Customer Web Portal (`portal.lumen.example`)
- Demo Edge Gateway (`gateway.demo.lumen.example`)
- Demo MQTT Broker (`mqtt.demo.lumen.example`)

**Out-of-Scope Assets:**
- All customer-deployed edge gateways, warehouse sensors, and premises networks. (Reasoning: Lumen cannot authorize testing on physical or logical assets owned and operated by third-party clients).
- Third-party SaaS infrastructure and management planes.
- Physical security and social engineering.

Testing prioritized stealth, operational safety, and manual analysis over automated, high-volume scanning. Exploitation was strictly constrained by a "no-Metasploit" requirement for initial footholds, mandating the use of highly controlled, bespoke payloads to guarantee zero disruption to Lumen's availability.

## 3. PTES Phase Summary

**Pre-engagement:** Drafted custom Rules of Engagement to explicitly establish a boundary between Lumen’s central IT/OT infrastructure and unconsented customer-premises equipment, ensuring liability protection and operational safety.
**Intelligence Gathering:** Mapped Lumen’s external digital footprint, manually cataloging exposed microservices, administrative portals, and API structures without utilizing aggressive active scanning that could trigger SOC alerts.
**Threat Modeling:** Applied MITRE ATT&CK and STRIDE frameworks to contextualize the discovered infrastructure, identifying the administrative portal's file handling and API token management as the most probable risks to the IoT management plane.
**Vulnerability Analysis:** Conducted targeted manual probing of the admin portal's upload logic and the API's authorization schemas to validate weaknesses, strictly separating theoretical risks from confirmed flaws.
**Exploitation:** Successfully deployed a custom, hand-crafted polyglot file to bypass the administrative portal's validation, strictly adhering to the no-Metasploit constraint to ensure payload stability and prevent availability degradation.
**Post-Exploitation:** Pivoted from the compromised administrative web server to the internal API using exposed environment variables, demonstrating access to NIS2-sensitive configuration data while strictly avoiding interaction with any customer-owned networks.
**Reporting:** Translated the raw action logs and technical findings into a business-aligned conformity packet, prioritizing actionable remediation strategies for the Lumen CISO and downstream industrial auditors.

## 4. Findings

### 4.1 Unrestricted File Upload Leading to Remote Code Execution (RCE)
**Severity:** Critical

- **Technical description:** The `/admin/upload` endpoint on `admin.lumen.example` relies solely on "magic bytes" (`mime_content_type()`) to validate uploaded files. By prepending valid PNG magic bytes to a PHP script, the server accepted the payload. The web server is misconfigured to execute files containing PHP tags regardless of the file extension, resulting in an immediate web shell.
- **CVSS environmental:** 9.9 (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`). *Justification:* Unauthenticated, remote network access leads to total system compromise and allows a pivot into internal network segments.
- **NIS2 article relevance:** Article 21, paragraph 2(d) - Supply chain security; 2(e) - Security in network and information systems acquisition, development, and maintenance.
- **Business impact for Lumen:** Complete compromise of the administrative portal allows attackers to manipulate internal data or pivot deeper into the network, catastrophically violating the trust of downstream industrial clients and halting operations.
- **Remediation:** Implement strictly enforced file extension whitelists. Ensure the upload directory is configured to prevent execution (e.g., preventing the `/uploads/` path from routing to the PHP-FPM handler). 

### 4.2 Local File Inclusion / Secret Exposure via Environment Variables
**Severity:** High

- **Technical description:** Upon achieving RCE on `admin.lumen.example`, local file read capabilities were utilized to bypass a 403 Forbidden restriction on the `/admin/.env` file. Reading the `.env` file from the parent directory revealed critical infrastructure secrets, specifically the `API_MASTER_TOKEN`.
- **CVSS environmental:** 7.7 (`CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`). *Justification:* Though dependent on an initial compromise for execution, the exposure of master tokens provides immediate lateral movement capabilities to critical backend systems.
- **NIS2 article relevance:** Article 21, paragraph 2(a) - Policies on risk analysis and information system security.
- **Business impact for Lumen:** Storing master credentials in plaintext on an external-facing web server collapses the internal security perimeter, directly enabling the compromise of the central IoT management plane.
- **Remediation:** Remove hardcoded secrets from local environment files on web servers. Migrate all sensitive credentials to a dedicated, encrypted secrets management vault and inject them at runtime using least-privilege service roles.

### 4.3 Broken Object Level Authorization (BOLA) Suspected on Public API
**Severity:** Medium

- **Technical description:** The public API (`api.lumen.example`) utilizes predictable, sequential numerical identifiers for sensor endpoints (e.g., `/v1/sensors/101`). This structure suggests a potential BOLA vulnerability where an authenticated user could iterate IDs to view cross-tenant telemetry.
- **CVSS environmental:** 5.3 (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N`).
- **NIS2 article relevance:** Article 21, paragraph 2(f) - Basic computer hygiene practices and cybersecurity training.
- **Business impact for Lumen:** If exploitable, cross-tenant data leakage would violate SLAs and industrial confidentiality agreements.
- **Remediation:** Transition from sequential numerical IDs to cryptographically secure, unpredictable UUIDs (v4) for all API endpoints.

## 5. Exploitation Narrative

The exploitation phase was executed manually, ensuring absolute control over the targeted infrastructure. 

1. **Foothold:** Enumeration of `admin.lumen.example` revealed an exposed `/admin/upload` directory. A custom polyglot payload (`polyglot.png`) was crafted locally by prepending PNG magic bytes to a PHP system command shell. The payload was submitted via a POST request and successfully stored at `/uploads/polyglot.png`. Navigating to the file with `?cmd=id` confirmed code execution as the `www-data` user on Lumen-controlled infrastructure.
2. **Pivot:** Using the established web shell, local commands were executed to read the restricted `.env` file, bypassing the web server's 403 access control. This yielded the `API_MASTER_TOKEN`.
3. **Impact Chain:** The extracted token was utilized to authenticate against the internal API. This pivot granted access to the central IoT management plane (`/v1/internal/iot/management/central-config`), returning centralized internal server configurations—a critical, NIS2-sensitive data class. At no point was traffic directed toward out-of-scope customer environments.

## 6. Recommendations

**Short-Term Posture (0-30 Days):**
1. Disable execution of scripts in all web application upload directories immediately.
2. Implement strict, server-side file extension whitelisting on all upload endpoints.
3. Invalidate and rotate the compromised `API_MASTER_TOKEN` and any other secrets exposed in the `admin.lumen.example` environment files.

**Long-Term Posture (1-6 Months):**
1. Migrate to a centralized secrets management solution to eliminate localized `.env` credential storage.
2. Adopt a Zero Trust Architecture (ZTA) internally. The compromise of a peripheral administrative portal should not intrinsically grant network routes or token trust to the central IoT management API.
3. Conduct comprehensive, authenticated penetration testing specifically focused on cross-tenant data isolation on the public-facing API.

## 7. Limitations and Uncertainty

This assessment was limited to a specific time window and a strictly defined set of external assets. Automated exploitation frameworks were explicitly banned for initial access, meaning the assessment accurately reflects the risk of highly targeted manual attacks but may not comprehensively map vulnerabilities typically caught by widespread automated scanning. 

**Scope Event Encountered:** During Phase 4 (Vulnerability Analysis), an active MQTT telemetry broadcast stream on the in-scope demo broker was observed referencing IP links to customer-deployed edge warehouses. Applying strict scope discipline, all probing of those specific topics and IP ranges was instantly halted. No packets were sent to customer infrastructure, preserving the legal boundaries of the engagement.

## 8. Appendices

### A. Sourced Findings
- Upload bypass techniques adapted from standard MIME-type spoofing methodologies (CWE-434).
- BOLA methodology based on OWASP API Security Top 10 (API1:2023).

### B. Action Log Excerpt
- `2026-05-13T14:22:08Z` | `curl POST polyglot.png to /admin/upload` | 200 OK. Polyglot payload bypassed MIME validation.
- `2026-05-13T14:24:31Z` | `id` via uploaded webshell | Confirmed execution `uid=33(www-data)`.
- `2026-05-13T14:35:12Z` | `curl ...?cmd=cat%20../.env` | Extracted `API_MASTER_TOKEN`.
- `2026-05-13T14:55:30Z` | `curl -H "Authorization: Bearer <API_MASTER_TOKEN>"` to `/central-config` | Impact confirmed on internal API.

### C. Framework References
- **PTES (Penetration Testing Execution Standard):** Pre-engagement to Reporting flow utilized throughout the assessment.
- **MITRE ATT&CK:** T1505.003 (Web Shell), T1552.005 (Unsecured Credentials).
- **NIS2 Directive (EU) 2022/2555:** Emphasizing Article 21 incident reporting obligations.
