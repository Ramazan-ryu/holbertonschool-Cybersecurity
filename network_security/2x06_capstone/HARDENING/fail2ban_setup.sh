#!/bin/bash

set -e

echo "[+] Installing Fail2Ban..."

apt update -y
apt install -y fail2ban

# Backup default config
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local.bak

echo "[+] Creating custom jail for SSH brute force..."

cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 600        # Ban duration in seconds (10 minutes)
findtime = 600       # Time window to check for failures
maxretry = 5         # Number of failures before ban
backend = systemd

[sshd]
enabled = true
port    = ssh
logpath = /var/log/auth.log
EOF

echo "[+] Restarting Fail2Ban service..."
systemctl enable fail2ban
systemctl restart fail2ban

echo "[+] Fail2Ban setup complete."

echo "[+] Test by attempting multiple failed SSH logins from another host."
echo "Check status with: sudo fail2ban-client status sshd"
