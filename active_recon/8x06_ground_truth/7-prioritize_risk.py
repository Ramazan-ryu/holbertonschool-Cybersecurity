# Vulnerability Assessment, Castellan Energy
For: Castellan leadership and engineering, and the Ridgeline engagement lead

**Engagement window:** Active reconnaissance and vulnerability validation against Castellan Energy's internal network estate
**Scope:** `10.40.0.0/22` and `*.castellan.example`
**Classification:** Confidential — Castellan Energy / Ridgeline internal use only

---

## 1. Executive summary

Castellan Energy asked Ridgeline to find out, in practical terms, what in the network could actually hurt the business — not just what a scanner flags. This report answers that question, and the short version is: the estate is better maintained than most, but three specific problems put revenue, grid safety, and customer trust at real risk, and none of the three would have been correctly prioritized by automated tooling alone.

### Overall risk posture

Most of Castellan's general-purpose infrastructure is in reasonable shape. Patching is happening — we found evidence of routine security updates being applied on schedule to standard servers, and the majority of scanner-reported issues on ordinary hosts turned out to be low-impact or already mitigated. That is the good news, and it matters: it means the organization has working patch discipline, which is the hardest habit to build and the easiest to lose.

The bad news is concentrated, not spread out. We found three problems that sit on or near the systems that actually run the business — the billing platform that generates revenue, and a piece of grid-facing equipment that talks to field hardware — plus a customer-facing web application with a hidden entry point that was never reviewed. A generic vulnerability scanner, working purely off severity scores, would have told Castellan to spend its first week patching low-risk legacy machines while these three problems sat untouched. We did not let that happen. This report reorders the work around what would actually damage Castellan if exploited, not around what looks alarming in a scan output.

### The most critical findings, in plain terms

**1. The billing database has a known, actively-exploited flaw.**
The database that underpins customer billing (`billing-db.castellan.example`) is running software with a publicly known vulnerability that criminal groups are already using against other organizations right now — it is on the U.S. government's Known Exploited Vulnerabilities list. A generic scan rated this "moderate," because in isolation the flaw looks unremarkable. In context, it sits on the one system whose failure stops the company from billing customers and collecting revenue. If this is exploited, Castellan is not looking at a routine incident — it is looking at a halted revenue stream, a likely regulatory disclosure obligation, and a rebuild of customer trust in billing accuracy. **This is the single highest-impact finding in the assessment.**

**2. A piece of grid equipment is broadcasting its status to anyone who asks — no login required.**
We found a device on the internal network, running on a non-standard network port, that was never documented in any asset inventory Castellan provided us. It is part of the operational technology (OT) that talks to field equipment on the grid, and it answers detailed status questions from anyone on the network without asking for a username or password. On its own, this device does not turn off power to anyone. But it hands a would-be attacker exactly the information — equipment identifiers, software build details, live telemetry — needed to plan a real disruption later. Think of it as an unlocked door to the room where the blueprints are kept, even though the machinery itself is in the next room. Left alone, it is a reconnaissance gift to anyone probing Castellan's grid infrastructure.

**3. The public website has a back door into customer and admin data that no one knew was there.**
Castellan's main website exposes an internal programming interface (API) that isn't listed in any documentation and wasn't in scope for the developers' own security reviews. Two separate problems live in that hidden interface: one lets a user manipulate the site's database directly, and the other lets an ordinary customer account view or act on data that should be restricted to administrators or to other customers. Neither of these showed up as a scanner finding at all — they only appeared when a human tested the logic of the application by hand. This is the kind of flaw that leads to customer data exposure and headlines, and it was invisible to automated tools.

### What this means for the business

If Castellan does nothing else this quarter, these three findings are the ones that determine whether the year goes well or badly. Everything else in this report — and there is a long tail of lower-priority items — is genuinely lower priority. We want leadership to walk away from this summary trusting that the order we give below is the order that reflects actual business risk, not the order a scanner would print.

### Prioritized remediation, with indicative timelines

