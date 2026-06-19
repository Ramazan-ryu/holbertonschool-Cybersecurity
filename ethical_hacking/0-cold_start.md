# Pre-Engagement Package Draft: CareNet Regional Clinics

**Client:** CareNet Regional Clinics  
**Primary Contact:** David Chen, CTO  
**Prepared by:** Vanguard Security (Consultant Draft)  
**Date:** [Current Date]  

## 1. Scope Definition

Based on the initial call and email, the testing scope requires strict boundaries to ensure safety and legal compliance.

**Tentatively IN SCOPE:**
* **Internal Networks:** Central IT office network and local networks across the 4 clinic sites.
* **Internal Servers:** Internal file server and associated corporate infrastructure.
* **Public-Facing Website:** The appointment booking website (provided CareNet hosts it directly and it is not a third-party SaaS).
* **Staff Assets:** Employee awareness (Social Engineering) via phishing and limited pretexting, targeting reception and central IT staff.

**Strictly OUT OF SCOPE (Do Not Test):**
* **MedixCloud SaaS Environment:** The Electronic Medical Records (EMR) system and the newly mentioned Patient Portal. These are hosted by a third-party vendor. Testing them without explicit permission from MedixCloud is illegal.
* **Cardiac Monitoring Devices (and other Medical/IoMT Devices):** Active scanning or exploitation of these devices poses a severe life-safety risk to patients. They must be explicitly excluded by IP/MAC address.
* **NetBridge Infrastructure:** The firewall and VPN infrastructure managed by NetBridge cannot be tested without their formal, written consent. 

## 2. Red Flags and Open Concerns

Several critical issues must be addressed before any testing begins:

* **Missing Network Diagram:** David's email mentions an attached network diagram, but no file was included. We need this to identify subnets and accurately separate IT infrastructure from medical devices.
* **Life-Safety Risks (Medical Devices):** David states the cardiac monitors are "on the WiFi". A blanket assessment of the WiFi could accidentally knock these devices offline. We need a segmented guest/IoT network or specific IP ranges to exclude them completely.
* **Third-Party Dependencies:** David says NetBridge is "fine with it," but verbal confirmation is insufficient for a penetration test. We need signed authorization. Furthermore, David casually added the MedixCloud Patient Portal to the scope in his email, which we cannot legally test.
* **Social Engineering on Clinical Staff:** Pretexting nursing staff during clinic hours could delay patient care or cause panic. We must clearly define what pretexting scenarios are allowed and explicitly exclude emergency/active care personnel.
* **Post-Breach Context:** The environment may still be compromised. If we find active ransomware or backdoors during our test, we need an incident response handover protocol.

## 3. Initial Rules of Engagement (RoE)

To ensure smooth and safe execution, the following rules must be established:

* **Testing Windows:** * Internal network scanning and exploitation must occur **outside of clinic operating hours** (e.g., 9:00 PM - 5:00 AM) to avoid disrupting patient services.
    * Social engineering (phishing) can occur during business hours.
* **Communication Protocol:**
    * Daily status updates provided to David Chen.
    * **Emergency Stop:** If any clinic system goes down or patient care is impacted, Vanguard will immediately cease all testing and contact David Chen (requires a 24/7 emergency phone number).
* **Data Handling:** As a healthcare provider, CareNet handles ePHI (Electronic Protected Health Information) regulated by HIPAA. Our consultants will not exfiltrate patient data. If access to ePHI is achieved, we will take a sanitized proof-of-concept screenshot (redacting patient names) and immediately report the vulnerability.

## 4. Authorization Concerns

The current level of authorization is **insufficient** to proceed legally and safely.

* **Executive Sign-Off:** David explicitly stated the CEO does not need to be involved. This is incorrect. A full network penetration test—especially following a recent ransomware incident and driven by insurance requirements—must be authorized and signed by an executive officer (CEO, Board Member, or authorized legal counsel) who bears the ultimate liability for the company.
* **Third-Party Consents:** We require written "Get Out of Jail Free" (authorization) letters from:
    1.  **CareNet CEO/Executive:** Authorizing the overall test.
    2.  **NetBridge:** Authorizing testing against their managed firewall/VPN infrastructure.
    3.  **MedixCloud (Optional):** If David insists on testing the EMR/Patient Portal, CareNet must facilitate written permission from MedixCloud's legal/security team. Otherwise, it remains out of scope.
