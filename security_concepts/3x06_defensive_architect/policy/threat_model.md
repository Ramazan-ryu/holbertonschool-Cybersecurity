                  
# Threat Model – BioHealth

Repository: holbertonschool-cybersecurity/security_concepts/3x06_defensive_architect/policy
File: threat_model.md

---

## Overview

This threat model identifies threats to BioHealth’s systems, data, personnel, and physical environment.
We use the STRIDE methodology and explicitly map threat actors to each identified threat.

---

## STRIDE Analysis

STRIDE: Spoofing
Component: User accounts & SSH keys
Top Threat: Stolen credentials or shared SSH key used to access servers
Likely Threat Actor: External attacker (cybercriminal)

STRIDE: Tampering
Component: Servers & databases
Top Threat: Unauthorized modification of patient data
Likely Threat Actor: Insider employee

STRIDE: Repudiation
Component: Audit logs
Top Threat: Logs deleted to hide malicious activity
Likely Threat Actor: Insider sysadmin

STRIDE: Information Disclosure
Component: Patient data
Top Threat: Leakage of confidential information
Likely Threat Actor: External attacker or competitor

STRIDE: Denial of Service
Component: Critical servers & network
Top Threat: Service disruption or ransomware attack
Likely Threat Actor: External attacker (script kiddie or ransomware operator)

STRIDE: Elevation of Privilege
Component: Admin/root accounts
Top Threat: Unauthorized admin access
Likely Threat Actor: Insider or external attacker

---

## Physical Security Threats

Threat 1: Server room door propped open
Threat Actor: Opportunistic intruder or malicious visitor

Threat 2: Delivery person in server room without check-in
Threat Actor: Malicious contractor or delivery agent

Threat 3: Whiteboard with passwords
Threat Actor: Insider or casual intruder

Threat 4: Unlocked laptops
Threat Actor: Insider or opportunistic visitor

Threat 5: Generic unlabeled keycards
Threat Actor: Unauthorized staff or intruder

---

## Technical & Network Threats

Threat 1: Shared SSH key in Slack
Component: Server authentication
Severity: High
Threat Actor: External attacker

Threat 2: PostgreSQL 5432 open to 0.0.0.0/0
Component: Database exposure
Severity: High
Threat Actor: External attacker

Threat 3: No backup verification
Component: Data recovery
Severity: Medium
Threat Actor: Internal mistake or attacker

Threat 4: Everyone has root access
Component: Server accounts
Severity: High
Threat Actor: Insider or external attacker

Threat 5: Weak PINs (e.g., 1975)
Component: User authentication
Severity: Medium
Threat Actor: External attacker

Threat 6: No logging enabled
Component: Systems & audit
Severity: High
Threat Actor: Insider (malicious employee)

---

## Human / Insider Threats

- Employees writing passwords on whiteboards or post-it notes
- Sysadmins creating unmonitored accounts (e.g., sysadmin2)
- Staff with excessive privileges performing unauthorized actions
- Social engineering risks: phishing, pretexting, or tailgating

---

## Critical Assets

1. Patient data – highest sensitivity
2. Authentication systems – SSH, admin accounts, MFA
3. Servers & databases – EHR and internal applications
4. Physical security systems – server room, access control, keycards
5. Network infrastructure – internal LAN, VPN, firewalls

---

## Recommendations

1. Implement multi-factor authentication (MFA) for all accounts
2. Enforce least privilege and role-based access control (RBAC)
3. Secure physical access to server rooms and sensitive areas
4. Monitor and retain logs for at least 365 days with integrity checks
5. Conduct regular security awareness training for all staff
6. Close exposed ports (e.g., PostgreSQL 5432) and verify backups regularly
7. Remove generic/unlabeled keycards and secure workstations
8. Implement strong PIN/password policies
9. Audit SSH key usage and remove shared or leaked keys
10. Perform periodic penetration tests and physical security reviews

