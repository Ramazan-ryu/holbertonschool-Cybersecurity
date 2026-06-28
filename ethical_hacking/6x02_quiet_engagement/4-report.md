# Penetration Test Report, Lumen Industrial Systems

**Engagement reference:** LIS-PT-2026Q2  
**Reporting period:** July 6, 2026 – July 17, 2026  
**Prepared by:** Junior Consultant, Vanguard Security  
**Distribution:** Lumen CISO, downstream NIS2 conformity packet recipients  

## 1. Executive Summary

During the engagement window, Vanguard Security conducted an external, grey-box penetration test against Lumen Industrial Systems' central management infrastructure. The primary objective was to assess the security posture of the perimeter ahead of critical NIS2 conformity audits, operating strictly under a mandate of zero operational disruption to live industrial assets. The assessment identified a critical vulnerability chain allowing unauthenticated threat actors to achieve remote code execution (RCE) on the central administrative panel. By exploiting an unrestricted file upload flaw, our team established a foothold and subsequently extracted master API credentials. This access permitted a lateral pivot into the internal IoT management plane, ultimately exposing centralized server configurations and cryptographic routing materials. These findings represent a critical risk to Lumen’s supply chain integrity and NIS2 compliance status. Promptly remediating the file upload mechanism and enforcing strict secrets management will sever this attack path and restore the integrity of the external perimeter.

## 2. Scope and Methodology

This engagement was governed by a strict Rules of Engagement (RoE) designed to isolate Lumen’s central IT/OT bridging infrastructure from downstream customer premises equipment. 

**In-Scope Assets:**
- Central Admin Panel (`admin.lumen.example`)
- Public REST API (`api.lumen.example`)
- Customer Web Portal (`portal.lumen.example`)
- Demo Edge Gateway (`gateway.demo.lumen.example`)
- Demo MQTT Broker (`mqtt.demo.lumen.example`)

**Out-of-Scope Assets:**
- Any customer-deployed edge gateways or warehouse sensors. (Reasoning: Lumen cannot authorize testing on physical or logical assets owned and operated by third parties).
- Third-party SaaS infrastructure and management planes.
- Social engineering and physical penetration testing.

Testing was conducted manually, prioritizing stealth and operational safety over automated, high-volume scanning. Exploitation was constrained by a strict "no-Metasploit" requirement for initial footholds to ensure highly controlled, bespoke payload delivery.

## 3. PTES Phase Summary

**Pre-engagement:** We established a strict, mutually agreed-upon Rules of Engagement document. Crucially, we delineated exact technical and legal boundaries, ensuring customer-owned edge devices were explicitly cordoned off to prevent third-party operational disruption.

**Intelligence Gathering:** We conducted non-intrusive reconnaissance against the in-scope assets, enumerating open ports, exposed endpoints, API methods, and available services without triggering defensive countermeasures.

**Threat Modeling:** We utilized a hybrid MITRE ATT&CK and STRIDE approach to contextualize the recon data. Threats were mapped directly to the surfaced assets, prioritizing risks like unauthorized API access, file upload bypasses, and unauthenticated telemetry exposure.

**Vulnerability Analysis:** We actively probed the identified services, evaluating input validation on the admin panel's upload function, authentication schemas on the API, and protocol configurations on the demo MQTT broker, distinguishing between theoretical weaknesses and confirmed flaws.

**Exploitation:** Relying entirely on custom-crafted payloads, we successfully bypassed file validation controls on the admin portal to achieve code execution. This confirmed the critical vulnerability without resorting to noisy, generic exploit frameworks.

**Post-Exploitation:** From the initial foothold, we escalated access by extracting local environment secrets, pivoting laterally to the internal API, and demonstrating access to highly sensitive, NIS2-regulated configuration data.

**Reporting:** We synthesized the raw action logs and technical evidence into this comprehensive deliverable, translating technical exploitation into actionable business and regulatory context for Lumen leadership and their industrial auditors.

## 4. Findings

### 4.1 Unrestricted File Upload Leading to Remote Code Execution (RCE)
**Severity:** Critical

- **Technical description:** The `/admin/upload` endpoint on `admin.lumen.example` relies solely on "magic bytes" (`mime_content_type()`) to validate uploaded files. By prepending valid PNG magic bytes (`\x89PNG\r\n\x1a\n`) to a PHP script payload (`polyglot.png`), the server accepts the file. Furthermore, the web server is misconfigured to execute any file containing PHP tags regardless of the `.png` extension, leading to a direct web shell implementation.
- **CVSS environmental:** 9.9 (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`). *Justification:* Unauthenticated, remote network access leads to total system compromise and allows a pivot into internal network segments.
- **NIS2 article relevance:** Article 21, paragraph 2(d) - Supply chain security; 2(e) - Security in network and information systems acquisition, development, and maintenance.
- **Business impact for Lumen:** Complete compromise of the administrative portal allows attackers to manipulate internal data, deploy ransomware, or pivot deeper into the network, catastrophically violating the trust of downstream industrial clients and halting operations.
- **Remediation:** Implement strictly enforced file extension whitelists (e.g., only `.png`, `.jpg`). Ensure the upload directory is configured to prevent execution (e.g., `php_admin_value engine Off` in Apache, or avoiding passing the `/uploads/` path to PHP-FPM in Nginx). 

### 4.2 Local File Inclusion / Secret Exposure via Environment Variables
**Severity:** High

- **Technical description:** Upon achieving RCE on `admin.lumen.example`, local file read capabilities were utilized to bypass a 403 Forbidden restriction on the `/admin/.env` file. Reading the `.env` file from the parent directory revealed critical infrastructure secrets, specifically the `API_MASTER_TOKEN`.
- **CVSS environmental:** 7.7 (`CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`). *Justification:* Though dependent on an initial compromise for execution, the exposure of master tokens provides immediate lateral movement capabilities without further exploitation.
- **NIS2 article relevance:** Article 21, paragraph 2(a) - Policies on risk analysis and information system security.
- **Business impact for Lumen:** Storing master credentials in plaintext on an external-facing web server collapses the internal security perimeter, directly enabling the compromise of the central IoT management plane.
- **Remediation:** Remove hardcoded secrets from `.env` files on web servers. Migrate all sensitive credentials to a dedicated, encrypted secrets management vault and inject them at runtime with least-privilege IAM roles.

### 4.3 Broken Object Level Authorization (BOLA) Suspected on Public API
**Severity:** Medium

- **Technical description:** The public API (`api.lumen.example`) utilizes predictable, sequential numerical identifiers for sensor endpoints (e.g., `/v1/sensors/101`). While full exploitation was unconfirmed, this structure heavily suggests a BOLA vulnerability where an authenticated user could iterate IDs to view cross-tenant telemetry.
- **CVSS environmental:** 5.3 (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N`).
- **Business impact for Lumen:** If exploitable, cross-tenant data leakage would violate SLAs and industrial confidentiality agreements.
- **Remediation:** Transition from sequential numerical IDs to cryptographically secure, unpredictable GUIDs/UUIDs (v4) for all API endpoints. Ensure rigorous authorization checks are performed on every object request to verify tenant ownership.

