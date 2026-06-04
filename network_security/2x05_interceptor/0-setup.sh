#!/bin/bash
# Task 0: Install Squid and backup configuration

# Install squid package
sudo apt install -y squid

# Enable Squid service to start at boot
sudo systemctl enable squid

# Backup original configuration
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