| Priority | Action | Owner | Indicative timeline |
|---|---|---|---|
| P0 | Patch/upgrade `billing-db.castellan.example` to close the actively-exploited flaw; isolate the host on its own network segment in the interim | Database & Infrastructure | 0–48 hours |
| P0 | Firewall off the undocumented OT status service on `10.40.2.37:9000` from the general corporate LAN; require authentication on the service itself | OT / ICS Engineering | 0–48 hours |
| P1 | Fix the SQL injection and broken access control flaws in the hidden `/api/v1/` interface on `www.castellan.example` | Web Application Engineering | Within 14 days |
| P1 | Formally inventory and bring the undocumented API and the OT status service under existing change-management and asset-inventory processes | IT Governance / Asset Management | Within 14 days |
| P2 | Work through the remaining medium and low findings in the appendix register, prioritizing internet-facing hosts over internal legacy systems | Infrastructure & Web teams | Next patch cycle (30–60 days) |
| P2 | Retire or formally decommission isolated legacy hosts (e.g., `legacy-07`) that carry stale software but limited exposure | Infrastructure | Next patch cycle, or decommission roadmap |

We recommend leadership fund the P0 items immediately and treat them as an incident-adjacent response rather than routine patching — both involve systems where a failure has direct revenue or safety consequences. The P1 items should be funded as a short, focused engineering sprint. P2 items can absorb into normal operational cadence.

---

## 2. Scope and methodology

### Authorized scope

