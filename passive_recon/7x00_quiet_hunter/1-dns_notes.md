# Task 1 — DNS & Subdomain Hunt

> Recover hosts and mail records the company would rather you didn't notice.

_Copy this file into `../my_notes/` and fill it in. Do not guess — every entry needs a source._

## Suggested sources

- Certificate-transparency search
- Passive-DNS history

## Findings to record

### 1. Forgotten/staging subdomain

- **Value:** `staging-quote.helix-maritime.example`
- **Exact source (URL / file / metadata field):** Simulated Certificate Transparency search (CertWatch)
- **Justification (1 line):** Subdomain identified in CT logs with a valid Let's Encrypt certificate, indicating an active non-production or testing quoting environment exposed to the internet.
- **Cross-reference / alternative ruled out:** Confirmed via passive CT logs; ruled out active probing, and validated that it belongs to the target domain's Subject Alt Names.

### 2. Legacy host with an old naming style + expired certificate

- **Value:** `hlx-owa01.helix-maritime.example`
- **Exact source (URL / file / metadata field):** Simulated Certificate Transparency search (CertWatch) - Expired Entry
- **Justification (1 line):** Hostname discovered attached to an expired DigiCert SSL certificate (valid until 2021-09-10), revealing a legacy internal naming convention likely tied to an old Outlook Web App (OWA) server.
- **Cross-reference / alternative ruled out:** Confirmed certificate expiration date is in the past, ensuring this is legacy infrastructure rather than a current production decoy.

### 3. Mail server IP (from passive MX + historical records)

- **Value:** `198.51.100.25`
- **Exact source (URL / file / metadata field):** Passive DNS history (DNSVault)
- **Justification (1 line):** Historical MX record (`mail.helix-maritime.example`) and its corresponding historical A record tie the legacy self-hosted mail exchanger directly to this specific IPv4 address.
- **Cross-reference / alternative ruled out:** Correlated historical A records (observed 2014-06-01 to 2024-09-30) linked to the retired MX hostname, bypassing the current cloud-managed `mx1.zephyrmail.example` provider.

### 4. A mail record that names a third-party service

- **Value:** `v=spf1 include:spf.zephyrmail.example include:spf.marlinmail.example -all`
- **Exact source (URL / file / metadata field):** Passive DNS history (DNSVault) TXT records
- **Justification (1 line):** SPF TXT record explicitly authorizes a primary mailbox provider (`zephyrmail.example`) and an additional third-party campaign mail service (`marlinmail.example`) to send emails on behalf of the domain.
- **Cross-reference / alternative ruled out:** Sourced directly from passive TXT record retrieval (observed 2024-08-10 to 2025-05-28), confirming it as an active policy and exposing supply-chain vendor relationships.

## Open questions / things to verify

- Is the legacy `198.51.100.25` mail server IP still active and reachable, potentially presenting an unpatched host vulnerability since its retirement in late 2024?
- Does the `marlinmail.example` third-party service have a history of data breaches or known misconfigurations that could be leveraged for a vendor-compromise attack?
