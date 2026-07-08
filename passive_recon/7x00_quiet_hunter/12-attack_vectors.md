# Attack Vectors — Helix Maritime Insurance

## Vector 1: Targeted Spear-Phishing against IT Leadership
- Entry point: Corporate email account of Joris Bakker (Infrastructure & Security Lead).
- Exploitation scenario: In a later authorized red-team engagement, this intelligence would support a targeted spear-phishing campaign. Using the validated corporate email `joris.bakker@helix-maritime.example` and identity documented in `9-employee_notes.md` Finding 1, an authorized testing team could draft a highly credible lure. By formatting the message to match the exact corporate email provider (ZephyrMail Business) confirmed in `10-stack_notes.md` Finding 2, the team would attempt to blend in with normal internal traffic to test credential harvesting defenses.
- OSINT prerequisites: `9-employee_notes.md` Finding 1 (Joris Bakker, Infrastructure & Security Lead, joris.bakker@helix-maritime.example); `10-stack_notes.md` Finding 2 (ZephyrMail Business).
- Probable business impact: Operationally, if credentials were obtained, the actor could attempt mailbox access and later misuse. Commercially, if privileged access were achieved, it might allow the actor to attempt internal credential resets, which could theoretically threaten Helix's marine underwriting systems.

## Vector 2: Codebase Reconnaissance via Exposed Repository
- Entry point: Public GitHub repository of the Backend Developer (`dvries`).
- Exploitation scenario: In a later authorized engagement, the team would use the exposed repository details to plan an application security assessment. Based on the public GitHub profile of the Backend Developer identified in `9-employee_notes.md` Finding 2, an authorized team would target the `tidewater-engine` repository. The intelligence gathered allows operators to scope a targeted review of the commit history and metadata to search for internal API structures and framework dependencies related to the Tidewater Risk Engine.
- OSINT prerequisites: `9-employee_notes.md` Finding 2 (Daan de Vries, username dvries, tidewater-engine repository).
- Probable business impact: Operationally, if the repository contained sensitive configuration details, an actor might discover them during review, which could inform later exploitation. Commercially, if proprietary maritime risk-model logic were successfully extracted, it could potentially damage Helix's competitive advantage.

## Vector 3: Vishing Campaign against Corporate Communications
- Entry point: Direct phone line of the Community & Communications Manager, Marleen Koster.
- Exploitation scenario: During an authorized social engineering phase, a red team could execute a voice phishing (vishing) campaign using the direct phone line `+31 10 555 0199` exposed in `9-employee_notes.md` Finding 3. Bypassing the corporate switchboard, the authorized caller would use the upcoming Rotterdam Maritime Week 2025 event (confirmed in `8-social_notes.md` Finding 2) as a conversational pretext. This pairing of unfiltered phone access with a verified corporate initiative would be used to build trust and test the target's susceptibility to disclosing sensitive information.
- OSINT prerequisites: `9-employee_notes.md` Finding 3 (Marleen Koster, direct phone number +31 10 555 0199); `8-social_notes.md` Finding 2 (Rotterdam Maritime Week 2025 event).
- Probable business impact: Operationally, if the target were persuaded, the actor might try a password-reset pretext or attempt to elicit internal logistics. Commercially, if communications assets were successfully hijacked, the actor could potentially issue fraudulent press releases, which might damage client trust.

## Vector 4: Physical Headquarters Interception Planning
- Entry point: The physical perimeter of the corporate headquarters (Wilhelminakade 909).
- Exploitation scenario: In a future authorized physical penetration test, operators would use the physical tracking data of the Head of Technical Operations, Sander de Boer. Using the GPS fitness tracking data (`9-employee_notes.md` Finding 4), a red team would map the predictable start and end times of his routine. Because `6-registry_notes.md` Finding 1 verifies that the route's endpoint is the legally registered corporate headquarters, the authorized team would use this window to plan a physical interception, tailgating attempt, or perimeter breach test at Wilhelminakade 909.
- OSINT prerequisites: `9-employee_notes.md` Finding 4 (Sander de Boer, username sander_db, GPS route at Wilhelminakade 909); `6-registry_notes.md` Finding 1 (Registered corporate address at Wilhelminakade 909).
- Probable business impact: Operationally, the route information could help identify a time when physical access might be attempted. Commercially, if access were gained, it might create an opportunity for downstream compromise, such as targeting internal network assets or deploying implants.
