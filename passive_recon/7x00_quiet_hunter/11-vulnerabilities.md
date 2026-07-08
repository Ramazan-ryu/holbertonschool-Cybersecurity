# Vulnerabilities Identified — Helix Maritime Insurance

## Vulnerability 1: Internal Network Infrastructure Exposure
- Description: The inadvertent exposure of internal naming conventions on a corporate whiteboard, specifically the internal hostname `hlx-mail01` and IP `198.51.100.25`, provides attackers with internal network mapping details that can be used to plan lateral movement and internal discovery (supported by `8-social_notes.md` Finding 3).
- Source findings: `8-social_notes.md` Finding 3
- Risk level: Low to Medium. Rationale: While direct external network exploitation is mitigated if the IP is non-routable, the exposure of internal naming conventions aids attackers in mapping the internal environment post-breach.
- Exploitation potential: Technical

## Vulnerability 2: Executive Spear-Phishing via Email Pattern Exposure
- Description: The exposure of a predictable corporate email pattern, combined with the verified identity and role of the Infrastructure & Security Lead (Joris Bakker), allows attackers to craft highly targeted spear-phishing campaigns directed at a high-privilege administrative user (supported by `9-employee_notes.md` Finding 1).
- Source findings: `9-employee_notes.md` Finding 1
- Risk level: High. Rationale: High-privilege administrative users are prime, high-yield targets. A successful phishing compromise of this account would likely grant broad access to critical infrastructure.
- Exploitation potential: Social engineering

## Vulnerability 3: Supply Chain Risk via Exposed Developer Account
- Description: The public exposure of an authenticated developer account (`dvries`) linked to the internal proprietary Tidewater Risk Engine creates a direct vector for code injection and supply chain compromise by allowing attackers to target a specific developer with access to critical codebases (supported by `9-employee_notes.md` Finding 2).
- Source findings: `9-employee_notes.md` Finding 2
- Risk level: High. Rationale: Developer accounts linked to internal codebases are major supply-chain risks. Compromising this account could allow malicious code to be pushed to proprietary applications.
- Exploitation potential: Supply chain / Technical

## Vulnerability 4: Physical Security Risk via Executive Tracking
- Description: The public disclosure of the Head of Technical Operations' physical routine via GPS tracking, which physically maps to the verified corporate headquarters, enables attackers to execute targeted physical social engineering, tailgating, or physical hardware drops (supported by `9-employee_notes.md` Finding 4 and `6-registry_notes.md` Finding 1).
- Source findings: `9-employee_notes.md` Finding 4, `6-registry_notes.md` Finding 1
- Risk level: Medium. Rationale: Confirmed physical routines of key IT personnel linked to the corporate address significantly lower the barrier for physical intrusion attempts.
- Exploitation potential: Social engineering / Internal access

## Vulnerability 5: Software Vulnerability Profiling via CMS Version Exposure
- Description: The disclosure of the exact deployed corporate CMS version (Veridian CMS 5.2.1) allows attackers to reliably query known CVEs and develop bespoke software exploits without needing to perform noisy, detectable active scanning against the infrastructure (supported by `10-stack_notes.md` Finding 1 and `8-social_notes.md` Finding 3).
- Source findings: `10-stack_notes.md` Finding 1, `8-social_notes.md` Finding 3
- Risk level: Medium. Rationale: Revealing the exact software stack and version greatly accelerates the reconnaissance phase for technical exploitation, enabling an attacker to weaponize specific exploits silently.
- Exploitation potential: Technical
