# Attack Vectors — Helix Maritime Insurance

## Vector 1: Spear-Phishing the IT Lead using Vendor Pretext
- Entry point: Joris Bakker's corporate email account (Infrastructure & Security Lead).
- Exploitation scenario: The attacker crafts a spear-phishing email targeting Joris Bakker directly. The attacker uses `9-employee_notes.md` Finding 1 to know his exact corporate email address and his role as Infrastructure & Security Lead. To make the attack credible, the attacker leverages `10-stack_notes.md` Finding 2, which confirms the company uses ZephyrMail Business. The attacker sends a fake ZephyrMail administrative security alert to Joris Bakker. This specific OSINT combination ensures the email reaches a high-value target with a perfectly matched, vendor-specific lure that he is operationally responsible for managing.
- OSINT prerequisites: `9-employee_notes.md` Finding 1; `10-stack_notes.md` Finding 2.
- Probable business impact: Operationally, the attacker gains control of a high-privilege IT administrative account. Commercially, this allows full compromise of corporate communications, potential ransomware deployment across the domain, and massive financial disruption to Helix's operations.

## Vector 2: Supply Chain Compromise via Developer Repository
- Entry point: Daan de Vries's public developer account (`dvries`).
- Exploitation scenario: The attacker targets the external developer platform account of Daan de Vries. `9-employee_notes.md` Finding 2 explicitly confirms that the username `dvries` belongs to the Backend Developer and that this specific account is hosting the "Tidewater Risk Engine" framework. The attacker uses credential stuffing against this specific developer account to gain unauthorized access. Because the OSINT directly ties this account to the internal risk-modelling engine, the attacker uses the compromised account to modify the proprietary code or steal internal API keys found in the commit history.
- OSINT prerequisites: `9-employee_notes.md` Finding 2.
- Probable business impact: Operationally, the attacker achieves a direct supply chain code injection into the internal tools. Commercially, altering the maritime risk-modelling algorithms would result in severe financial mispricing of insurance policies and catastrophic loss of client trust.

## Vector 3: Targeted Vishing using Corporate Event Pretext
- Entry point: The direct phone line of the Community & Communications Manager, Marleen Koster.
- Exploitation scenario: The attacker conducts a voice phishing (vishing) campaign by calling Marleen Koster directly. By using the exact phone number revealed in `9-employee_notes.md` Finding 3, the attacker completely bypasses the main corporate switchboard and reception filtering. To establish immediate trust, the attacker poses as internal IT and references the upcoming "Rotterdam Maritime Week 2025" exhibition, which was confirmed as a major upcoming corporate initiative in `8-social_notes.md` Finding 2. The attacker uses the urgency of this specific event to pressure the Communications Manager into verbally revealing her password over the phone.
- OSINT prerequisites: `9-employee_notes.md` Finding 3; `8-social_notes.md` Finding 2.
- Probable business impact: Operationally, the attacker acquires valid employee credentials and bypasses perimeter security. Commercially, compromising the communications manager allows the attacker to issue fraudulent public statements, causing immediate reputational and market value damage to Helix Maritime.

## Vector 4: Physical Penetration via Routine Interception
- Entry point: The physical perimeter of the corporate headquarters via the Head of Technical Operations.
- Exploitation scenario: A red team operative attempts unauthorized physical entry into the Helix headquarters by targeting Sander de Boer. `9-employee_notes.md` Finding 4 provides the exact GPS tracking map of his daily fitness running route, showing precisely when he leaves and returns. `6-registry_notes.md` Finding 1 confirms that the start and end point of this GPS route is exactly Wilhelminakade 909, the legally registered corporate headquarters. The operative waits at this exact address during his tracked return window and uses physical proximity to tailgate behind him through the secure access doors as he re-enters the building.
- OSINT prerequisites: `9-employee_notes.md` Finding 4; `6-registry_notes.md` Finding 1.
- Probable business impact: Operationally, the attacker bypasses all external network firewalls by gaining physical access to the internal corporate facility. Commercially, physical access can lead to direct theft of proprietary hardware and complete operational paralysis of the headquarters.
