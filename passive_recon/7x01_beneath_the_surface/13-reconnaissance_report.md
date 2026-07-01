# Active Reconnaissance Report, Astralis Cloud Services
Prepared by: Junior Reconnaissance Specialist, Vanguard Security
For: Marcus Bauer, Lead Red Teamer, Vanguard Security
Date: 2026-07-02

## Executive summary
This document details the active reconnaissance phase against Astralis Cloud Services (`astralis-cloud.example`). Executed under strict Rules of Engagement (RoE) requiring moderate-intensity scanning and no exploitation, the objective was to map the external perimeter. The reconnaissance uncovered shadow infrastructure, an undocumented API surface, and a vulnerable web stack.

## Infrastructure cartography
### Network topology
The infrastructure resides within a distinct Autonomous System (ASN). The network is segmented into public-facing gateways and internally routed administrative functions obscured on non-standard, ephemeral TCP ports.
### DNS structure
The DNS relies on a centralized primary authoritative nameserver. Moderate-intensity brute-force enumeration revealed semantic sub-naming conventions indicating hidden infrastructure. DMARC TXT records manage email authentication policies.
### Exposed services
The perimeter is protected by a WAF/CDN edge layer. Critical deviations include administrative interfaces on ephemeral ports and publicly resolvable cloud object storage buckets.

## Service and version inventory
| Asset | Service Type | Identified Stack |
| :--- | :--- | :--- |
| `portal.astralis-cloud.example` | Web Gateway | Nginx |
| `portal.astralis-cloud.example` | WAF / CDN | Verified |
| `admin.astralis-cloud.example` | Admin Service | Unknown |
| `*.s3.amazonaws.com` | Object Storage | AWS S3 |

## Identified attack surface
### DNS
Active enumeration revealed internal subdomains. DMARC directives frame the social engineering and phishing boundaries for the red team.
### Network
The network relies on port obscurity for administrative access. A throttled TCP connect scan identified a live ephemeral port on the admin node.
### Application
`robots.txt` discloses an administrative path, TLS certificates expose internal SAN hostnames, and an active API endpoint is omitted from the published OpenAPI documentation.
### Mail
DMARC policy directives dictate our email spoofing capabilities for upcoming phishing campaigns.
### Cloud
Cloud storage buckets mapped to the Astralis brand exist and are reachable, providing targets for enumeration.

## Prioritized targets for enumeration
1. **The Undocumented API Endpoint:** Omitted from the OpenAPI spec, making it a prime initial access target.
2. **The Disclosed robots.txt Admin Path:** An exposed dashboard represents a direct vector for credential stuffing.
3. **The High-Severity NVD Target:** The Nginx web server version maps directly to a critical CVSS v3.1 vulnerability.

