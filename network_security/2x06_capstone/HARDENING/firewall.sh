#!/bin/bash

echo "Configuring firewall..."

# clear old rules
nft flush ruleset

# create table
nft add table inet filter

# create chains
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }

# allow localhost
nft add rule inet filter input iif lo accept

# allow established connections
nft add rule inet filter input ct state established,related accept

# allow SSH
nft add rule inet filter input tcp dport 22 accept

# allow FTP
nft add rule inet filter input tcp dport 21 accept

# allow VPN
nft add rule inet filter input udp dport 51820 accept

# allow database
nft add rule inet filter input tcp dport 3306 accept

echo "Firewall configured."
