#!/bin/bash

set -e

echo "[+] Installing Suricata IDS..."

# Update system and install Suricata
apt update -y
apt install -y suricata

# Determine WAN interface (replace eth0 if different)
WAN_IF=$(ip route | grep default | awk '{print $5}')
echo "[+] WAN interface detected: $WAN_IF"

# Backup default configuration
cp /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak

# Configure Suricata to monitor WAN interface
sed -i "s/^  - interface: eth0/  - interface: $WAN_IF/" /etc/suricata/suricata.yaml

echo "[+] Enabling rule sets for detection..."

# Use default rules from Suricata package
# Enable basic categories: portscan, ssh brute force, malware/outbound
suricata-update

# Optional: manually enable categories if needed
# sed -i 's/^# - categories: "trojan"/  - categories: "trojan"/' /etc/suricata/rules/*.yaml

echo "[+] Starting Suricata in service mode..."
systemctl enable suricata
systemctl start suricata

echo "[+] Suricata IDS setup complete."
echo "Logs: /var/log/suricata/fast.log"

echo "[+] Test it with nmap scans, SSH brute force attempts, or simulated attacks."
