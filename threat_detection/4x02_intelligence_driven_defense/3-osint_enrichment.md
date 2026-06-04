# OSINT Enrichment - HEALTHBANE Campaign

## Overview

This document enriches the actionable indicators identified during Task 1.
The enrichment process transforms raw indicators into intelligence-grade
artifacts that support defensive operations and detection engineering.

Because this lab environment does not require live internet access,
simulated evidence from:
- HC3 advisory
- commercial intelligence feed
- researcher blog
- MedDefense findings

was used alongside documented OSINT collection methods.

---

# 1. Enrichment Methodology

## Common OSINT Methods

| Enrichment Type | Example Command / Method |
|---|---|
| WHOIS | `whois domain.com` |
| DNS Resolution | `dig domain.com` |
| Passive DNS | SecurityTrails / RiskIQ / VirusTotal |
| Certificate Transparency | `crt.sh?q=domain.com` |
| Reverse DNS | `dig -x <IP>` |
| ASN Lookup | `whois <IP>` or bgp.he.net |
| Hash Reputation | VirusTotal / MalwareBazaar |
| URL Reputation | VirusTotal URL analysis |

---

# 2. Domain Enrichment

---

## meddefense-portal.com

### WHOIS
- Registration Date: 2026-04-09
- Registrar: Namecheap
- Registrant: Privacy protected

### DNS Resolution
- Current IP: 91.234.99.107
- Historical Resolution:
  - Same IP observed across campaign window
  - Linked to phishing infrastructure

### Certificate Transparency
### Query Method
```bash
crt.sh?q=meddefense-portal.com
```

### Findings
- Let's Encrypt certificate observed
- Certificate issued within 7 days of phishing activity
- Related domains share similar issuance timing

### Reputation
- VirusTotal: Multiple phishing detections
- Community tagging:
  - phishing
  - credential-harvest
  - healthcare spoofing

### Defensive Meaning
- BLOCK at DNS and proxy layers
- ALERT on outbound requests
- HUNT for historical access logs

### Confidence Impact
Enrichment increases confidence due to:
- registration timing
- phishing kit overlap
- shared infrastructure correlation

### Actionability
REMAINS ACTIONABLE

---

## medequip-supplies.net

### WHOIS
- Registration Date: 2026-04-08
- Registrar: Namecheap
- Registrant: Hidden

### DNS Resolution
- Current IP: 185.176.43.22
- Historical:
  - Stable phishing infrastructure during campaign

### Certificate Transparency
```bash
crt.sh?q=medequip-supplies.net
```

### Findings
- Let's Encrypt certificate
- Similar issuance pattern to other HEALTHBANE domains

### Reputation
- Tagged in commercial feed as phishing infrastructure
- Corroborated by HC3 and MedDefense

### Defensive Meaning
- BLOCK
- ALERT
- Retrospective log hunting

### Confidence Impact
Confidence strengthened through multi-source corroboration.

### Actionability
REMAINS ACTIONABLE

---

## meddefense-benefits.org

### WHOIS
- Registration Date: 2026-04-10
- Registrar: Namecheap

### DNS Resolution
- Current IP: 164.90.218.73
- Hosting: DigitalOcean

### Certificate Transparency
```bash
crt.sh?q=meddefense-benefits.org
```

### Findings
- Short-lived Let's Encrypt certificate
- Issued shortly before phishing activity

### Reputation
- Referenced by HC3 and internal MedDefense findings

### Defensive Meaning
- BLOCK
- Monitor authentication logs for related activity

### Confidence Impact
Maintains HIGH confidence.

### Actionability
REMAINS ACTIONABLE

---

## outlook-protection.com

### WHOIS
- Registrar: Namecheap
- Registration Date: Observed during campaign period

### DNS Resolution
- Current IP: 51.38.42.17
- Hosting Provider: OVH

### Certificate Transparency
```bash
crt.sh?q=outlook-protection.com
```

### Findings
- Microsoft impersonation style certificate naming
- Operational phishing infrastructure

### Reputation
- Known phishing domain
- SPF/DKIM correctly configured for deception

### Defensive Meaning
- BLOCK
- ALERT on inbound email references
- Hunt for user interaction

### Confidence Impact
High-confidence phishing infrastructure.

### Actionability
REMAINS ACTIONABLE

---

## healthbane-c2.net

### WHOIS
- Registrar: Njalla
- Registration Date: Prior to Stage 2 activity

### DNS Resolution
- Current IP: 51.38.42.191
- Historical:
  - Persistent C2 infrastructure

### Certificate Transparency
```bash
crt.sh?q=healthbane-c2.net
```

### Findings
- Self-managed operational infrastructure
- Associated subdomains:
  - data-sync.healthbane-c2.net

### Reputation
- Strong malicious reputation
- DNS tunneling activity confirmed

### Defensive Meaning
- BLOCK immediately
- Sinkhole if possible
- Hunt for DNS queries

### Confidence Impact
Highest confidence infrastructure indicator.

### Actionability
REMAINS ACTIONABLE

---

## data-sync.healthbane-c2.net

### WHOIS
- Subdomain of healthbane-c2.net

### DNS Resolution
- Current Resolution:
  - 51.38.42.191

### Certificate Transparency
- Covered under parent certificate activity

### Reputation
- Confirmed DNS TXT tunneling endpoint

### Defensive Meaning
- BLOCK
- ALERT on long DNS TXT queries
- Hunt for Base32 encoded labels

### Confidence Impact
Confirmed exfiltration infrastructure.

### Actionability
REMAINS ACTIONABLE

---

## update-healthbane.net

### WHOIS
- Registrar: Not fully confirmed
- First Seen: 2026-04-16

### DNS Resolution
- Current IP: 45.77.218.9

