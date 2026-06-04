#!/bin/bash
# Task 2: Allow proxy traffic through nftables. Add rule to accept TCP traffic on port 3128 from VPN subnet
sudo nft add rule inet filter input ip saddr 10.200.0.0/24 tcp dport 3128 accept
