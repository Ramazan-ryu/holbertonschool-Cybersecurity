# Active Reconnaissance Report, Astralis Cloud Services
Prepared by: Junior Reconnaissance Specialist, Vanguard Security
For: Marcus Bauer, Lead Red Teamer, Vanguard Security
Date: 2026-07-02

## Executive summary
This document details the active reconnaissance phase against Astralis Cloud Services (`astralis-cloud.example`). Executed under strict Rules of Engagement (RoE) requiring moderate-intensity scanning and no exploitation, the objective was to map the external perimeter. The reconnaissance successfully uncovered shadow infrastructure, an undocumented API surface, and a vulnerable web stack. Security controls are heavily weighted toward public endpoints, leaving internal and administrative components reliant on obscurity.

## Infrastructure cartography
### Network topology
The infrastructure resides within a distinct Autonomous System (ASN) attributed via BGP. The network is segmented into public-facing gateways and internally routed administrative functions, with the latter intentionally obscured on non-standard, ephemeral TCP ports rather than strict firewall drops.

### DNS structure
The DNS relies on a centralized primary authoritative nameserver. While basic passive transfers fail, moderate-intensity brute-force enumeration revealed semantic sub-naming conventions (`internal-`, `backend-`) indicating hidden infrastructure. DMARC TXT records manage email authentication policies, defining the viability of domain-spoofing campaigns.

### Exposed services
The perimeter is protected by a WAF/CDN edge layer fronting the TLS (443) web applications. However, critical deviations include administrative interfaces on ephemeral ports (>49152) and publicly resolvable cloud object storage buckets (S3) following predictable naming patterns.

## Service and version inventory
| Asset | Service Type | Identified Stack | Notes |
| :--- | :--- | :--- | :--- |
| `portal.astralis-cloud.example` | Web Gateway | Nginx | Version extracted via HTTP headers |
| `portal.astralis-cloud.example` | WAF / CDN | Verified | Provider identified via header signatures |
| `admin.astralis-cloud.example` | Admin Service | Unknown | TCP Port > 49152 |
| `*.s3.amazonaws.com` | Object Storage | AWS S3 | Verified via HTTP 403 status |

## Identified attack surface
### DNS
Active enumeration breached the passive ceiling, revealing internal subdomains. DMARC directives frame the social engineering and phishing boundaries for the red team.
### Network
The network relies on port obscurity for administrative access. A throttled TCP connect scan bypassed potential protections to identify a live ephemeral port on the admin node.
### Application
The application surface leaks significant intelligence. `robots.txt` discloses an administrative path, TLS certificates expose internal SAN hostnames, and an active API endpoint is suspiciously omitted from the published OpenAPI documentation.
### Mail
DMARC policy directives dictate our email spoofing capabilities for upcoming phishing campaigns against their new federal client.
### Cloud
Cloud storage buckets mapped to the Astralis brand exist and are reachable, providing targets for subsequent IAM or credential-stuffing enumeration.

## Prioritized targets for enumeration
1. **The Undocumented API Endpoint:** Omitted from the OpenAPI spec, this endpoint likely lacks standard WAF scrutiny and rigorous authentication, making it a prime initial access target.
2. **The Disclosed robots.txt Admin Path:** An exposed administrative dashboard represents a direct vector for credential stuffing using the M7/0x00 OSINT package.
3. **The High-Severity NVD Target:** The Nginx web server version maps directly to a critical CVSS v3.1 vulnerability. The red team must cross-reference this against available PoC exploits.

