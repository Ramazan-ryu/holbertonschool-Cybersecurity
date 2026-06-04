#!/bin/bash
# =========================================
# init-identity.sh
# Harden Linux Identity & Access Controls
# =========================================

set -euo pipefail

echo "=== Identity Hardening Script ==="

# --------------------------
# 1. Password Policies (PAM)
# --------------------------
echo "Configuring password policies..."
PAM_FILE="/etc/security/pwquality.conf"
[ ! -f "${PAM_FILE}.bak" ] && cp "$PAM_FILE" "${PAM_FILE}.bak"

# Remove existing settings to ensure idempotency
sed -i '/^minlen/d;/^dcredit/d;/^ucredit/d;/^ocredit/d;/^lcredit/d' "$PAM_FILE"

# Append secure defaults
cat >> "$PAM_FILE" <<EOF
minlen = 12
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
EOF
echo "  Password policies: OK"

# --------------------------
# 2. Account Lockout (pam_tally2)
# --------------------------
echo "Configuring account lockout..."
PAM_AUTH="/etc/pam.d/common-auth"
if ! grep -q "pam_tally2.so" "$PAM_AUTH"; then
    sed -i '/^auth\s\+required\s\+pam_unix.so/i auth required pam_tally2.so deny=5 unlock_time=900 even_deny_root onerr=fail' "$PAM_AUTH"
fi
echo "  Account lockout: OK"

# --------------------------
# 3. SSH Hardening
# --------------------------
echo "Hardening SSH..."
SSHD_CONFIG="/etc/ssh/sshd_config"
[ ! -f "${SSHD_CONFIG}.bak" ] && cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"

# Apply secure defaults
grep -q "^PermitRootLogin no" "$SSHD_CONFIG" || sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG" || echo "PermitRootLogin no" >> "$SSHD_CONFIG"
grep -q "^PasswordAuthentication no" "$SSHD_CONFIG" || sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG" || echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
grep -q "^X11Forwarding no" "$SSHD_CONFIG" || sed -i 's/^X11Forwarding.*/X11Forwarding no/' "$SSHD_CONFIG" || echo "X11Forwarding no" >> "$SSHD_CONFIG"
grep -q "^MaxAuthTries 3" "$SSHD_CONFIG" || sed -i 's/^MaxAuthTries.*/MaxAuthTries 3/' "$SSHD_CONFIG" || echo "MaxAuthTries 3" >> "$SSHD_CONFIG"

systemctl reload sshd
echo "  SSH hardening: OK"

# --------------------------
# 4. Root Account Lockdown
# --------------------------
echo "Locking down root account..."
passwd -l root
echo "  Root account: LOCKED"

# --------------------------
# Completion
# --------------------------
echo "Identity hardening applied successfully."
exit 0
