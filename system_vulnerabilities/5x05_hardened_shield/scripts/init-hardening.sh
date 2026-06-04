#!/bin/bash
# System Hardening Script
# Applies kernel parameters, filesystem protections,
# service minimization, SUID/SGID audit, and legal banner
# Idempotent script with proper exit codes

set -e

echo "=== System Hardening Started ==="

########################################
# Kernel Hardening (sysctl)
########################################

SYSCTL_FILE="/etc/sysctl.conf"

apply_sysctl() {
    PARAM="$1"

    if ! grep -q "^$PARAM" "$SYSCTL_FILE"; then
        echo "$PARAM" >> "$SYSCTL_FILE"
    fi
}

# Network security
apply_sysctl "net.ipv4.ip_forward=0"
apply_sysctl "net.ipv4.conf.all.accept_redirects=0"
apply_sysctl "net.ipv4.conf.default.accept_redirects=0"
apply_sysctl "net.ipv4.conf.all.accept_source_route=0"
apply_sysctl "net.ipv4.conf.default.accept_source_route=0"

# ICMP protections
apply_sysctl "net.ipv4.icmp_echo_ignore_broadcasts=1"
apply_sysctl "net.ipv4.icmp_ignore_bogus_error_responses=1"

# SYN flood protection
apply_sysctl "net.ipv4.tcp_syncookies=1"

# IPv6 disable (security hardening)
apply_sysctl "net.ipv6.conf.all.disable_ipv6=1"
apply_sysctl "net.ipv6.conf.default.disable_ipv6=1"

# Kernel protections
apply_sysctl "kernel.randomize_va_space=2"
apply_sysctl "kernel.kptr_restrict=2"

sysctl -p > /dev/null 2>&1

echo "Kernel parameters applied"

########################################
# Filesystem Security
########################################

chmod 600 /etc/shadow
chmod 644 /etc/passwd
chmod 700 /root

chmod 1777 /tmp
chmod 1777 /var/tmp

echo "Filesystem permissions secured"

########################################
# Service Minimization
########################################

SERVICES="cups avahi-daemon"

for SERVICE in $SERVICES; do
    if systemctl list-unit-files | grep -q "$SERVICE"; then
        systemctl stop "$SERVICE" 2>/dev/null || true
        systemctl disable "$SERVICE" 2>/dev/null || true
    fi
done

echo "Unnecessary services minimized"

########################################
# SUID / SGID Audit
########################################

LOG_FILE="/var/log/suid_sgid_audit.log"

echo "SUID/SGID Audit - $(date)" > "$LOG_FILE"

find / -xdev -type f \( -perm -4000 -o -perm -2000 \) \
    -exec ls -l {} \; >> "$LOG_FILE" 2>/dev/null

# Remove dangerous SUID bits if present
chmod 0755 /usr/bin/ftp 2>/dev/null || true
chmod 0755 /usr/bin/ping 2>/dev/null || true

echo "SUID/SGID audit completed"

########################################
# Legal Banner
########################################

BANNER="Authorized use only. All activity may be monitored and reported."

if ! grep -q "Authorized use only" /etc/issue 2>/dev/null; then
    echo "$BANNER" > /etc/issue
fi

if ! grep -q "Authorized use only" /etc/motd 2>/dev/null; then
    echo "$BANNER" > /etc/motd
fi

echo "Legal banner configured"

########################################
# Exit
########################################

echo "=== System Hardening Completed ==="

exit 0
