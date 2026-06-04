# SecureHealth – Final Audit Report

## Goal
Demonstrate that all implemented security controls are active, effective, and in compliance with the SecureHealth policies.

---

## 1. Verification Commands

### System Hardening / SSH
```bash
# Check root login is disabled
grep ^PermitRootLogin /etc/ssh/sshd_config

# Check password authentication is disabled
grep ^PasswordAuthentication /etc/ssh/sshd_config

# Check password policy
cat /etc/login.defs | grep PASS
grep pam_pwquality /etc/pam.d/common-password

# List groups
getent group devs
getent group ops
getent group auditors

# Check sudo privileges for key users
sudo -l -U sarah
sudo -l -U dave

# Verify home directory permissions
ls -la /home/devuser
ls -la /home/opsuser
ls -la /home/auditor

# Verify default deny and allowed ports
ufw status verbose
ufw status numbered
ss -tlnp | grep 5432

# Verify rsyslog forwarding
grep $CENTRAL_LOG_SERVER /etc/rsyslog.d/50-central.conf

# Verify auditd rules
auditctl -l



