#!/bin/bash

PASS=0
FAIL=0

check() {
    if [ "$1" -eq 0 ]; then
        echo "[PASS] $2"
        PASS=$((PASS+1))
    else
        echo "[FAIL] $2"
        FAIL=$((FAIL+1))
    fi
}

echo "Starting security validation..."

# --- FIREWALL ---
INPUT_POLICY=$(nft list chain inet filter input | grep -i "policy drop" || true)
check "[[ -n \"$INPUT_POLICY\" ]]" "Firewall default INPUT policy is DROP"

# Check required rules exist
nft list ruleset | grep -q "tcp dport 22" 
check $? "SSH rule exists"

nft list ruleset | grep -q "tcp dport 21"
check $? "FTP rule exists"

nft list ruleset | grep -q "udp dport 51820"
check $? "WireGuard VPN rule exists"

nft list ruleset | grep -q "tcp dport 3306"
check $? "Database rule exists"

# Check for unexpected ACCEPT rules
EXTRA_ACCEPT=$(nft list ruleset | grep -vE "22|21|51820|3306" | grep "accept" || true)
if [ -z "$EXTRA_ACCEPT" ]; then
    echo "[PASS] No unexpected ACCEPT rules"
    PASS=$((PASS+1))
else
    echo "[FAIL] Unexpected ACCEPT rules found"
    FAIL=$((FAIL+1))
fi

# --- SERVICE STATUS ---
systemctl is-active --quiet ssh
check $? "SSH service is running"

systemctl is-active --quiet wg-quick@wg0
check $? "VPN interface wg0 is UP"

# Example: check unnecessary service
systemctl is-active --quiet vsftpd
if systemctl is-active --quiet vsftpd; then
    echo "[FAIL] Expected service 'vsftpd' to be stopped"
    FAIL=$((FAIL+1))
else
    echo "[PASS] Unnecessary service 'vsftpd' is stopped"
    PASS=$((PASS+1))
fi

# --- ACCESS CONTROL ---
SSH_ROOT=$(grep -Ei "^PermitRootLogin\s+no" /etc/ssh/sshd_config)
check "[[ -n \"$SSH_ROOT\" ]]" "SSH root login disabled"

SSH_PASS=$(grep -Ei "^PasswordAuthentication\s+no" /etc/ssh/sshd_config)
check "[[ -n \"$SSH_PASS\" ]]" "SSH password authentication disabled"

# Sudo users
SUDOERS=$(grep -E "^admin" /etc/sudoers || true)
check "[[ -n \"$SUDOERS\" ]]" "Correct users have sudo access"

# --- NETWORK CONFIGURATION ---
IP_FORWARD=$(sysctl net.ipv4.ip_forward | grep -q "net.ipv4.ip_forward = 1")
check $? "IP forwarding enabled"

# Example: check interface IP
ip addr show wg0 | grep -q "10.0.0.1"
check $? "VPN interface wg0 has correct IP"

# Example: check default route exists
ip route | grep -q "default via"
check $? "Default route exists"

# --- RESULTS ---
TOTAL=$((PASS+FAIL))
echo "RESULT: $PASS/$TOTAL checks passed"
