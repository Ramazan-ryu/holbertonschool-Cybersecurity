# Vulnerabilities Identified — Helix Maritime Insurance

## Vulnerability 1: Internal Infrastructure and IP Address Exposure
- Description: An inadvertently published photograph of a sprint planning whiteboard exposed critical internal infrastructure details, including the internal hostname `hlx.app.03` and a specific internal IP address `198.51.100.25` for the `hlx-mail01` server. This provides an attacker with a partial internal network map before they even breach the perimeter.
- Source findings: `8-social_notes.md` Finding 3
- Risk level: High. Rationale: Knowing exact internal IP addresses and hostnames significantly reduces the time and noise required for an attacker to perform internal reconnaissance and lateral movement once initial access is achieved.
- Exploitation potential: Technical / Internal access

## Vulnerability 2: Corporate Email Pattern and Key Personnel Identification
- Description: The corporate email pattern (`first.last@helix-maritime.example`) is completely transparent. Combined with the identification of key technical staff, including the Infrastructure & Security Lead and the Head of Technical Operations, an attacker possesses all the necessary data to craft highly targeted spear-phishing campaigns directed at high-privilege users.
- Source findings: `9-employee_notes.md` Finding 1, `9-employee_notes.md` Finding 4
- Risk level: High. Rationale: Phishing remains the dominant initial access vector. Targeting specific IT and security leads whose email formats are confirmed increases the likelihood of compromising administrative credentials.
- Exploitation potential: Social engineering

## Vulnerability 3: Software Stack and Version Disclosure
- Description: The exact name and version of the corporate content management system (Veridian CMS 5.2.1) is publicly exposed in the HTML source code, while the legacy CRM system (Nimbus 9.4) was exposed via a social media photo. This allows attackers to query vulnerability databases (CVEs) and build bespoke exploits without actively scanning the target.
- Source findings: `10-stack_notes.md` Finding 1, `8-social_notes.md` Finding 3
- Risk level: Medium. Rationale: While exposing the version does not immediately guarantee a breach, it drastically accelerates an attacker's weaponization phase if a zero-day or known vulnerability exists for these specific versions.
- Exploitation potential: Technical

## Vulnerability 4: Migration Period Targeting (IT Impersonation)
- Description: Helix is undergoing two major internal migrations simultaneously: an email migration to ZephyrMail Business and a CRM migration to Salesforce. Both were publicly exposed via job postings and social media. Attackers can leverage this context to spoof IT support, asking employees to "verify credentials for the new ZephyrMail/Salesforce rollout."
- Source findings: `7-jobs_notes.md` Finding 1, `8-social_notes.md` Finding 3, `10-stack_notes.md` Finding 2
- Risk level: High. Rationale: During major IT migrations, employee guard is lowered regarding credential resets and IT requests. Contextually accurate phishing during this window has a very high success rate.
- Exploitation potential: Social engineering

## Vulnerability 5: Physical Security and Routine Tracking
- Description: The Head of Technical Operations uses a public GPS-tagged fitness tracking platform where his regular running routes begin and end precisely at the registered Helix corporate headquarters (Wilhelminakade 909). This exposes his physical routines and presence at the office.
- Source findings: `9-employee_notes.md` Finding 4, `6-registry_notes.md` Finding 1
- Risk level: Low to Medium. Rationale: While difficult to exploit remotely, it provides a physical red team or malicious actor with the exact schedule and location of a key IT executive, facilitating tailgating, physical hardware insertion, or in-person social engineering.
- Exploitation potential: Social engineering / Internal access

## Vulnerability 6: Public Exposure of Internal Developer Activity
- Description: A Helix backend developer maintains a publicly cached repository (`tidewater-engine`) that explicitly references the company's internal framework. The commit history exposes internal development cadences, email addresses, and specific technologies (Kotlin, TypeScript).
- Source findings: `9-employee_notes.md` Finding 2, `7-jobs_notes.md` Finding 2
- Risk level: Medium. Rationale: Code repositories are prime targets for supply chain attacks. If the developer uses the same credentials or lacks 2FA, compromising this public account could lead to unauthorized code injection or further exposure of proprietary logic.
- Exploitation potential: Supply chain / Technical