### Certificate Transparency
```bash
crt.sh?q=update-healthbane.net
```

### Findings
- Limited certificate history
- Short operational lifespan

### Reputation
- Linked to Stage 2 payload delivery

### Defensive Meaning
- BLOCK
- Hunt for download activity

### Confidence Impact
Moderate-to-high confidence.

### Actionability
REMAINS ACTIONABLE

---

# 3. IP Enrichment

---

## 91.234.99.107

| Field | Value |
|---|---|
| ASN | AS47583 |
| Hosting Provider | Hostinger |
| Geolocation | Europe |
| Reverse DNS | Not meaningful |
| Reputation | Known phishing host |
| Blocking Risk | LOW |

### Defensive Meaning
Dedicated phishing infrastructure with repeated malicious use.

### Actionability
SAFE TO BLOCK

---

## 185.176.43.22

| Field | Value |
|---|---|
| ASN | AS47583 |
| Hosting Provider | Hostinger |
| Geolocation | Europe |
| Reputation | Credential harvesting infrastructure |
| Blocking Risk | LOW |

### Actionability
SAFE TO BLOCK

---

## 164.90.218.73

| Field | Value |
|---|---|
| ASN | AS14061 |
| Hosting Provider | DigitalOcean |
| Geolocation | United States |
| Reputation | Campaign-linked phishing host |
| Blocking Risk | LOW-MEDIUM |

### Defensive Meaning
Dedicated VPS used during campaign window.

### Actionability
BLOCK WITH MONITORING

---

## 51.38.42.17

| Field | Value |
|---|---|
| ASN | AS16276 |
| Hosting Provider | OVH |
| Geolocation | France |
| Reputation | Confirmed phishing infrastructure |
| Blocking Risk | LOW |

### Actionability
SAFE TO BLOCK

---

## 51.38.42.191

| Field | Value |
|---|---|
| ASN | AS16276 |
| Hosting Provider | OVH |
| Geolocation | France |
| Reputation | Confirmed C2 and DNS tunneling |
| Blocking Risk | LOW |

### Defensive Meaning
Critical operational infrastructure.

### Actionability
IMMEDIATE BLOCKING RECOMMENDED

---

## 45.77.218.9

| Field | Value |
|---|---|
| ASN | AS20473 |
| Hosting Provider | Vultr |
| Geolocation | United States |
| Reputation | Malware delivery host |
| Blocking Risk | LOW |

### Actionability
SAFE TO BLOCK

---

# 4. Hash Enrichment

---

## a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456

### File Information
| Field | Value |
|---|---|
| File Type | Microsoft Word Macro Document |
| Filename | HEALTHBANE_S2_invoice.docm |
| First Seen | 2026-04-16 |
| Behavioral Tags | macro, phishing, downloader |
| Detection Ratio | High detection consensus |

### Defensive Meaning
Macro-enabled delivery document used in Stage 2.

### Confidence Impact
Strongly corroborated across sources.

### Actionability
CAMPAIGN-SPECIFIC AND ACTIONABLE

---

## b9c8a7d6e5f4321098765432109876543210fedcba9876543210fedcba987654

### File Information
| Field | Value |
|---|---|
| File Type | Windows PE Executable |
| Filename | svchost_update.exe |
| First Seen | 2026-04-16 |
| Behavioral Tags | trojan, persistence, scheduled-task |
| Detection Ratio | High |

### Defensive Meaning
Primary Stage 2 malware payload.

### Confidence Impact
High-confidence malware artifact.

### Actionability
ACTIONABLE

---

## c7d6e5f4a3b291827364554637281900a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6

### File Information
| Field | Value |
|---|---|
| File Type | PowerShell Script |
| Filename | sync_healthdata.ps1 |
| First Seen | 2026-04-18 |
| Behavioral Tags | exfiltration, DNS tunneling, PowerShell |
| Detection Ratio | Moderate-to-high |

### Defensive Meaning
Exfiltration script used for DNS-based data theft.

### Confidence Impact
Corroborated by HC3 and researcher analysis.

### Actionability
HIGHLY ACTIONABLE

---

# 5. Enrichment Impact Summary

## Indicators Remaining Actionable

The following remained actionable after enrichment:
- phishing domains
- C2 infrastructure
- malware hashes
- dedicated VPS infrastructure

These indicators were supported by:
- multiple independent sources
- timing correlation
- infrastructure reuse
- operational overlap

---

## Indicators That Require Caution

Some infrastructure still requires careful handling:
- DigitalOcean hosted systems
- VPS infrastructure with possible tenant reuse

These should be:
- monitored
- validated against internal telemetry
- blocked selectively

---

# 6. Defensive Recommendations

## Immediate Blocking
- healthbane-c2.net
- data-sync.healthbane-c2.net
- 51.38.42.191
- phishing delivery domains
- confirmed malware hashes

## Alerting and Hunting
- PHPMailer 6.6.0 headers
- newly registered healthcare-themed domains
- long DNS TXT queries
- Base32/Base64 DNS subdomains
- scheduled task persistence

## Monitoring
- authentication anomalies
- outbound DNS tunneling patterns
- PowerShell encoded command execution

---

# 7. Final Assessment

OSINT enrichment significantly increased confidence for the core
HEALTHBANE infrastructure.

The strongest indicators shared:
- consistent registrar usage
- coordinated registration windows
- overlapping hosting providers
- certificate timing overlap
- shared phishing kit artifacts
- multi-source corroboration

The enrichment process confirmed that the campaign used:
- rapidly deployed phishing infrastructure
- VPS-based hosting
- short-lived certificates
- reusable operational tooling

These patterns support durable behavioral detection beyond simple IOC
blocking.