## Methodology documentation
1. `dig +short NS astralis-cloud.example | head -n 1 | sed 's/\.$//'` (Target: `astralis-cloud.example`)
2. `gobuster dns --domain astralis-cloud.example -w /usr/share/wordlists/astralis-subdomains.txt -t 5 -q | grep -E 'internal|backend|admin' | grep -oE '[a-zA-Z0-9.-]+\.astralis-cloud\.example' | head -n 1` (Target: `astralis-cloud.example`)
3. `ip=$(dig +short astralis-cloud.example | head -n 1) && curl -s -m 10 "https://api.bgpview.io/ip/$ip" | jq -r '.data.prefixes[0].asn.asn' | awk '{print "AS"$1}'` (Target: BGP API)
4. `timeout 120 nmap -sT -T2 --max-rate 100 -p 49152-65535 admin.astralis-cloud.example | grep 'open' | awk -F/ '{print $1}' | head -n 1` (Target: `admin.astralis-cloud.example`)
5. `curl -s -I -m 10 portal.astralis-cloud.example | grep -i '^Server:' | head -n 1 | awk '{print $2}' | tr -d '\r'` (Target: `portal.astralis-cloud.example`)
6. `timeout 10 openssl s_client -connect portal.astralis-cloud.example:443 -servername portal.astralis-cloud.example < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -Eo 'DNS:[a-zA-Z0-9.-]+' | cut -d ':' -f 2 | grep -E 'internal|backend|admin|mgmt' | head -n 1` (Target: `portal:443`)
7. `curl -s -m 10 https://portal.astralis-cloud.example/robots.txt | grep -i '^Disallow:' | grep -E 'admin|manage|backend|console' | awk '{print $2}' | tr -d '\r' | head -n 1` (Target: `robots.txt`)
8. `dig +short TXT _dmarc.astralis-cloud.example | grep -Eo 'p=(none|quarantine|reject)' | awk -F= '{print $2}' | head -n 1` (Target: `_dmarc.astralis-cloud.example`)
9. `wafw00f portal.astralis-cloud.example | grep -i 'is behind' | awk '{print $NF}' || curl -s -I -m 10 portal.astralis-cloud.example | grep -iE 'Server:|CF-RAY|X-Amz-Cf-Id|X-Served-By' | grep -vi 'nginx' | awk -F': ' '{print $2}' | tr -d '\r' | head -n 1` (Target: WAF Edge)
10. `for b in astralis astralis-cloud astralis-assets astralis-prod astralis-dev astralis-backup astralis-public astralis-static; do code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "https://${b}.s3.amazonaws.com"); if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ] || [ "$code" = "403" ]; then echo "$b"; exit 0; fi; done` (Target: S3)
11. `for url in $(curl -s -m 10 https://status.astralis-cloud.example | grep -Eo 'https://api.astralis-cloud.example/v1/[a-zA-Z0-9./_-]+' | sort -u); do path=$(echo "$url" | sed 's|https://api.astralis-cloud.example||'); if ! curl -s -m 10 https://api.astralis-cloud.example/v1/docs/openapi.json | jq -r '(.paths, .components) | objects | keys[]' | grep -qx "$path"; then code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$url"); if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ] || [ "$code" = "401" ] || [ "$code" = "403" ]; then echo "https://api.astralis-cloud.example$path"; exit 0; fi; fi; done` (Target: OpenAPI)
12. `product="nginx"; version=$(curl -s -I -m 10 portal.astralis-cloud.example | grep -i 'Server:' | awk '{print $2}' | cut -d/ -f2 | tr -d '\r'); curl -s -m 10 "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${product}+${version}" | jq -r '.vulnerabilities | sort_by(.cve.metrics.cvssMetricV31[0].cvssData.baseScore) | last | .cve.id' | grep 'CVE' | head -n 1` (Target: NVD)

## Limitations and uncertainty
Our methodology successfully identified the surface, but the strict Rules of Engagement leave several critical findings uncertain:
* **Admin Port Service Unknown:** We identified the ephemeral port `54321` is open, but because we only performed a TCP Connect scan, the actual application/service running on it remains entirely unknown.
* **Storage Bucket Contents Unknown:** We confirmed the existence of the bucket `example-prod-eu` via HTTP status codes, but we do not know if it contains sensitive PII or benign assets because listing contents was prohibited.
* **Undocumented API Functionality Unverified:** We discovered the hidden endpoint `https://api.example.com/v1/internal/example`, but because we did not send functional payloads, it is completely uncertain what data it handles or if it is vulnerable.
* **CVE Applicability is Uncertain:** We identified `CVE-2024-00000` via the web server banner `nginx/1.0.0`. It remains uncertain if the target is actually vulnerable because Astralis may have backported security patches while leaving the original banner intact.

## Appendix : script-to-flag index
* `1-nameserver.sh` produced `ns1.example.com`
* `2-hidden_subdomain.sh` produced `internal-svc.example.com`
* `3-asn.sh` produced `AS64500`
* `4-admin_port.sh` produced `54321`
* `5-portal_version.sh` produced `nginx/1.0.0`
* `6-san_entry.sh` produced `internal-mgmt.example.com`
* `7-admin_path.sh` produced `/admin/dashboard`
* `8-dmarc.sh` produced `quarantine`
* `9-waf.sh` produced `ExampleWAF`
* `10-bucket.sh` produced `example-prod-eu`
* `11-undoc_endpoint.sh` produced `https://api.example.com/v1/internal/example`
* `12-cve.sh` produced `CVE-2024-00000`
