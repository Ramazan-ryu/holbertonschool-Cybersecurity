#!/bin/bash

# System Hardening Script
# Goal: Establish a secure baseline configuration

echo "Starting system hardening..."

########################################
# 1. Secure SSH Configuration
########################################

echo "Hardening SSH..."

# Disable root login
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Disable password authentication
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart ssh 2>/dev/null || systemctl restart sshd

########################################
# 2. Enable Firewall
########################################

echo "Enabling firewall..."

# Install ufw if missing
apt-get update -y
apt-get install -y ufw

# Default firewall rules
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
ufw allow ssh

# Enable firewall
ufw --force enable

########################################
# 3. Password Policy
########################################

echo "Setting password policy..."

# Set password expiration
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

########################################
# 4. File Permissions
########################################

echo "Fixing critical file permissions..."

chmod 600 /etc/shadow
chmod 644 /etc/passwd

########################################
# 5. Disable Unnecessary Services
########################################

echo "Disabling unused services..."

systemctl disable telnet 2>/dev/null
systemctl disable ftp 2>/dev/null
systemctl disable rsh 2>/dev/null

########################################
# 6. Enable Logging
########################################

echo "Ensuring logging service is running..."

systemctl enable rsyslog
systemctl start rsyslog

########################################
# 7. Remove World-Writable Files
########################################

echo "Removing world-writable permissions..."

find / -xdev -type d -perm -0002 -exec chmod o-w {} \; 2>/dev/null

########################################
# 8. Set Strong Default umask
########################################

echo "Setting secure umask..."

echo "umask 027" >> /etc/profile

########################################
# 9. Lock Inactive Accounts
########################################

echo "Locking inactive accounts..."

useradd -D -f 30

########################################
# 10. Update System Packages
########################################

echo "Updating system..."

apt-get upgrade -y

echo "System hardening completed."