- IP range: `10.40.0.0/22` (1,024 addresses, Castellan's internal network estate)
- Domain root: `castellan.example`, and all discovered subdomains resolving within that root
- Both live-network reconnaissance and analysis of vulnerability-scanner reports Castellan provided as a starting baseline

### Explicit exclusions

- Any host or IP address outside `10.40.0.0/22`, including any cloud-hosted or third-party-managed infrastructure not physically or logically within this range
- Any domain not resolving under `castellan.example`
- Physical security testing, social engineering, and phishing simulations were out of scope for this engagement
- No wireless assessment was performed

### Assumptions

- The IP range and DNS zone provided by Castellan were current and complete as of the start of the engagement
- Vulnerability scan exports provided by Castellan reflect scans run within the prior 30 days and were treated as a baseline to validate, not as ground truth
- Systems observed to be unreachable during the assessment window (e.g., powered off, air-gapped, or maintenance-windowed) are noted as "not assessed" rather than assumed secure

### Rules of engagement

This was an **assess, do not exploit** engagement. That boundary shaped every technique used:

- No aggressive or high-volume port scanning (e.g., full-range SYN sweeps at default Nmap timing) was run against the estate. Castellan flagged that a subset of OT/ICS controllers are known to be fragile under scan load, so all live scanning used conservative timing, targeted port lists built from prior reconnaissance, and was run in coordination with Castellan's OT engineering point of contact.
- Vulnerabilities were confirmed using benign, boolean, or non-destructive proof-of-concept payloads only — for example, a SQL injection was confirmed by observing a true/false conditional response difference, not by extracting data.
- No credentials were harvested, brute-forced, or dumped. Where authentication weaknesses are discussed, they were identified structurally (e.g., absence of an auth check) rather than by attempting logins.
- No data was exfiltrated, no records were modified, and no OT/grid state was altered at any point.
- Findings involving the OT status service on `10.40.2.37:9000` were limited to passive/benign query-response observation; no command or control-plane interaction was attempted against grid-facing equipment.

### Methodology and phase sequence

1. **Baseline review** — ingested Castellan's provided vulnerability scan exports (host inventory, CVE lists, CVSS base scores) as a starting point, not a conclusion.
2. **Passive and low-impact active reconnaissance** — DNS enumeration and zone-adjacent subdomain discovery against `castellan.example`; targeted, low-rate TCP connection probes against the `10.40.0.0/22` range informed by DNS and scan-export results, rather than a blind full-range sweep.
3. **Service identification and banner analysis** — for each responsive host/port, service and version fingerprinting via protocol-appropriate handshakes (HTTP requests, TLS handshake inspection, banner grabs), used to independently confirm or dispute the scanner's software-version claims.
4. **Manual application review** — the public web application (`www.castellan.example`) was walked by hand (not spidered blindly) to identify endpoints, including undocumented ones, that automated crawlers had not reached because they were not linked from any discoverable page.
5. **Vulnerability validation** — every scanner-reported finding above informational severity was independently retested with a benign proof-of-concept; findings that could not be reproduced were downgraded to "unconfirmed" or "false positive" per the criteria in Section 6.
6. **Threat and business context enrichment** — confirmed findings were cross-referenced against CISA's Known Exploited Vulnerabilities (KEV) catalog and public EPSS exploitation-probability scores, and each affected asset was mapped against Castellan's asset-criticality notes (crown-jewel vs. peripheral) provided at kickoff.
7. **Reporting and reprioritization** — findings were reordered from scanner-severity order into business-risk order, producing the risk story in Section 5.

All timestamps, request/response captures, and command transcripts referenced in Section 3 and the Appendix are retained in the engagement evidence log and available to Castellan's engineering team on request, for reproducibility.

---

## 3. Findings by severity

Each finding below lists the affected asset, our verified verdict, severity in context (CVSS base score plus an environmental note explaining why the contextual risk may differ from the base score), applicable threat context (KEV/EPSS where relevant), and a reproducible proof.

### 3.1 Critical

#### V-0031 — Known-exploited vulnerability on core billing database
- **Asset:** `billing-db.castellan.example` (10.40.0.14)
- **Verdict:** Confirmed
- **CVSS base:** 7.5 (High, per NVD) — **Environmental severity: Critical.** The base score reflects generic exposure; environmentally, this host processes all customer billing transactions and has no live redundant failover, so successful exploitation has a direct, unmitigated revenue and regulatory impact.
- **Threat context:** Listed on CISA's Known Exploited Vulnerabilities (KEV) catalog; EPSS exploitation probability in the top decile at time of assessment, indicating active, ongoing exploitation attempts across the internet at large, not merely theoretical risk.
- **Proof (behavioral, non-destructive):** A crafted request against the exposed database management interface returned a version-disclosure banner matching the vulnerable build; a benign conditional probe (true/false timing differential) consistent with the published proof-of-concept confirmed the flaw was live and unpatched, without any data being read or altered. Full request/response capture: `evidence/V-0031_probe.log`.

#### DISCOVERED-001 — Broken access control in undocumented API
- **Asset:** `www.castellan.example` — hidden interface `/api/v1/*`
- **Verdict:** Confirmed
- **CVSS base:** 6.5 (Medium, generic OWASP scoring for broken object-level authorization) — **Environmental severity: Critical.** This endpoint was not in any documentation, was not covered by the application's existing auth-review process, and grants cross-principal access to account records; the business impact of undetected customer-data exposure outweighs the generic base score.
- **Threat context:** Not present in KEV (this is an application-logic flaw specific to Castellan's codebase, not a published CVE); EPSS not applicable. Threat context here is qualitative: broken access control is consistently among the most exploited web application flaw classes industry-wide (OWASP Top 10, A01).
- **Proof:** Requesting `GET /api/v1/accounts/{id}/invoices` while authenticated as a low-privilege test account, and substituting a different customer's numeric account ID, returned that other account's invoice records with HTTP 200 rather than an expected 403. Captured request/response pair with account identifiers redacted: `evidence/DISCOVERED-001_response.log`.

### 3.2 High

#### V-0007 — SQL injection in undocumented API
- **Asset:** `www.castellan.example` — `/api/v1/search`
- **Verdict:** Confirmed
- **CVSS base:** 8.6 (High) — **Environmental note:** consistent with base; no compensating control (WAF rule, parameterization) was observed on this specific endpoint, so contextual severity matches the base score.
- **Threat context:** Not KEV-listed (application-specific, unpublished CVE); qualitative risk is high given the endpoint sits on a customer-facing, internet-reachable interface.
- **Proof:** A single-quote character submitted in the `query` parameter produced a database driver error disclosing the underlying DBMS type and version in the response body; a subsequent boolean pair (`' AND 1=1--` vs `' AND 1=2--`) produced differential response lengths confirming injectable, unsanitized input, without any row-level data extraction attempted. Capture: `evidence/V-0007_boolean_diff.log`.

#### DISCOVERED-002 — Unauthenticated OT status service
- **Asset:** `10.40.2.37:9000` (undocumented, non-standard port; not present in Castellan's asset inventory at kickoff)
- **Verdict:** Confirmed
- **CVSS base:** 5.3 (Medium, generic "unauthenticated information disclosure" scoring) — **Environmental severity: High.** The disclosed information includes RTU (remote terminal unit) console telemetry and firmware/build identifiers for grid-facing field equipment; in an OT context, reconnaissance-enabling disclosure is treated as materially higher risk than an equivalent disclosure on a general IT asset, because it shortens the path to a targeted grid-availability attack.
- **Threat context:** No public CVE (bespoke internal service); qualitative OT threat context per NERC-CIP-aligned risk guidance treats unauthenticated telemetry exposure on grid-adjacent systems as a priority finding regardless of formal CVSS score.
- **Proof:** A single benign status query (`GET /status` equivalent, sent over the service's plaintext protocol) returned a structured response including RTU identifiers, firmware build string, and last-poll telemetry, with no authentication challenge issued at any point in the exchange. Capture: `evidence/DISCOVERED-002_status_response.log`. No control-plane or write operation was attempted, per the rules of engagement.

### 3.3 Medium

#### V-0012 — Outdated TLS configuration on customer portal
- **Asset:** `portal.castellan.example` (10.40.0.22)
- **Verdict:** Confirmed
- **CVSS base:** 5.9 (Medium) — Environmental note: consistent with base; the portal supports TLS 1.0/1.1 alongside modern TLS for backward compatibility, which is a real but narrow exposure window given modern browsers already refuse the legacy versions by default.
- **Threat context:** Not KEV-listed; long-standing, low-EPSS configuration weakness rather than an active exploitation trend.
- **Proof:** TLS handshake enumeration confirmed the server accepts a TLS 1.0 ClientHello and completes a full handshake using a weak cipher suite. Capture: `evidence/V-0012_tls_handshake.log`.

#### V-0018 — Verbose error handling on internal file server
- **Asset:** `files-internal.castellan.example` (10.40.1.9)
- **Verdict:** Confirmed
- **CVSS base:** 4.3 (Medium) — Environmental note: internal-only asset, not internet-reachable, which meaningfully reduces exploitation likelihood relative to the base score's generic assumptions.
- **Threat context:** Not KEV-listed; low EPSS.
- **Proof:** Requesting a nonexistent internal path returned a full stack trace including internal file-system paths and the application framework's exact version string. Capture: `evidence/V-0018_stacktrace.log`.

### 3.4 Low / Informational

#### V-0044 — End-of-support OS on isolated legacy host
- **Asset:** `legacy-07.castellan.example` (10.40.3.201)
- **Verdict:** Confirmed, but contextually low priority
- **CVSS base:** 7.8 (High, generic "unsupported OS" scoring) — **Environmental severity: Low.** This is the clearest example in the assessment of scanner severity overstating real risk: the host is network-isolated on a dedicated VLAN with no route to the internet or to crown-jewel systems, serves no active business function beyond archival read access by two named engineers, and is scheduled for decommissioning. High base score, negligible business exposure.
- **Threat context:** Numerous public CVEs exist for the unsupported OS version; however, EPSS-style exploitation-probability reasoning is largely moot given the host's network isolation removes practical exploit delivery paths.
- **Proof:** Banner grab confirmed the end-of-support OS version and build date. Capture: `evidence/V-0044_banner.log`.

Full per-finding detail — including the remaining minor and informational items not individually narrated above — is indexed in the Appendix risk register (Section 8) with links to their evidence records.

---

## 4. Remediation plan

Remediation is matched to what actually caused each flaw — a stale patch, a missing config, a missing architecture boundary, or a missing authorization check — rather than one generic instruction.

### V-0031 — Billing database KEV vulnerability
- **Type of fix:** Patch + short-term architecture control
- **Immediate:** Apply the vendor-issued patch that closes the actively-exploited flaw; this is available and compatible with Castellan's current database version per vendor release notes.
- **Bridging control (until patch is validated in a maintenance window):** Place `billing-db.castellan.example` behind a dedicated network segment/ACL that restricts inbound connections to only the specific application servers that require database access, closing off lateral-movement paths from the general corporate LAN in the interim.
- **Castellan-specific constraint addressed:** Billing cannot tolerate unplanned downtime during business hours; we recommend the patch be applied in the existing weekend maintenance window already used for billing-system changes, with the network-segmentation bridging control live before that window.

### DISCOVERED-001 — Broken access control in `/api/v1/`
- **Type of fix:** Access control / application logic
- **Fix:** Implement server-side authorization checks on every `/api/v1/*` endpoint that verify the requesting principal owns or is entitled to the requested resource ID, rather than relying on the client to only request its own data. This should use the same authorization middleware already in place on the documented, non-hidden portion of the API — the gap here is that this endpoint set was never wired into that existing middleware, not that the middleware itself is missing.
- **Castellan-specific constraint addressed:** Because this is a logic gap rather than a missing library, no new dependency or architecture change is required — engineering can apply the existing authorization decorator to the affected routes.

### V-0007 — SQL injection in `/api/v1/search`
- **Type of fix:** Configuration / secure coding
- **Fix:** Replace the current string-concatenated query construction with parameterized queries (prepared statements) using the existing database driver's native parameter binding. As a compensating control while the code fix is validated, apply a WAF rule specifically for this endpoint's `query` parameter.
- **Castellan-specific constraint addressed:** This endpoint shares a query-construction helper function with several other, documented endpoints; we recommend auditing that shared helper function rather than patching this one call site in isolation, since the same pattern likely recurs elsewhere in the codebase.

### DISCOVERED-002 — Unauthenticated OT status service
- **Type of fix:** Network segmentation + service-level authentication
- **Immediate:** Firewall the service off from the general corporate LAN, restricting access to only the specific OT management workstations that legitimately need it. This does not require touching the field-facing side of the device at all, respecting the fragility constraint Castellan flagged for OT systems.
- **Follow-up:** Because this service was undocumented, we recommend Castellan's OT engineering team assess whether the underlying platform supports adding authentication natively (many RTU management interfaces do, via a config flag) before the next scheduled maintenance window, rather than leaving segmentation as the sole control long-term.
- **Castellan-specific constraint addressed:** No firmware change, restart, or control-plane interaction is required for the immediate segmentation fix, keeping the fragile OT asset untouched per the assess-do-not-exploit mandate that also governed our own testing.

### V-0012 — Legacy TLS on customer portal
- **Type of fix:** Configuration
- **Fix:** Disable TLS 1.0/1.1 and the associated weak cipher suites in the web server's TLS configuration, retaining only TLS 1.2+ with modern cipher suites. Given that modern browsers already refuse the legacy protocol versions, this change is expected to have negligible impact on real customer traffic; we recommend a one-week monitoring window on portal error rates post-change to confirm.

### V-0018 — Verbose error handling on internal file server
- **Type of fix:** Configuration
- **Fix:** Set the application framework to production error-handling mode, replacing stack-trace responses with generic error pages, and route detailed errors to internal logs instead of the HTTP response body.

### V-0044 — Legacy end-of-support host
- **Type of fix:** Decommissioning (not patching)
- **Fix:** Given the host's isolation and pending decommission, patching effort is not the right investment here. We recommend Castellan formalize the decommission date already discussed internally, and in the interim, confirm the two named engineers with archival access are the only accounts with credentials on the host.

Remaining medium/low findings not detailed above follow the same fix-to-cause matching and are recorded per-item in the Appendix register.

---

## 5. The risk story

If Castellan had simply worked down the automated scanner's severity list, the first week of remediation effort would have gone to `legacy-07` (scored High at 7.8) and to other peripheral hosts carrying similarly high generic CVSS scores — while the billing database's KEV-listed flaw (scored a mere Moderate/7.5 in the same neighborhood, but for very different reasons) and the completely unscored, undocumented findings sat untouched. That is the core problem with severity-only prioritization: a CVSS base score measures the technical properties of a vulnerability in a vacuum. It does not know that `legacy-07` is isolated on its own VLAN and about to be retired, and it does not know that `billing-db` is a single point of failure for all of Castellan's revenue with active real-world exploitation happening against it right now.

**Why V-0031 outranks everything, despite a "moderate" base rating.** Base CVSS scoring assumes a generic deployment. It cannot see that this specific database has no live failover, or that it is the sole system of record for revenue. Layer in KEV status — meaning this exact vulnerability class is being actively exploited across the internet, not theoretically exploitable — and a "moderate" score becomes the highest-priority item in the entire assessment. This is the clearest example in this engagement of why threat intelligence (is this being exploited right now?) has to sit alongside CVSS in any prioritization decision.

**Why DISCOVERED-002 (the OT status leak) outranks V-0012 or V-0018, despite carrying a lower or comparable numeric score.** Generic scanners scored this a Medium information-disclosure issue, the same tier as a verbose error page on an internal file server. But an information leak on grid-facing OT equipment is not the same category of risk as an information leak on an internal file server, even at the same nominal severity. The OT leak hands an attacker the specific reconnaissance data needed to plan a targeted disruption against physical grid infrastructure — a class of consequence (safety, physical service continuity, potential regulatory exposure under grid-reliability standards) that a generic CVSS environmental score does not capture unless a human analyst applies OT-specific judgment. This is why we ranked it above general IT information-disclosure findings of similar or higher numeric score.

**Why the two `/api/v1/` findings (V-0007 and DISCOVERED-001) outrank several "confirmed high" findings from the original scan.** These findings did not exist in the scanner output at all — the interface was undocumented and unlinked from any crawlable page, so no automated tool ever reached it. A scanner cannot prioritize what it never found. Both flaws were discovered only through manual, human-driven application review, which is precisely the gap automated tooling structurally cannot close: logic flaws and hidden attack surface are invisible to signature- and crawl-based scanning. We elevated both above several "confirmed" scanner findings on documented endpoints, because an entire undocumented attack surface with a live SQL injection and a live cross-account access bug represents materially more realistic business risk than yet another instance of a well-known, already-scoped vulnerability class.

**Why `legacy-07` (V-0044) drops from "High" to our lowest-priority tier.** This is the mirror image of the billing-database case: a numerically high base score paired with environmental context (network isolation, no route to sensitive systems, scheduled decommission, minimal user base) that neutralizes almost all of the practical risk. Spending immediate remediation effort here, as a severity-only list would direct, would have been a genuine misallocation of Castellan's limited engineering time this quarter.

The pattern across all four re-orderings is the same: **CVSS base score tells you how bad a flaw is in isolation; it does not tell you how bad it is for Castellan specifically.** Asset criticality (crown jewel vs. peripheral), live threat intelligence (KEV/EPSS), and whether automated tooling could even see the flaw in the first place are the three factors that moved findings up or down from where a generic scan output would have placed them. We are confident leadership can trust this reordering because every upward move is backed by an external threat-intelligence signal (KEV/EPSS) or a documented asset-criticality designation from Castellan's own kickoff materials, not by our own subjective judgment alone.

---

## 6. False positives and limitations

### Cleared false positives

- **Scanner finding "V-0021 — Outdated OpenSSH banner on `mail-relay.castellan.example`":** The scanner flagged this based on a version string in the SSH banner. On manual review, the banner reflects the vendor's backported-patch versioning scheme (a common Linux-distribution practice where the underlying package is patched but the version string is not bumped to the latest upstream release). Manual comparison against the vendor's security advisory list confirmed the specific CVE the scanner flagged had already been backported and fixed. Evidence: `evidence/V-0021_backport_confirmation.log`. Cleared — no action required.
- **Scanner finding "V-0028 — Directory listing enabled on `static.castellan.example`":** Manual review found the directory in question contains only public marketing assets (images, CSS) with no sensitive or unpublished content, and the listing does not disclose any path outside the public static-asset tree. Cleared as informational-only; not elevated to a tracked finding.
- **Scanner finding "V-0033 — Weak cipher suite on `mail.castellan.example`":** The flagged cipher suite is offered by the server but is not selected in practice because it sits at the bottom of the server's cipher preference order, behind several strong suites; a live handshake test using default client behavior always negotiated a strong suite. Downgraded from the scanner's "Medium" rating to informational.

### Unconfirmed findings

- **Scanner finding "V-0039 — Possible XML External Entity (XXE) vulnerability on `partner-api.castellan.example`":** The scanner's signature matched based on an XML content-type header on a request/response pair, but our benign XXE proof-of-concept payload did not produce the expected out-of-band callback or error differential during the assessment window. This may indicate the endpoint is not actually vulnerable, or that it is protected by a control that also suppressed our benign probe (e.g., strict XML parser configuration). **This would be settled by** a follow-up review of the server-side XML parser configuration directly with the `partner-api` engineering team, since our black-box probing could not fully rule the flaw in or out without exceeding the assess-do-not-exploit boundary.
- **Scanner finding "V-0041 — Potential default credentials on `print-mgmt.castellan.example`":** Per the rules of engagement, we did not attempt any authentication against this or any other host. The finding is recorded as unconfirmed by design, not because testing failed. **This would be settled by** Castellan's own internal team confirming, out of band, whether default vendor credentials remain active on this device.

### Scope and coverage limitations

- **OT/ICS depth:** Per the fragility constraint on Castellan's OT estate, we deliberately limited interaction with OT-adjacent systems to passive/benign observation. This means our OT coverage should be read as "what is visible without touching the systems," not a full OT security assessment. A dedicated ICS-focused assessment, run with OT engineering directly in the loop and with an agreed maintenance window for more invasive testing, would likely surface additional findings beyond DISCOVERED-002.
- **Time-boxed reconnaissance:** The engagement window did not allow for exhaustive subdomain enumeration beyond DNS-based and passively observed discovery methods; it is possible additional subdomains or shadow IT assets exist under `castellan.example` that were not discovered during this assessment.
- **No authenticated application testing:** All web application testing was performed from an unauthenticated or low-privilege test-account perspective consistent with the rules of engagement; deeper authenticated-role testing (e.g., privilege escalation paths between mid-tier employee roles) was out of scope and may surface additional findings.
- **Point-in-time assessment:** This report reflects the estate's state during the assessment window only. New assets, new code deployments, or newly disclosed CVEs after this window are not reflected here.

We want to be explicit that clearing a scanner finding or leaving another unconfirmed is not the same as certifying the surrounding system as fully secure — it means, specifically, that the tested hypothesis did not hold under the techniques permitted in this engagement.

---

## 7. Conclusion

Castellan Energy's overall security posture is uneven in a specific and fixable way: broad infrastructure hygiene is genuinely good, but three findings — the billing database's actively-exploited flaw, the undocumented and unauthenticated OT status service, and the undocumented API with SQL injection and broken access control — sit directly on or adjacent to the systems that matter most to the business, and none of the three would have been correctly prioritized by scanner output alone. That gap between generic severity scoring and actual business risk is the central finding of this engagement, more than any single vulnerability.

Our general recommendations, beyond the item-specific remediation in Section 4:

1. **Close the P0/P1 items in Section 1 first**, in the order given — they are ordered by validated business impact, not by convenience or effort.
2. **Bring undocumented assets under inventory.** Both the hidden `/api/v1/` interface and the OT status service on `10.40.2.37:9000` existed outside Castellan's own asset records. An asset that isn't inventoried can't be reviewed, patched on a schedule, or included in the next scan baseline. We recommend a lightweight, recurring discovery pass (DNS enumeration plus targeted port review) folded into routine operations, not treated as a one-time cleanup.
3. **Extend manual application review to other customer-facing systems.** The most damaging findings in this assessment (both `/api/v1/` issues) were invisible to automated scanning and only surfaced through manual, logic-driven testing. If `www.castellan.example` had one undocumented, vulnerable interface, it is reasonable to assume other Castellan-built applications may as well; we recommend budgeting for periodic manual application review, not scanner output alone, as a standing practice.
4. **Treat OT-adjacent findings with OT-specific judgment, not generic IT severity scoring**, going forward — the DISCOVERED-002 case in this report is a template for how a numerically modest finding can carry outsized real-world consequence in a grid context.
5. **Keep the patch discipline that is already working.** The clean, backported patch state we found on Castellan's general infrastructure (Section 6) is a genuine strength and the reason the false-positive rate on routine systems was as low as it was. Preserve whatever process produces that outcome as the estate grows.

Taken together, Castellan is not in crisis, but it is one unpatched database and one unauthenticated OT interface away from being in one. Both are fixable within 48 hours at low engineering cost. We recommend leadership treat the P0 items in Section 1 as the actual priority this week, independent of whatever a scan dashboard says.

---

## 8. Appendix: prioritized risk register

Findings are listed in the business-risk order used throughout this report (Section 5), not raw CVSS order. Each entry links to its evidence record for reproducibility.

| # | Finding ID | Asset | Verdict | CVSS base | Environmental severity | KEV / EPSS | Evidence |
|---|---|---|---|---|---|---|---|
| 1 | V-0031 | `billing-db.castellan.example` | Confirmed | 7.5 (High) | **Critical** | KEV-listed; top-decile EPSS | `evidence/V-0031_probe.log` |
| 2 | DISCOVERED-001 | `www.castellan.example` `/api/v1/*` | Confirmed | 6.5 (Medium) | **Critical** | Not applicable (app-logic flaw) | `evidence/DISCOVERED-001_response.log` |
| 3 | V-0007 | `www.castellan.example` `/api/v1/search` | Confirmed | 8.6 (High) | High | Not applicable (app-logic flaw) | `evidence/V-0007_boolean_diff.log` |
| 4 | DISCOVERED-002 | `10.40.2.37:9000` | Confirmed | 5.3 (Medium) | **High (OT context)** | No public CVE; qualitative OT priority | `evidence/DISCOVERED-002_status_response.log` |
| 5 | V-0012 | `portal.castellan.example` | Confirmed | 5.9 (Medium) | Medium | Not KEV; low EPSS | `evidence/V-0012_tls_handshake.log` |
| 6 | V-0018 | `files-internal.castellan.example` | Confirmed | 4.3 (Medium) | Low–Medium (internal-only) | Not KEV; low EPSS | `evidence/V-0018_stacktrace.log` |
| 7 | V-0044 | `legacy-07.castellan.example` | Confirmed | 7.8 (High) | **Low (isolated, decommission-scheduled)** | CVEs exist; exploitability moot (isolated) | `evidence/V-0044_banner.log` |
| — | V-0021 | `mail-relay.castellan.example` | **Cleared — false positive** (backported patch) | 6.1 (Medium, as scanned) | N/A | N/A | `evidence/V-0021_backport_confirmation.log` |
| — | V-0028 | `static.castellan.example` | **Cleared — informational only** | 3.1 (Low, as scanned) | N/A | N/A | Manual review notes, engagement log |
| — | V-0033 | `mail.castellan.example` | **Cleared — not exploitable in practice** | 4.8 (Medium, as scanned) | N/A | N/A | Handshake capture, engagement log |
| — | V-0039 | `partner-api.castellan.example` | **Unconfirmed** — see Section 6 | 7.1 (High, as scanned) | Pending | Pending | Engagement log; probe attempt notes |
| — | V-0041 | `print-mgmt.castellan.example` | **Unconfirmed by design** (no auth testing performed) | 9.0 (Critical, as scanned) | Pending | Pending | Engagement log |

*All evidence log files referenced above are retained in the engagement's evidence directory and are available to Castellan's engineering and security teams for independent verification and reproduction of every confirmed finding.*
