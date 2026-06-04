# HEALTHBANE Kill Chain Reconstruction

## Overview

This report reconstructs the HEALTHBANE campaign using intelligence from:

*   HC3 Advisory
*   MedDefense internal findings
*   Independent researcher analysis
*   Commercial intelligence feed

The campaign targeted healthcare organizations through a multi-stage intrusion chain involving credential harvesting, malware delivery and DNS-based exfiltration.

---

# 1. Campaign Timeline

| Date / Window | Activity | Evidence Source | Confidence |
|---|---|---|---|
| 2026-04-05 | Earliest suspicious domain registrations observed | Commercial Feed | MEDIUM |
| 2026-04-10 | Phishing infrastructure became operational | Researcher / HC3 | HIGH |
| 2026-04-14 | MedDefense phishing emails received | MedDefense | HIGH |
| 2026-04-14 → 2026-04-18 | Credential harvesting activity across healthcare sector | HC3 / Blog / MedDefense | HIGH |
| 2026-04-16 | Stage 2 malware delivery window activated | HC3 / Feed | HIGH |
| 2026-04-18 | PowerShell exfiltration tooling identified | HC3 / Blog | HIGH |
| 2026-04-20 → 2026-04-24 | Stage 3 exfiltration window via DNS tunneling | HC3 | HIGH |
| 2026-04-26 | Most recent reported event / infrastructure activity | HC3 / Commercial Feed | HIGH |

---

# 2. Attack Phase Reconstruction

## Stage 1 — Credential Harvesting

### Phishing Operation
The phishing operation began with malicious emails impersonating healthcare suppliers, HR portals, and Microsoft security notifications. Attackers utilized templates mimicking internal business infrastructure to trick users into providing access credentials.

### Targeting Pattern
The targeting pattern specifically focused on:
*   Hospital HR staff
*   Clinical administrators
*   Finance departments
*   Procurement teams
*   Healthcare IT personnel

HC3 reporting indicates multiple healthcare organizations were targeted during the campaign window.

### Infrastructure Used
**Domains:**
*   meddefense-portal.com
*   medequip-supplies.net
*   meddefense-benefits.org
*   outlook-protection.com

**Hosting Infrastructure:**
| IP | Role |
|---|---|
| 91.234.99.107 | Phishing portal hosting |
| 185.176.43.22 | Invoice phishing infrastructure |
| 164.90.218.73 | HR-themed phishing |
| 51.38.42.17 | Microsoft impersonation portal |

**Operational Characteristics:**
*   PHPMailer 6.6.0 usage
*   Let's Encrypt certificates
*   Healthcare-themed domain naming
*   Credential harvesting forms
*   SPF/DKIM configured to improve delivery success

### Known Victims
*   **Confirmed:** MedDefense employees and additional unnamed healthcare organizations referenced by HC3.
*   **Possible:** Additional sector victims inferred from shared infrastructure reuse.

### MedDefense Evidence
MedDefense identified multiple phishing emails, credential harvesting redirects, domain impersonation, repeated sender infrastructure, and shared phishing templates. Internal findings strongly corroborate HC3 reporting.

### Success Rate
The success rate across reported victims is not available and was not published. However, HC3 confirmed credential theft occurred, Stage 2 activity confirms at least partial operational success, and follow-up malware delivery indicates attackers obtained valid access or trust. The estimated overall success rate remains unknown.

---

## Stage 2 — Malware Delivery

### Transition from Stolen Credentials to Follow-Up Emails
After credential harvesting, attackers transitioned from stolen credentials to follow-up emails. The transition mechanism suggests operators used harvested credentials to hijack trusted email delivery threads or impersonate authorized personnel to send follow-up communications containing malicious links or attachments.

### Document Type
Observed document type and formats included DOCM macro-enabled Office files, fake invoice attachments, and security update themed documents.

### Malware or Script Artifacts
The payload and script artifacts identified include:
| Hash Purpose | Description |
|---|---|
| Macro document | Initial execution vector |
| svchost_update.exe | Trojan payload |
| sync_healthdata.ps1 | Exfiltration script loader |

### Download Infrastructure
**Domains & URLs:**
*   healthbane-c2.net
*   update-healthbane.net
*   `https://healthbane-c2.net/update/svchost_update.exe`

**Infrastructure Nodes:**
| IP | Role |
|---|---|
| 45.77.218.9 | Malware hosting |
| 51.38.42.191 | C2 infrastructure |

### Persistence Mechanisms
Reported persistence mechanisms included scheduled tasks, Registry Run keys, PowerShell startup execution, and beacon retry logic.

### Evidence Source
*   **HC3:** Malware workflow details.
*   **Researcher Blog:** Technical tooling and script detail.
*   **Commercial Feed:** Additional domain and file indicators.
*   **MedDefense:** Initial phishing templates and local delivery logs.

---

## Stage 3 — Data Exfiltration

