#!/bin/bash
# Task 15: Force all HTTP/HTTPS traffic through Squid proxy using nftables

# VPN subnet
VPN_NET="10.200.0.0/24"

# Proxy IP and ports
PROXY_IP="127.0.0.1"
HTTP_PORT="3128"
HTTPS_PORT="3129"

# Define table and chain
TABLE="inet filter"
CHAIN="forward"

# Add rules to allow VPN clients to reach the proxy
sudo nft add rule $TABLE $CHAIN ip saddr $VPN_NET tcp dport $HTTP_PORT accept
sudo nft add rule $TABLE $CHAIN ip saddr $VPN_NET tcp dport $HTTPS_PORT accept

# Block direct HTTP (80) and HTTPS (443) from VPN clients
sudo nft add rule $TABLE $CHAIN ip saddr $VPN_NET tcp dport 80 drop
sudo nft add rule $TABLE $CHAIN ip saddr $VPN_NET tcp dport 443 drop

# Allow the proxy itself to make outbound connections (optional: from localhost)
sudo nft add rule $TABLE $CHAIN ip saddr 127.0.0.1 accept