## Methodology documentation
1. **Primary Nameserver:** `dig +short NS astralis-cloud.example | head -n 1 | sed 's/\.$//'` (Target: `astralis-cloud.example`)
2. **Hidden Subdomain:** `gobuster dns --domain astralis-cloud.example -w /usr/share/wordlists/astralis-subdomains.txt -t 5 -q | grep -E 'internal|backend|admin' | grep -oE '[a-zA-Z0-9.-]+\.astralis-cloud\.example' | head -n 1` (Target: `astralis-cloud.example`)
3. **Astralis ASN:** `ip=$(dig +short astralis-cloud.example | head -n 1) && curl -s -m 10 "https://api.bgpview.io/ip/$ip" | jq -r '.data.prefixes[0].asn.asn' | awk '{print "AS"$1}'` (Target: BGP DB)
4. **Non-Standard Admin Port:** `timeout 120 nmap -sT -T2 --max-rate 100 -p 49152-65535 admin.astralis-cloud.example | grep 'open' | awk -F/ '{print $1}' | head -n 1` (Target: `admin.astralis-cloud.example`)
5. **Portal Version:** `curl -s -I -m 10 portal.astralis-cloud.example | grep -i '^Server:' | head -n 1 | awk '{print $2}' | tr -d '\r'` (Target: `portal.astralis-cloud.example`)
6. **Internal SAN Entry:** `timeout 10 openssl s_client -connect portal.astralis-cloud.example:443 -servername portal.astralis-cloud.example < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -Eo 'DNS:[a-zA-Z0-9.-]+' | cut -d ':' -f 2 | grep -E 'internal|backend|admin|mgmt' | head -n 1` (Target: `portal:443`)
7. **Admin Path:** `curl -s -m 10 https://portal.astralis-cloud.example/robots.txt | grep -i '^Disallow:' | grep -E 'admin|manage|backend|console' | awk '{print $2}' | tr -d '\r' | head -n 1` (Target: `robots.txt`)
8. **DMARC Policy:** `dig +short TXT _dmarc.astralis-cloud.example | grep -Eo 'p=(none|quarantine|reject)' | awk -F= '{print $2}' | head -n 1` (Target: `_dmarc.astralis-cloud.example`)
9. **WAF Provider:** `wafw00f portal.astralis-cloud.example | grep -i 'is behind' | awk '{print $NF}' || curl -s -I -m 10 portal.astralis-cloud.example | grep -iE 'Server:|CF-RAY|X-Amz-Cf-Id|X-Served-By' | grep -vi 'nginx' | awk -F': ' '{print $2}' | tr -d '\r' | head -n 1` (Target: WAF Edge)
10. **Storage Bucket:** `for b in astralis astralis-cloud astralis-assets astralis-prod astralis-dev astralis-backup astralis-public astralis-static; do code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "https://${b}.s3.amazonaws.com"); if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ] || [ "$code" = "403" ]; then echo "$b"; exit 0; fi; done` (Target: S3)
11. **Undocumented API:** `for url in $(curl -s -m 10 https://status.astralis-cloud.example | grep -Eo 'https://api.astralis-cloud.example/v1/[a-zA-Z0-9./_-]+' | sort -u); do path=$(echo "$url" | sed 's|https://api.astralis-cloud.example||'); if ! curl -s -m 10 https://api.astralis-cloud.example/v1/docs/openapi.json | jq -r '(.paths, .components) | objects | keys[]' | grep -qx "$path"; then code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$url"); if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ] || [ "$code" = "401" ] || [ "$code" = "403" ]; then echo "https://api.astralis-cloud.example$path"; exit 0; fi; fi; done` (Target: OpenAPI)
12. **Critical CVE:** `product="nginx"; version=$(curl -s -I -m 10 portal.astralis-cloud.example | grep -i 'Server:' | awk '{print $2}' | cut -d/ -f2 | tr -d '\r'); curl -s -m 10 "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${product}+${version}" | jq -r '.vulnerabilities | sort_by(.cve.metrics.cvssMetricV31[0].cvssData.baseScore) | last | .cve.id' | grep 'CVE' | head -n 1` (Target: NVD)

## Limitations and uncertainty
The reconnaissance phase was inherently limited by the RoE, leaving several specific knowledge gaps:
* **Admin Port Unknowns:** We identified an open ephemeral port (>49152), but without aggressive service fingerprinting (which was restricted), we have no idea if it hosts SSH, a proprietary web dashboard, or a honeypot.
* **Incomplete DNS Coverage:** To honor rate limits, our DNS brute-force was severely throttled. We almost certainly missed deeper shadow infrastructure and non-standard subdomains that a full-speed sweep would have caught.
* **API Authentication Blindness:** The undocumented API endpoint was verified to exist via HTTP status codes, but we have zero visibility into its required JSON schema, payloads, or authentication mechanisms.
* **S3 Content Opacity:** The cloud storage bucket returned a 403 Forbidden. While this confirms existence, we are completely blind to its actual contents, permissions, or relevance to the engagement.
* **False Positive Vulnerabilities:** The critical CVE identification relies entirely on the HTTP `Server` header. If the client has backported security patches without updating the web server banner, this finding is a false positive.
* **UDP Blind Spot:** All network scans were restricted strictly to TCP Connect. We have zero knowledge of any exposed UDP surfaces.

## Appendix script-to-flag index
* Task 1: 1-nameserver.sh -> ns1.example.com
* Task 2: 2-hidden_subdomain.sh -> internal-svc.example.com
* Task 3: 3-asn.sh -> AS64500
* Task 4: 4-admin_port.sh -> 54321
* Task 5: 5-portal_version.sh -> nginx/1.0.0
* Task 6: 6-san_entry.sh -> internal-mgmt.example.com
* Task 7: 7-admin_path.sh -> /admin/dashboard
* Task 8: 8-dmarc.sh -> quarantine
* Task 9: 9-waf.sh -> ExampleWAF
* Task 10: 10-bucket.sh -> example-prod-eu
* Task 11: 11-undoc_endpoint.sh -> https://api.example.com/v1/internal/example
* Task 12: 12-cve.sh -> CVE-2024-00000
