#!/bin/bash
apt update
apt install -y nftables wireguard wireguard-tools
systemctl enable nftables
