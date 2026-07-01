# OSINT Intelligence Report — Helix Maritime Insurance

Prepared by: Junior OSINT Analyst, Vanguard Security
For: Marcus Bauer, Lead Red Teamer, Vanguard Security
Classification: Internal — Vanguard Red Team Only

## 1. Executive summary
Helix Maritime Insurance presents a defined attack surface. Intelligence gathered strictly through passive open-source intelligence (OSINT) reveals specific exposures in document metadata, social media, public developer repositories, and physical fitness tracking. This intelligence enables the red team to plan targeted spear-phishing, vishing, physical infiltration, and codebase reconnaissance. Three primary vectors are prioritized for red team consumption based directly on validated findings without any active exploitation.

## 2. Synthesized corporate profile

### 2.1 Organizational structure
To ensure decoy resistance, key identities were triangulated across multiple independent sources:
- **Joris Bakker**: Infrastructure & Security Lead. (Identity cross-referenced between Lattice profile and corporate `humans.txt` to rule out homonyms).
- **Sander de Boer**: Head of Technical Operations. (Profile authenticity validated by matching GPS tracking endpoints to the registered corporate headquarters).
- **Marleen Koster**: Community & Communications Manager. (Identity confirmed via social media and document metadata).
- **Daan de Vries**: Backend Developer. (Alias `dvries` triangulated with `humans.txt` and GitHub commit email `daan.devries@helix-maritime.example` to exclude lookalikes).

### 2.2 Technical surface
The technology stack has been definitively mapped and cross-verified:
- **Content Management System**: Veridian CMS 5.2.1. (Synthesized via HTML tags and Web Archive paths).
- **Email Provider**: ZephyrMail Business. (Corroborated by DNS MX records and PDF metadata).
- **Internal Framework**: Tidewater Risk Engine.
- **Internal Network Artifacts**: The internal hostname `hlx-mail01` is confirmed. *Decoy Note*: An IP address `198.51.100.25` was exposed, but OSINT confirms this falls within the RFC 5737 TEST-NET-2 documentation range and is treated strictly as a decoy placeholder.

### 2.3 Social footprint
Employees frequently post about internal operations (CRM/Email migrations, Rotterdam Maritime Week 2025). Employees also use public fitness tracking platforms that explicitly trace routes back to the legally registered corporate headquarters, exposing physical operational routines.

## 3. Vulnerabilities identified

- **Vulnerability 1: CMS Version Exposure**: The exact version of the corporate CMS is exposed as Veridian CMS 5.2.1. Risk level: Medium. Rationale: Accelerates the weaponization phase if known vulnerabilities exist.
- **Vulnerability 2: Exposed Internal Infrastructure**: A sprint whiteboard exposed the internal hostname `hlx-mail01`. Risk level: Low to Medium. Rationale: Aids internal mapping post-breach (excluding the decoy IP).
- **Vulnerability 3: Corporate Email Pattern Disclosure**: The email format for the Infrastructure & Security Lead (`joris.bakker@helix-maritime.example`) is confirmed. Risk level: High. Rationale: Provides exact targeting information for spear-phishing.
- **Vulnerability 4: Inadvertent Phone Number Exposure**: A direct phone number (`+31 10 555 0199`) for Marleen Koster was exposed. Risk level: Medium. Rationale: Bypasses general security screening for vishing.
- **Vulnerability 5: Public Developer Repository Exposure**: A verified repository references the internal Tidewater Risk Engine. Risk level: High. Rationale: Exposes internal codebase dependencies.

## 4. Attack vectors recommended

- **Vector 1: Targeted Spear-Phishing against IT Leadership**: The attacker drafts a targeted phishing email to Joris Bakker (`joris.bakker@helix-maritime.example`), mimicking the confirmed email provider (ZephyrMail Business). Probable operational impact: Enables the delivery of a malicious payload directly to an administrative endpoint.
- **Vector 2: Codebase Reconnaissance via Exposed Repository**: The attacker reviews the public commit history of the `tidewater-engine` repository belonging to Daan de Vries (`dvries`). Probable operational impact: Maps internal code logic and identifies software dependencies without active scanning.
- **Vector 3: Vishing Campaign against Corporate Communications**: The attacker initiates a voice phishing call to Marleen Koster's direct line (`+31 10 555 0199`), using the Rotterdam Maritime Week 2025 event as a pretext. Probable operational impact: Bypasses technical filters to establish direct communication and solicit internal event logistics.
- **Vector 4: Physical Headquarters Interception Planning**: The attacker plans physical interception by tracking Sander de Boer's GPS fitness data, mapping his routine at the Wilhelminakade 909 facility. Probable operational impact: Identifies a predictable window for physical intrusion planning.

## 5. Targeting recommendations
- **Prioritized persona**: Joris Bakker, Infrastructure & Security Lead.
- **Prioritized vector**: Vector 1 (Targeted Spear-Phishing). The email migration to ZephyrMail Business provides a contextually accurate pretext.
- **Indicators of red-team readiness**: Targeting data has been rigorously cross-referenced. Decoys have been filtered out. The red team can begin operational planning without further active OSINT gathering.

## Appendix : Source documentation

- **Task 1, Finding 3 & Task 3, Finding 1**: ZephyrMail Business. 
  - Notes files: `1-dns_notes.md`, `3-pdf_metadata_notes.md`
  - Source URLs: `http://[PROVIDED_IP]/dns-intelligence`, `http://[PROVIDED_IP]/documents/marine-risk-outlook-2025.pdf`
  - Corroboration: DNS MX records triangulated with ExifTool metadata.
- **Task 2, Finding 3 & Task 4, Finding 1**: Veridian CMS 5.2.1. 
  - Notes files: `2-source_code_notes.md`, `4-web_archive_notes.md`
  - Source URLs: `http://[PROVIDED_IP]/`, `http://[PROVIDED_IP]/archive`
  - Source date: Snapshot 2023-05-09
  - Corroboration: HTML tags cross-referenced with archive snapshots.
- **Task 6, Finding 1**: Wilhelminakade 909 address. 
  - Notes file: `6-registry_notes.md`
  - Source URL: `http://[PROVIDED_IP]/company/about`
- **Task 8, Finding 2 & 3**: Maritime Week and `hlx-mail01`. 
  - Notes file: `8-social_notes.md`
  - Source URL: `http://[PROVIDED_IP]/social`
- **Task 9, Finding 1**: Joris Bakker email. 
  - Notes file: `9-employee_notes.md`
  - Source URL: `http://[PROVIDED_IP]/social/employees/joris-bakker`
  - Corroboration: Profile matched with `humans.txt` to exclude homonyms.
- **Task 9, Finding 2**: Daan de Vries repository. 
  - Notes file: `9-employee_notes.md`
  - Source URL: `http://[PROVIDED_IP]/developer/dvries`
  - Corroboration: Triangulated with commit metadata.
- **Task 9, Finding 3**: Marleen Koster phone (+31 10 555 0199). 
  - Notes file: `9-employee_notes.md`
  - Source URL: `http://[PROVIDED_IP]/documents/marine-summit-sponsorship.pdf`
- **Task 9, Finding 4**: Sander de Boer GPS. 
  - Notes file: `9-employee_notes.md`
  - Source URL: `http://[PROVIDED_IP]/social/employees/activity/sander-de-boer`
