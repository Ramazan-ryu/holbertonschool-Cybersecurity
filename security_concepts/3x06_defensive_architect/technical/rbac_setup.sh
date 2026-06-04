#!/bin/bash
# rbac_setup.sh - Configure RBAC for SecureHealth servers
# Implements Least Privilege: devs, ops, auditors
# Allows Sarah to restart Nginx without root, Dave to read logs without editing configs
# Author: SecureHealth Security Team
# Date: 2026-04-02

set -e

echo "[*] Starting RBAC setup..."

# ------------------------------
# 1. Create groups
# ------------------------------
echo "[*] Creating groups..."
groupadd -f devs
groupadd -f ops
groupadd -f auditors

# ------------------------------
# 2. Create dummy users
# ------------------------------
echo "[*] Creating users..."
id -u sarah &>/dev/null || useradd -m -G devs,sudo sarah
id -u dave &>/dev/null || useradd -m -G ops,daveops dave
id -u auditor1 &>/dev/null || useradd -m -G auditors auditor1

# ------------------------------
# 3. Set strict home directory permissions
# ------------------------------
echo "[*] Setting home directory permissions..."
chmod 750 /home/sarah
chmod 750 /home/dave
chmod 750 /home/auditor1

# ------------------------------
# 4. Configure Sudoers for least privilege
# ------------------------------
echo "[*] Configuring sudoers..."
# Backup existing sudoers
cp /etc/sudoers /etc/sudoers.bak

# Remove old custom entries
sed -i '/# SecureHealth RBAC/,/# End SecureHealth RBAC/d' /etc/sudoers

# Add SecureHealth RBAC
cat << 'EOF' >> /etc/sudoers
# SecureHealth RBAC
# Allow Sarah to restart nginx without full root
sarah ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx, /bin/systemctl status nginx

# Allow Dave read-only access to logs
dave ALL=(ALL) NOPASSWD: /bin/less /var/log/nginx/*.log, /usr/bin/tail -n 100 /var/log/nginx/*.log

# Auditors have read-only sudo access to specific commands (example)
auditor1 ALL=(ALL) NOPASSWD: /bin/less /var/log/securehealth/*.log
# End SecureHealth RBAC
EOF

# Validate sudoers file
visudo -c

# ------------------------------
# 5. Remove direct root login for all
# ------------------------------
echo "[*] Ensuring no direct root login via sudo..."
chmod 440 /etc/sudoers

# ------------------------------
# 6. Remove users from unnecessary groups
# ------------------------------
echo "[*] Cleaning up unnecessary group memberships..."
gpasswd -d sarah sudo || true
gpasswd -d dave sudo || true

# ------------------------------
# Final message
# ------------------------------
echo "[*] RBAC setup completed successfully."
