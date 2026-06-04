# Access Control Policy - SecureHealth

## Goal
Define rules for digital engagement to enforce **efficiency** and **safety**, eliminate shared credentials, and enable scripting for enforcement.

---

## Authentication

- Individual SSH keys per user (kill shared nexus_master.pem)
- Strong password policy: minimum 14-character complex passwords
- MFA/2FA required for all production systems
- No password sharing allowed
- Key rotation schedule: rotate all SSH keys annually or upon departure
- Disable password SSH login; only key-based authentication permitted
- Audit and revoke old/unused keys automatically
- Centralized management of `authorized_keys` for all servers
- Revoked keys removed within 24 hours
- Automated scripts to enforce authentication policies

---

## Authorization (RBAC)

- Define roles: devs, ops, auditors
- Principle of Least Privilege enforced per role
- Sarah (Lead Dev): allowed to restart nginx without root
- Dave (CTO): allowed to read logs without editing configuration
- Sudo rules assigned per role; no exceptions
- Separation of duties enforced across environments
- No direct root login permitted
- Role assignment controlled by scripts or configuration management
- Access to production only via role-based permissions
- Audit logging of all privileged commands

---

## Network

- Close database port 5432 to public access
- VPN requirement for all remote access
- Bastion host required for SSH into sensitive systems
- Network segmentation: dev, staging, production isolated
- Default deny policy enforced on all firewalls
- Whitelist approach for all administrative access
- Encrypted communications using TLS 1.3 internally and externally
- Firewall rules automated with scripts
- Periodic scans detect open ports and unauthorized access

---

## Bali Remote Team Access

- Proper VPN with higher performance endpoints
- Database access via proxy/jump host only
- Region-specific VPN endpoints for remote teams
- Read replicas for remote team to reduce direct DB access
- Never expose database directly to the internet
- Audit all remote team access for compliance
- Enforce same authentication and RBAC rules for remote users

---

## Technical / Scriptable Implementation

- Groups: devs, ops, auditors
- Sudo commands restricted per group:  
  - devs: restart nginx, manage dev environment only  
  - ops: deploy applications, monitor system  
  - auditors: read-only logs
- Firewall rules example:  
```bash
ufw default deny incoming
ufw allow from 10.0.0.0/24 to any port 22
ufw allow from 10.0.0.0/24 to 5432 proto tcp


asdfghj
asdfghjkl
asdfghjk
sdfghj
asdfghj
asdfghjk
