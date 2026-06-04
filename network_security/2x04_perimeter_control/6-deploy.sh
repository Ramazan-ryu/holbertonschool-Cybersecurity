#!/bin/bash
# 6-deploy.sh
# Usage: ./6-deploy.sh user@host /path/to/skeleton.conf

TARGET="$1"
CONFIG="$2"

# Copy firewall config to the target
scp "$CONFIG" "$TARGET:/tmp/skeleton.conf"

# Run panic script on target (auto reset in 5 minutes)
ssh "$TARGET" "sudo /path/to/2-panic.sh"

# Apply the firewall configuration
ssh "$TARGET" "sudo nft -f /tmp/skeleton.conf"

# Show active rules to verify
ssh "$TARGET" "sudo nft list ruleset"
