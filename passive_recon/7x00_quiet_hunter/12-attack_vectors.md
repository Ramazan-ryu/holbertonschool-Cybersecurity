# Attack Vectors — Helix Maritime Insurance

## Vector 1: Targeted Spear-Phishing against IT Leadership
- Entry point: Corporate email account of Joris Bakker (Infrastructure & Security Lead).
- Exploitation scenario: The attacker drafts a targeted phishing email delivered directly to the Infrastructure & Security Lead. This is executed by using the validated corporate email `joris.bakker@helix-maritime.example` and identity documented in `9-employee_notes.md` Finding 1. To provide legitimate context for the email, the attacker formats the message using the exact corporate email provider (ZephyrMail Business) explicitly confirmed in `10-stack_notes.md` Finding 2. The attack chain relies strictly on matching the confirmed IT executive target with the verified internal email infrastructure environment.
- OSINT prerequisites: `9-employee_notes.md` Finding 1 (Joris Bakker, Infrastructure & Security Lead, joris.bakker@helix-maritime.example); `10-stack_notes.md` Finding 2 (ZephyrMail Business).
- Probable business impact: Operationally, the attacker achieves credential theft resulting in full mailbox takeover of a ZephyrMail administrative account. Commercially, this privileged access allows the attacker to reset internal credentials, directly compromising Helix's marine underwriting systems and resulting in severe regulatory fines.

## Vector 2: Codebase Reconnaissance via Exposed Repository
- Entry point: Public GitHub repository of the Backend Developer (`dvries`).
- Exploitation scenario: The attacker maps the internal proprietary risk-modelling logic without needing to bypass corporate firewalls. This is achieved by reviewing the public commit history and cached metadata of the `tidewater-engine` repository belonging to Daan de Vries, as explicitly identified in `9-employee_notes.md` Finding 2. The attacker clones the exposed repository to search the commit metadata for internal API structure and framework dependencies related to the Tidewater Risk Engine.
- OSINT prerequisites: `9-employee_notes.md` Finding 2 (Daan de Vries, username dvries, tidewater-engine repository).
- Probable business impact: Operationally, the attacker identifies hardcoded API keys or vulnerable dependencies within the Tidewater Risk Engine codebase. Commercially, the extraction of proprietary maritime risk-model logic used in Helix's core underwriting decisions destroys their competitive advantage and allows rival insurers to undercut their pricing.

## Vector 3: Vishing Campaign against Corporate Communications
- Entry point: Direct phone line of the Community & Communications Manager, Marleen Koster.
- Exploitation scenario: The attacker initiates a voice phishing (vishing) call that bypasses the corporate switchboard entirely by dialing the direct phone number `+31 10 555 0199` exposed in `9-employee_notes.md` Finding 3. Upon connecting with the Communications Manager, Marleen Koster, the attacker uses the upcoming Rotterdam Maritime Week 2025 event—confirmed in `8-social_notes.md` Finding 2—as the conversational pretext. The chain unfolds by pairing the unfiltered phone access with a verified corporate initiative to build trust.
- OSINT prerequisites: `9-employee_notes.md` Finding 3 (Marleen Koster, direct phone number +31 10 555 0199); `8-social_notes.md` Finding 2 (Rotterdam Maritime Week 2025 event).
- Probable business impact: Operationally, the attacker succeeds in convincing Marleen to disclose internal event logistics or authorize a fake password reset request. Commercially, hijacking Helix's official communications assets allows the attacker to issue fraudulent press releases during the Maritime Week, directly damaging client trust in the marine insurance market.

## Vector 4: Physical Headquarters Interception Planning
- Entry point: The physical perimeter of the corporate headquarters (Wilhelminakade 909).
- Exploitation scenario: The attacker plans a physical interception at the corporate facility by tracking the Head of Technical Operations, Sander de Boer. Using the GPS fitness tracking data for username `sander_db` from `9-employee_notes.md` Finding 4, the attacker maps the exact start and end times of his routine. The attacker explicitly links this route to the corporate facility because `6-registry_notes.md` Finding 1 verifies that the route's endpoint, Wilhelminakade 909, is the legally registered corporate headquarters.
- OSINT prerequisites: `9-employee_notes.md` Finding 4 (Sander de Boer, username sander_db, GPS route at Wilhelminakade 909); `6-registry_notes.md` Finding 1 (Registered corporate address at Wilhelminakade 909).
- Probable business impact: Operationally, the attacker identifies a specific, predictable window for physical intrusion through the Wilhelminakade 909 secure doors. Commercially, targeting unattended hardware/network assets at the Rotterdam headquarters allows the deployment of a network implant, paving the way for ransomware and complete operational paralysis of the firm.
