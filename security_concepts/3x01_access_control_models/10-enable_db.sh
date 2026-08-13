#!/bin/bash
# 10-enable_db.sh - Enable SELinux boolean for httpd to connect to remote databases
# Author: SecureHealth Security Team
# Date: 2026-04-02
# Purpose: Allow web server to initiate network connections to remote DB (Port 3306)

set -e

echo "[*] Identifying SELinux boolean for httpd database connection..."
# List relevant httpd booleans
semanage boolean -l | grep httpd | grep db

# The boolean to allow httpd network connections
SELINUX_BOOL="httpd_can_network_connect_db"

echo "[*] Enabling SELinux boolean: $SELINUX_BOOL persistently..."
# Enable the boolean permanently
setsebool -P $SELINUX_BOOL on

echo "[*] SELinux boolean $SELINUX_BOOL is now enabled."
