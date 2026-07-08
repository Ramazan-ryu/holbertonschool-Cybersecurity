# Vulnerabilities Identified — Helix Maritime Insurance

## Vulnerability 1: Internal Network Infrastructure Exposure
- Description: [Exposure of internal hostname `hlx-mail01` and IP `198.51.100.25` on a whiteboard] -> [Leakage of internal naming conventions, though the IP is an RFC 5737 TEST-NET-2 address] -> [Aids attackers in mapping the internal environment for lateral movement post-breach] (status: IP is decoy/unconfirmed; hostname is partially usable; historical/uncertain; not confirmed current exposure) (supported by `8-social_notes.md` Finding 3).
- Source findings: `8-social_notes.md` Finding 3
- Risk level: Low
- Rationale: Direct external network exploitation is mitigated because the IP is a non-routable decoy, but the exposure of internal naming conventions still aids attackers in mapping the internal environment if a breach occurs.
- Exploitation potential: Technical

## Vulnerability 2: Executive Spear-Phishing via Email Pattern Exposure
- Description: [Verified corporate email pattern combined with the confirmed identity of Infrastructure & Security Lead Joris Bakker] -> [Exposure of a highly privileged target's direct contact vector] -> [Allows attackers to craft highly targeted spear-phishing campaigns directed at a system administrator] (status: validated) (supported by `9-employee_notes.md` Finding 1).
- Source findings: `9-employee_notes.md` Finding 1
- Risk level: High
- Rationale: High-privilege administrative users are prime, high-yield targets. A successful phishing compromise of this account would likely grant broad access to critical infrastructure.
- Exploitation potential: Social engineering

## Vulnerability 3: Supply Chain Risk via Exposed Developer Account
- Description: [Public exposure of authenticated developer account `dvries` linked to the proprietary Tidewater Risk Engine] -> [Direct access vector to critical internal codebases] -> [Enables targeted code injection and supply chain compromise by targeting a specific developer] (status: validated) (supported by `9-employee_notes.md` Finding 2).
- Source findings: `9-employee_notes.md` Finding 2
- Risk level: High
- Rationale: Developer accounts linked to internal codebases are major supply-chain risks. Compromising this account could allow malicious code to be pushed to proprietary applications.
- Exploitation potential: Supply chain / Technical

## Vulnerability 4: Physical Security Risk via Executive Tracking
- Description: [GPS tracking data matching the Head of Technical Operations' physical routine to the verified corporate headquarters] -> [Disclosure of key IT personnel's physical location and predictability] -> [Enables targeted physical social engineering, tailgating, or hardware drops] (status: validated) (supported by `9-employee_notes.md` Finding 4 and `6-registry_notes.md` Finding 1).
- Source findings: `9-employee_notes.md` Finding 4, `6-registry_notes.md` Finding 1
- Risk level: Medium
- Rationale: Confirmed physical routines of key IT personnel linked to the corporate address significantly lower the barrier for physical intrusion attempts.
- Exploitation potential: Social engineering / Internal access

## Vulnerability 5: Software Vulnerability Profiling via CMS Version Exposure
- Description: [Disclosure of Veridian CMS 5.2.1 via HTML source code, Web Archive snapshots, and a sprint planning whiteboard] -> [Exposure of the exact deployed corporate software stack and version] -> [Allows attackers to reliably query known CVEs and develop bespoke exploits without noisy scanning] (status: validated; web archive data is historical but cross-verified as current) (supported by `10-stack_notes.md` Finding 1 and `8-social_notes.md` Finding 3).
- Source findings: `10-stack_notes.md` Finding 1, `8-social_notes.md` Finding 3
- Risk level: Medium
- Rationale: Revealing the exact software stack and version greatly accelerates the reconnaissance phase for technical exploitation, enabling an attacker to weaponize specific exploits silently.
- Exploitation potential: Technical
