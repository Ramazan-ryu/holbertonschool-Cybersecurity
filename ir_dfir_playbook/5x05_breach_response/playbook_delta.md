# Playbook Delta – Credential Exposure Response

---

## Change 1 – NTLM Lateral Movement Detection Upgrade

section changed: Credential Exposure Detection – Lateral Movement Rule

before:
"If lateral movement is suspected, escalate for forensic review."

after:
"If NTLM authentication occurs across multiple hosts within a short time window (example: WS-104 → WS-107 → WS-112), automatically trigger HIGH severity incident, isolate affected hosts, and force immediate credential reset including all active sessions."

incident finding:
SYSMON-001 confirmed NTLM-based lateral movement across WS-104, WS-107, and WS-112 during attacker dwell period.

---

## Change 2 – Credential Scope Expansion for Compromised Accounts (scope expansion)

section changed: Credential Containment Scope Definition

before:
"Reset credentials for confirmed compromised accounts only."

after:
"Upon confirmation of credential misuse or NTLM relay activity, expand reset scope to include:
- all accounts used on affected hosts during dwell window
- all accounts that authenticated within lateral movement chain
- enforce domain-wide session invalidation for privileged users"

incident finding:
MEM-003 and SYSMON-001 showed credential reuse across multiple systems during lateral movement, indicating broader credential exposure requiring scope expansion.

---

## Change 3 – Authentication Anomaly Trigger (VPN impossible-travel + krbtgt + HIPAA)

section changed: Authentication Risk Trigger Rules

before:
"Investigate repeated authentication failures or unusual login patterns."

after:
"Trigger automatic investigation and conditional lockout when:
- VPN impossible-travel is detected between geographically inconsistent logins
- Kerberos anomalies involving krbtgt ticket patterns are observed
- HIPAA-relevant patient data access occurs outside approved workflows
- authentication is observed from multiple internal hosts without normal session chaining

Escalate to identity compromise workflow immediately."

incident finding:
PROXY-003 and SYSMON-001 indicate distributed authentication patterns consistent with session reuse, VPN impossible-travel behavior, and potential Kerberos ticket abuse involving krbtgt.
