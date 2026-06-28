# Threat Model, Lumen Industrial Systems

## Framework Mix
This threat model employs a hybrid framework approach to accurately capture the multi-dimensional risks facing Lumen Industrial Systems. **PASTA (Process for Attack Simulation and Threat Analysis)** is utilized to frame business-centric and regulatory threats, specifically addressing the stringent compliance requirements of NIS2. **MITRE ATT&CK** categorizes direct, tactical exploitation risks against the external infrastructure discovered during active reconnaissance. Finally, **STRIDE** is applied to decompose architectural and application-logic flaws inherent to the exposed API and cloud microservices, providing actionable context for the vulnerability analysis phase.

## Threat Matrix

| # | Threat | Asset | Framework Tag | Severity | Rationale |
| --- | --- | --- | --- | --- | --- |
| 1 | Exploitation of Public-Facing Application | `vpn.lumen-industrial.com` | MITRE-T1190 | Critical | Recon surfaced legacy VPN firmware versions; poses an immediate risk for unauthenticated initial access to the internal network. |
| 2 | API Authentication Bypass | `api.lumen-industrial.com` | STRIDE-Spoofing | Critical | Automated recon highlighted missing uniform rate-limiting and fragmented authentication controls across v1 and v2 API endpoints. |
| 3 | Malicious File Upload (Web Shell) | `portal.lumen-industrial.com` | MITRE-T1505.003 | High | The contractor portal exposes an unauthenticated document submission form, introducing the risk of remote code execution. |
| 4 | Credential Stuffing / Password Spraying | `portal.lumen-industrial.com` | MITRE-T1110.004 | High | OSINT on LinkedIn and Hunter.io surfaced 50+ valid employee email formats, providing a rich dataset for targeted credential attacks. |
| 5 | Data Exposure via Misconfigured Storage | `s3-lumen-industrial-assets` | STRIDE-Info Disclosure | High | Cloud storage enumeration revealed an indexable AWS S3 bucket containing legacy architecture diagrams and vendor contracts. |
| 6 | Privilege Escalation via IDOR | `api.lumen-industrial.com` | STRIDE-Elevation | High | Public API documentation caching indicates the use of predictable, sequential object identifiers rather than UUIDs. |
| 7 | Regulatory Non-Compliance & Fines (NIS2) | Corporate Data Assets | PASTA-Stage-VII | High | If a compromise occurs via the external perimeter, Lumen faces aggressive NIS2 reporting timelines and severe financial penalties. |
| 8 | Subdomain Takeover via Dangling CNAME | `marketing.lumen-industrial.com` | MITRE-T1584.001 | Medium | DNS reconnaissance discovered a CNAME record pointing to an abandoned third-party SaaS provider, risking malicious domain hijacking. |
| 9 | Resource Exhaustion (DoS) | `admin.lumen-industrial.com` | STRIDE-Denial of Service | Medium | The management microservice login page lacks WAF signatures or CAPTCHA, making it susceptible to automated availability degradation. |
| 10 | Third-Party Infrastructure Compromise | External Network ASNs | PASTA-Stage-IV | Medium | BGP and ASN mapping revealed heavy reliance on a single regional ISP, introducing a single point of failure in the supply chain. |
| 11 | Downgrade Attack (Man-in-the-Middle) | `*.lumen-industrial.com` | STRIDE-Tampering | Low | TLS enumeration tools identified support for deprecated TLS 1.1 cipher suites on secondary, non-critical subdomains. |
| 12 | Internal Network Topology Disclosure | Public DNS | STRIDE-Info Disclosure | Low | While zone transfers failed, verbose DNS TXT records leak internal IP routing schemes and Active Directory domain naming conventions. |

## Prioritisation Note
The top three threats in terms of business impact are the **Exploitation of the Public-Facing VPN** (Threat 1), **API Authentication Bypass** (Threat 2), and **Regulatory Non-Compliance via NIS2** (Threat 7). A successful compromise of the VPN or API directly jeopardizes Lumen’s core mandate of zero operational disruption, potentially bridging the gap between the external IT perimeter and critical industrial control systems (OT). Consequently, this would trigger an immediate NIS2 compliance crisis, exposing Lumen not only to severe operational downtime but also to catastrophic regulatory fines and reputational damage among its industrial customer base.
