# Attack Vectors — Helix Maritime Insurance

## Vector 1: Targeted Spear-Phishing against IT Leadership
- Entry point: Corporate email account of Joris Bakker (Infrastructure & Security Lead).
- Exploitation scenario: The attacker drafts a targeted phishing email delivered directly to the Infrastructure & Security Lead. This is executed by using the validated corporate email `joris.bakker@helix-maritime.example` and identity documented in `9-employee_notes.md` Finding 1. To provide legitimate context for the email, the attacker formats the message using the exact corporate email provider (ZephyrMail Business) explicitly confirmed in `10-stack_notes.md` Finding 2. The attack chain relies strictly on matching the confirmed IT executive target with the verified internal email infrastructure environment.
- OSINT prerequisites: `9-employee_notes.md` Finding 1 (Joris Bakker, Infrastructure & Security Lead, joris.bakker@helix-maritime.example); `10-stack_notes.md` Finding 2 (ZephyrMail Business).
- Probable business impact: Operationally, delivering a malicious payload directly to an administrative IT endpoint. Commercially, compromising the security lead exposes the organization to systemic data breaches and regulatory penalties.

## Vector 2: Codebase Reconnaissance via Exposed Repository
- Entry point: Public GitHub repository of the Backend Developer (`dvries`).
- Exploitation scenario: The attacker maps the internal proprietary risk-modelling logic without needing to bypass corporate firewalls. This is achieved by reviewing the public commit history and cached metadata of the `tidewater-engine` repository belonging to Daan de Vries, as explicitly identified in `9-employee_notes.md` Finding 2. The attacker clones the exposed repository to search the commit metadata for internal API structure and framework dependencies related to the Tidewater Risk Engine.
- OSINT prerequisites: `9-employee_notes.md` Finding 2 (Daan de Vries, username dvries, tidewater-engine repository).
- Probable business impact: Operationally, mapping internal code logic and identifying software dependencies. Commercially, the exposure of trade secrets and intellectual property related to Helix's core maritime risk assessment algorithms.

## Vector 3: Vishing Campaign against Corporate Communications
- Entry point: Direct phone line of the Community & Communications Manager, Marleen Koster.
- Exploitation scenario: The attacker initiates a voice phishing (vishing) call that bypasses the corporate switchboard entirely by dialing the direct phone number `+31 10 555 0199` exposed in `9-employee_notes.md` Finding 3. Upon connecting with the Communications Manager, Marleen Koster, the attacker uses the upcoming Rotterdam Maritime Week 2025 event—confirmed in `8-social_notes.md` Finding 2—as the conversational pretext. The chain unfolds by pairing the unfiltered phone access with a verified corporate initiative to build trust.
- OSINT prerequisites: `9-employee_notes.md` Finding 3 (Marleen Koster, direct phone number +31 10 555 0199); `8-social_notes.md` Finding 2 (Rotterdam Maritime Week 2025 event).
- Probable business impact: Operationally, bypassing technical perimeter filters to establish direct communication. Commercially, manipulating the communications manager facilitates unauthorized public disclosures and severe reputational damage.

## Vector 4: Physical Headquarters Interception Planning
- Entry point: The physical perimeter of the corporate headquarters (Wilhelminakade 909).
- Exploitation scenario: The attacker plans a physical interception at the corporate facility by tracking the Head of Technical Operations, Sander de Boer. Using the GPS fitness tracking data for username `sander_db` from `9-employee_notes.md` Finding 4, the attacker maps the exact start and end times of his routine. The attacker explicitly links this route to the corporate facility because `6-registry_notes.md` Finding 1 verifies that the route's endpoint, Wilhelminakade 909, is the legally registered corporate headquarters.
- OSINT prerequisites: `9-employee_notes.md` Finding 4 (Sander de Boer, username sander_db, GPS route at Wilhelminakade 909); `6-registry_notes.md` Finding 1 (Registered corporate address at Wilhelminakade 909).
- Probable business impact: Operationally, mapping the exact times an IT executive enters and leaves the physical perimeter. Commercially, enabling physical access planning that could result in hardware theft or direct internal network compromise.
