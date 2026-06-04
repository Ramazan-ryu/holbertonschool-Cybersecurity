#!/bin/bash
# Enable IP forwarding for VPN routing
# Turn on IP forwarding right now
sudo sysctl -w net.ipv4.ip_forward=1
# Make it permanent after reboot
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
