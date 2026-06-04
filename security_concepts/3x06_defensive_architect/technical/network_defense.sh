#!/bin/bash
# network_defense.sh - SecureHealth network micro-segmentation (dynamic)
# Implements Default Deny, closes exposed DB port, restricts SSH
# Web Server and Bastion IPs are configurable via environment variables
# Author: SecureHealth Security Team
# Date: 2026-04-02

set -e

echo "[*] Starting network defense and micro-segmentation setup..."

# ------------------------------
# 0. Check required environment variables
# ------------------------------
: "${WEB_SERVER_PRIVATE_IP:?Need to set WEB_SERVER_PRIVATE_IP}"
: "${BASTION_PRIVATE_IP:?Need to set BASTION_PRIVATE_IP}"

echo "[*] Web Server IP: $WEB_SERVER_PRIVATE_IP"
echo "[*] Bastion Host IP: $BASTION_PRIVATE_IP"

# ------------------------------
# 1. Reset UFW to clean state
# ------------------------------
ufw --force reset

# ------------------------------
# 2. Set default deny policies
# ------------------------------
ufw default deny incoming
ufw default allow outgoing

# ------------------------------
# 3. Close DB port to public
# ------------------------------
ufw deny 5432

# ------------------------------
# 4. Allow DB access from Web Server private IP only
# ------------------------------
ufw allow from $WEB_SERVER_PRIVATE_IP to any port 5432 proto tcp

# ------------------------------
# 5. Restrict SSH to Bastion Host
# ------------------------------
ufw allow from $BASTION_PRIVATE_IP to any port 22 proto tcp

# ------------------------------
# 6. Enable UFW
# ------------------------------
ufw --force enable

echo "[*] Network micro-segmentation applied successfully."
