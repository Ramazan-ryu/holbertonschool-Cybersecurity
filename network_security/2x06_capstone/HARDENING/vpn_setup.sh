#!/bin/bash

echo "Installing WireGuard..."

apt update
apt install -y wireguard

mkdir -p /etc/wireguard

echo "Generating keys..."

wg genkey > /etc/wireguard/privatekey
wg pubkey < /etc/wireguard/privatekey > /etc/wireguard/publickey

PRIVATE_KEY=$(cat /etc/wireguard/privatekey)

echo "Creating VPN configuration..."

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $PRIVATE_KEY
EOF

echo "Starting VPN..."

systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

echo "VPN setup finished."
