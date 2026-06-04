#!/bin/bash

echo "Starting system hardening..."

# update system
apt update -y

# remove unnecessary services
apt remove -y telnet

# SSH configuration
echo "Hardening SSH..."

sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

# restart SSH
systemctl restart ssh

echo "System hardening finished."
