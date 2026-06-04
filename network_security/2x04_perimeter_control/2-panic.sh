#!/bin/bash
nft flush ruleset

nft add table inet filter 2>/dev/null

nft add chain inet filter input { type filter hook input priority 0 \; policy accept \; } 2>/dev/null
nft add chain inet filter forward { type filter hook forward priority 0 \; policy accept \; } 2>/dev/null
nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; } 2>/dev/null


(sleep 300; "$0") &
