#!/bin/bash

# 0-manual_hunt.sh

LOG_DIR="$HOME/evidence_pack_primary/linux"

echo "========== FAILED AUTH =========="
echo

grep -RiE "failed|authentication failure|invalid user" "$LOG_DIR" 2>/dev/null

echo
echo "========== SOURCE IP =========="
echo

grep -RhoE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$LOG_DIR" 2>/dev/null | \
sort | uniq -c | sort -nr

echo
echo "========== SUSPECT =========="
echo

echo "Primary suspect IP: 10.10.3.47"