### Data Targeted
HC3 references indicate data targeted included healthcare operational documents, internal records, credential data, and possibly patient-related administrative information. No confirmed PHI exposure details were publicly released.

### Protocol or Tool Used
*   **Technique:** DNS TXT Tunneling
*   **Characteristics:** Base32-encoded subdomains, beacon intervals every 10–15 seconds, PowerShell-based automation (`sync_healthdata.ps1`), and TXT-response communication loop.

### Exfiltration Infrastructure
*   **Domains:** data-sync.healthbane-c2.net
*   **Node:** 51.38.42.191 (OVH-hosted exfiltration node)

### Evidence Source
*   **HC3:** HIGH confidence network intelligence.
*   **Researcher Blog:** MEDIUM-HIGH confidence script breakdown.
*   **Commercial Feed:** MEDIUM confidence passive DNS infrastructure metadata.

### Confirmed and Unclear
*   **Confirmed:** DNS tunneling occurred, PowerShell tooling existed, C2 infrastructure was operational, and TXT-based communication was explicitly observed.
*   **Unclear:** Exact volume of stolen data, final attacker objectives, full victim count, whether ransomware deployment occurred later, and long-term persistence duration after exfiltration.

---

# 3. Evidence Quality Assessment

## Stage 1 — Credential Harvesting
*   **Confirmed Evidence:** Phishing domains, active harvesting pages, received MedDefense phishing emails, and shared phishing infrastructure.
*   **Corroborated Evidence:** PHPMailer footprint usage, shared hosting infrastructure blocks, and regional healthcare targeting patterns.
*   **Inferred Evidence:** A significantly larger victim set across the sector beyond known public reporting.
*   **Unknowns:** Exact overall compromise rate and the comprehensive phishing distribution list.

## Stage 2 — Malware Delivery
*   **Confirmed Evidence:** Active malware delivery URLs, Trojan payload binary hashes, PowerShell script artifacts, and dedicated C2 nodes.
*   **Corroborated Evidence:** Implemented persistence techniques and multi-stage intermediate infection workflows.
*   **Inferred Evidence:** Threat actors directly utilized harvested credentials for trusted email delivery threads.
*   **Unknowns:** Complete hidden plugin capabilities of the malware and lateral movement actions.

## Stage 3 — Data Exfiltration
*   **Confirmed Evidence:** DNS tunneling traffic, TXT beaconing, active exfiltration domains, and exfiltration PowerShell script tooling.
*   **Corroborated Evidence:** OVH-hosted infrastructure clusters and shared operational infrastructure trends.
*   **Inferred Evidence:** High probability of successful structural healthcare data theft.
*   **Unknowns:** Exact stolen datasets, final landing destination systems, and long-term background access windows.

---

# 4. Intelligence Gaps and Unknowns

## Attribution Gaps
Different sources use disparate naming conventions for this threat cluster:
*   **HC3:** HEALTHBANE
*   **Commercial Feed:** VITALSCORE
*   **Researcher:** APT-MEDAGENT
*   **MedDefense:** No internal attribution assigned

No source provides definitive attribution evidence linking these strings to a known national actor or specific cybercriminal syndicate. Attribution confidence remains LOW-MEDIUM.

## Missing Victim Telemetry
Crucial missing victim telemetry context includes:
*   Internal endpoint logs from affected third-party environments
*   Local EDR telemetry captures from other sector victims
*   Untruncated, full email transmission headers from initial compromises
*   Host-level lateral movement artifacts inside sister networks
*   Centralized authentication logs for bypassed systems

The absence of this comprehensive victim telemetry limits total mapping accuracy across the sector.

## Incomplete Stage 3 Visibility
Current reporting does not confirm or quantify Stage 3 visibility specifics:
*   Total exfiltrated data volume
*   Exact nature of the contents compromised (e.g., specific patient counts or IP types)
*   Secondary downstream monetization loops or dark web dumping locations
*   In-network persistence duration following data egress

## Commercial-Feed Uncertainty
The commercial feed includes elements that introduce analytical noise and commercial-feed uncertainty:
*   Weakly clustered infrastructural indicators
*   Highly volatile shared cloud IP blocks (such as AWS/DigitalOcean dynamic allocations)
*   Historical tenancy overlaps unrelated to current campaigns
*   Automated ML-similarity indicators without manual verification

Several of these commercial feed indicators remain uncorroborated and should not be operationalized without additional verification.

## Recommended Additional Collection
The implementation of an enhanced collection plan would significantly eliminate existing gaps:
*   Continuous passive DNS (pDNS) history auditing
*   Endpoint forensic imaging of impacted servers
*   Full EDR telemetry export setups
*   External NetFlow record collections across critical segments
*   Upstream email gateway log integrations
*   Deep malware sandbox dynamic execution captures
*   Internal DNS resolver logs parsing
*   Cross-sector victim reporting sharing channels (such as ISAC networks)
