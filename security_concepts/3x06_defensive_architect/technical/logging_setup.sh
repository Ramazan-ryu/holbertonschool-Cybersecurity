#!/bin/bash
# logging_setup.sh - Centralized logging and audit configuration for SecureHealth
# Configures rsyslog forwarding, auditd monitoring, and immutable audit rules
# Author: SecureHealth Security Team
# Date: 2026-04-02

set -e

echo "[*] Starting logging and audit setup..."

# ------------------------------
# 0. Check required environment variable
# ------------------------------
: "${CENTRAL_LOG_SERVER:?Need to set CENTRAL_LOG_SERVER environment variable}"

echo "[*] Central log server IP: $CENTRAL_LOG_SERVER"

# ------------------------------
# 1. Install required packages
# ------------------------------
echo "[*] Installing rsyslog and auditd..."
apt-get update -y
apt-get install -y rsyslog auditd audispd-plugins

# ------------------------------
# 2. Configure rsyslog to forward critical logs
# ------------------------------
echo "[*] Configuring rsyslog forwarding..."
RSYSLOG_CONF="/etc/rsyslog.d/50-central.conf"

cat > "$RSYSLOG_CONF" << EOF
# Forward all critical logs to central log server
*.crit @@$CENTRAL_LOG_SERVER:514
EOF

# Restart rsyslog to apply
systemctl restart rsyslog
systemctl enable rsyslog

# ------------------------------
# 3. Configure auditd rules for sensitive files and privileged commands
# ------------------------------
echo "[*] Configuring auditd rules..."
AUDIT_RULES="/etc/audit/rules.d/securehealth.rules"

cat > "$AUDIT_RULES" << EOF
# Monitor sudoers file
-w /etc/sudoers -p wa -k sudo_changes

# Monitor SSH configuration
-w /etc/ssh/sshd_config -p wa -k ssh_config_changes

# Monitor sensitive directories
-w /etc/securehealth/ -p wa -k securehealth_config
-w /var/log/securehealth/ -p wa -k securehealth_logs

# Monitor execution of privileged commands
-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k privileged_exec
-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k privileged_exec
EOF

# Load rules and enable
augenrules --load
systemctl restart auditd
systemctl enable auditd

# ------------------------------
# 4. Make audit configuration immutable until reboot
# ------------------------------
echo "[*] Making audit rules immutable..."
auditctl -e 2

# ------------------------------
# Final message
# ------------------------------
echo "[*] Centralized logging and auditd setup completed successfully."
