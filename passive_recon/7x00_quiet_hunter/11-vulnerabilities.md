# Vulnerabilities Identified — Helix Maritime Insurance

## Vulnerability 1: CMS Version Exposure
- Description: The exact version of the corporate content management system is exposed as Veridian CMS 5.2.1. This single detail allows attackers to query known vulnerability databases for specific exploits.
- Source findings: `10-stack_notes.md` Finding 1
- Risk level: Medium. Rationale: Exposing the exact CMS version accelerates the weaponization phase if a known vulnerability exists, bypassing the need for active scanning.
- Exploitation potential: Technical

## Vulnerability 2: Exposed Internal IP Address
- Description: A photograph of a sprint planning whiteboard inadvertently exposed the specific internal IP address 198.51.100.25 for the hlx-mail01 server, providing a direct map of internal network topology.
- Source findings: `8-social_notes.md` Finding 3
- Risk level: High. Rationale: Internal IP knowledge allows an attacker to immediately target specific internal assets once perimeter defenses are bypassed.
- Exploitation potential: Technical

## Vulnerability 3: Corporate Email Pattern Disclosure
- Description: The corporate email format for the Infrastructure & Security Lead is completely transparent (joris.bakker@helix-maritime.example), providing exact targeting information for spear-phishing.
- Source findings: `9-employee_notes.md` Finding 1
- Risk level: High. Rationale: Validated email patterns for high-privilege IT users provide the exact targeting information needed for successful spear-phishing campaigns.
- Exploitation potential: Social engineering

## Vulnerability 4: Inadvertent Phone Number Exposure
- Description: A direct phone number for the communications manager was left exposed within a public sponsorship prospectus, bypassing corporate reception for direct vishing attacks.
- Source findings: `9-employee_notes.md` Finding 3
- Risk level: Medium. Rationale: Direct phone lines bypass general security screening, allowing attackers to conduct highly convincing voice phishing (vishing) attacks.
- Exploitation potential: Social engineering

## Vulnerability 5: Public Developer Repository Exposure
- Description: A public repository associated with a Helix developer explicitly references the internal Tidewater Risk Engine framework, exposing the proprietary technological footprint.
- Source findings: `9-employee_notes.md` Finding 2
- Risk level: High. Rationale: Public developer accounts linked to internal frameworks are prime targets for supply chain attacks and code compromise.
- Exploitation potential: Supply chain
