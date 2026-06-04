#!/bin/bash
# hardening.sh - SecureHealth server hardening script
# This script applies SSH, password, package, and system hardening.
# It disables unsafe defaults, enforces RBAC, and secures network access.
# Author: SecureHealth Security Team
# Date: 2026-04-02

set -e

echo "[*] Starting SecureHealth server hardening..."

# ------------------------------
# 1. System Updates
# ------------------------------
echo "[*] Updating system packages..."
apt-get update -y && apt-get upgrade -y

# ------------------------------
# 2. Disable unnecessary services and remove unsafe packages
# ------------------------------
echo "[*] Disabling unnecessary services and removing unsafe packages..."
systemctl disable rpcbind || true
systemctl stop rpcbind || true
systemctl disable avahi-daemon || true
systemctl stop avahi-daemon || true
apt-get remove -y telnetd || true

# ------------------------------
# 3. SSH Hardening
# ------------------------------
echo "[*] Hardening SSH..."
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# ------------------------------
# 4. Password Policy (PAM/login.defs)
# ------------------------------
echo "[*] Enforcing password policy..."
if grep -q pam_pwquality.so /etc/pam.d/common-password; then
    sed -i 's/pam_pwquality.so.*/pam_pwquality.so retry=3 minlen=14 enforce_for_root/' /etc/pam.d/common-password
fi
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN    14/' /etc/login.defs
sed -i 's/^#PASS_WARN_AGE.*/PASS_WARN_AGE    7/' /etc/login.defs

# ------------------------------
# 5. User & SSH Key Hardening
# ------------------------------
echo "[*] Configuring users and SSH keys..."
groupadd -f devs
groupadd -f ops
groupadd -f auditors
id -u devuser &>/dev/null || useradd -m -G devs devuser
mkdir -p /home/devuser/.ssh
chmod 700 /home/devuser/.ssh
if [ -f /keys/devuser_id_rsa.pub ]; then
    cp /keys/devuser_id_rsa.pub /home/devuser/.ssh/authorized_keys
    chmod 600 /home/devuser/.ssh/authorized_keys
    chown -R devuser:devs /home/devuser/.ssh
fi
# Remove shared nexus_master.pem key if present
find /home/*/.ssh/authorized_keys -type f -exec sed -i '/nexus_master.pem/d' {} \;

# ------------------------------
# 6. File Permissions
# ------------------------------
echo "[*] Setting secure file permissions..."
chmod 750 /etc/securehealth/ 2>/dev/null || true
chmod 700 /var/log/securehealth/ 2>/dev/null || true

# ------------------------------
# 7. Firewall / Network Hardening
# ------------------------------
echo "[*] Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow from 10.0.0.0/24 to any port 22
ufw deny 5432
ufw allow from 10.0.0.0/24 to 5432 proto tcp
ufw --force enable

# ------------------------------
# 8. Logging & Audit
# ------------------------------
echo "[*] Configuring audit logging..."
apt-get install -y auditd
systemctl enable auditd
systemctl start auditd
auditctl -w /etc/sudoers -p wa -k sudo_changes
auditctl -w /etc/ssh/sshd_config -p wa -k ssh_changes

# ------------------------------
# 9. Remove unsafe defaults
# ------------------------------
echo "[*] Removing unsafe defaults..."
find /home/* -name ".rhosts" -exec rm -f {} \;

# ------------------------------
# Final message
# ------------------------------
echo "[*] Server hardening completed successfully."