## 5. Exploitation Narrative

The exploitation phase was entirely driven by manual, targeted analysis without reliance on automated exploitation frameworks. 

1. **Foothold:** Port scanning and directory enumeration against `admin.lumen.example` revealed an exposed `/admin/upload` directory. Understanding the upload mechanism likely relied on superficial MIME-type checking, a polyglot payload (`polyglot.png`) was crafted locally. Valid PNG magic bytes were prepended to a standard PHP system command shell. The payload was submitted via a POST request to `/admin/upload` and stored at `/uploads/polyglot.png`. Navigating to the file with `?cmd=id` confirmed code execution as the `www-data` user.
2. **Pivot:** Using the established web shell, local commands were executed to read the restricted `.env` file (`?cmd=cat%20../.env`), successfully bypassing the web server's 403 access control. This yielded the `API_MASTER_TOKEN`.
3. **Impact Chain:** The extracted token was utilized to authenticate against the internal API (`api.lumen.example/v1/internal/iot/management`). This pivot granted access to the central IoT management plane. A final request was made to `/v1/internal/iot/management/central-config`, returning centralized internal server configurations—a critical, NIS2-sensitive data class proving systemic compromise without impacting live customer assets.

## 6. Recommendations

**Short-Term Posture (0-30 Days):**
1. Disable execution of scripts in all web application upload directories immediately.
2. Implement strict, server-side file extension whitelisting on all upload endpoints.
3. Invalidate and rotate the compromised `API_MASTER_TOKEN` and any other secrets exposed in the `admin.lumen.example` environment files.

**Long-Term Posture (1-6 Months):**
1. Migrate to a centralized secrets management solution to eliminate localized `.env` credential storage.
2. Adopt a Zero Trust Architecture (ZTA) internally. The compromise of a peripheral administrative portal should not intrinsically grant network routes or token trust to the central IoT management API.
3. Conduct comprehensive, authenticated penetration testing specifically focused on cross-tenant data isolation (BOLA/IDOR) on the public-facing API.

## 7. Limitations and Uncertainty

This assessment was limited to a specific time window and a strictly defined set of external assets. Automated exploitation frameworks (e.g., Metasploit) were explicitly banned for initial access, meaning the assessment accurately reflects the risk of highly targeted manual attacks but may not comprehensively map vulnerabilities typically caught by widespread automated scanning. 

**Scope Event Encountered:** During Phase 4 (Vulnerability Analysis), an active MQTT telemetry broadcast stream on `mqtt.demo.lumen.example` was observed referencing IP links to customer-deployed edge warehouses. Applying strict scope discipline and learning from prior industry incidents, all probing was instantly halted upon recognizing these off-scope assets. No packets were sent to customer infrastructure, preserving the legal boundaries of the engagement and adhering strictly to the mandate of zero operational disruption for third parties.

## 8. Appendices

### A. Sourced Findings
- Upload bypass techniques adapted from standard MIME-type spoofing methodologies (CWE-434: Unrestricted Upload of File with Dangerous Type).
- BOLA methodology based on OWASP API Security Top 10 (API1:2023).

### B. Action Log Excerpt
- `2026-05-13T14:22:08Z` | `curl POST polyglot.png to /admin/upload` | 200 OK. Polyglot payload bypassed MIME validation.
- `2026-05-13T14:24:31Z` | `id` via uploaded webshell | Confirmed execution `uid=33(www-data)`.
- `2026-05-13T14:35:12Z` | `curl ...?cmd=cat%20../.env` | Extracted `API_MASTER_TOKEN`.
- `2026-05-13T14:55:30Z` | `curl -H "Authorization: Bearer <API_MASTER_TOKEN>"` to `/central-config` | Impact confirmed on internal API.

### C. Framework References
- **PTES (Penetration Testing Execution Standard):** Pre-engagement to Reporting flow utilized throughout the assessment.
- **MITRE ATT&CK:** T1505.003 (Web Shell), T1552.005 (Unsecured Credentials), T1078 (Valid Accounts).
- **NIS2 Directive (EU) 2022/2555:** Emphasizing Article 21 (Cybersecurity risk-management measures) and incident reporting obligations.
