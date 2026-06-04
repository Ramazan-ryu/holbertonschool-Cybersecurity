#!/bin/bash
# Generate WireGuard keypairs for server and client

# Server keys
wg genkey | tee server_private | wg pubkey > server_public

# Client keys
wg genkey | tee client_private | wg pubkey > client_public
