# Attack Vectors — Helix Maritime Insurance

## Vector 1: IT Leadership Spear-Phishing via Migration Pretext
- Entry point: Infrastructure & Security Lead email account (Joris Bakker).
- Exploitation scenario: An attacker crafts a highly targeted spear-phishing email masquerading as a critical alert regarding the ongoing ZephyrMail Business or CRM platform migration. Because the target is responsible for IT infrastructure, a contextual lure requesting an urgent "administrative re-authentication" for the new mailbox deployment is highly believable. The email contains a link to a credential-harvesting portal spoofing the ZephyrMail login page.
- OSINT prerequisites: `9-employee_notes.md` Finding 1 (CISO identification and email pattern); `10-stack_notes.md` Finding 2 (ZephyrMail Business confirmation); `7-jobs_notes.md` Finding 1 (CRM migration context).
- Probable business impact: Initial access to an administrative account. Compromise of the IT Lead yields the "keys to the kingdom" (cloud environments, identity providers, and internal routing), leading to rapid domain compromise and massive data exfiltration.

## Vector 2: Supply Chain Compromise via Public Developer Account
- Entry point: Backend Developer's public GitHub account (`dvries`).
- Exploitation scenario: The attacker targets Daan de Vries using credential stuffing or a specialized phishing lure aimed at software developers. Since his public account is directly linked to the internal "Tidewater Risk Engine", an attacker gaining control of this account can analyze the commit history for hardcoded API keys or, if access permits, inject malicious code (supply chain attack) that gets pulled into the Helix corporate environment during the next build cycle.
- OSINT prerequisites: `9-employee_notes.md` Finding 2 (Developer username, identity, and Tidewater Risk Engine repository exposure).
- Probable business impact: Compromise of the proprietary risk-modelling engine. Manipulation of underwriting algorithms could cause massive financial miscalculations, and embedded backdoors would grant persistent, stealthy access to the corporate backend APIs.

## Vector 3: Vishing the Communications Manager using Event Pretext
- Entry point: Direct phone line of the Community & Communications Manager (Marleen Koster).
- Exploitation scenario: Utilizing the inadvertently exposed direct phone line, an attacker calls the Communications Manager, spoofing the caller ID to appear as Helix IT Support. The attacker leverages the public knowledge of the upcoming Rotterdam Maritime Week event as a pretext (e.g., "We need to urgently verify your mobile device sync before the Maritime Week press traffic"). The goal is to verbally coerce the target into revealing credentials or accepting an MFA push notification.
- OSINT prerequisites: `9-employee_notes.md` Finding 3 (Direct phone number exposure); `8-social_notes.md` Finding 2 (Upcoming Rotterdam Maritime Week 2025 event).
- Probable business impact: Bypassing MFA to gain initial access to a corporate communications account. This allows the attacker to launch trusted internal phishing campaigns against executives, manipulate external press releases to damage corporate reputation, or intercept sensitive corporate emails.

## Vector 4: Physical Tailgating via IT Executive Routine Tracking
- Entry point: Physical corporate headquarters and the Head of Technical Operations (Sander de Boer).
- Exploitation scenario: A physical red team utilizes the exposed GPS running routines of Sander de Boer. Knowing the exact days and times his runs start and end at the corporate office, an operative intercepts him at the building entrance during his post-run return. The operative leverages the distraction and physical proximity to tailgate through the secure doors, subsequently connecting a rogue hardware device (e.g., a network implant) to an unattended port in the office.
- OSINT prerequisites: `9-employee_notes.md` Finding 4 (GPS routine tracking); `6-registry_notes.md` Finding 1 (Exact registered HQ address at Wilhelminakade 909).
- Probable business impact: Direct, physical access to the internal network. This bypasses all external firewalls, web application protections, and perimeter defenses, leading to immediate internal reconnaissance and the potential deployment of ransomware from inside the trusted network.
