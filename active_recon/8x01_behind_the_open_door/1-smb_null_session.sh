#!/bin/bash

TARGET="files.carmichael.lab"

# 1. Extract the non-standard share
# We use the grepable output (-g) to reliably split fields.
# We then filter out standard hidden/administrative shares and take the first match.
smbclient -N -L "//$TARGET" -g 2>/dev/null | grep -i '^Disk|' | cut -d '|' -f 2 | grep -Ev '^(print\$|IPC\$|ADMIN\$|C\$)$' | head -n 1

# 2. Extract the domain name
# We capture standard smbclient output, which historically formats this in two possible ways depending on the target OS.
SMB_OUT=$(smbclient -N -L "//$TARGET" 2>/dev/null)

# Strategy A: Check for the inline connection info string (e.g., Workgroup=[CARMICHAEL])
DOMAIN=$(echo "$SMB_OUT" | grep -o 'Workgroup=\[[^]]*\]' | cut -d '[' -f 2 | cut -d ']' -f 1 | head -n 1)

# Strategy B: If empty, check for the older tabular workgroup listing
if [ -z "$DOMAIN" ]; then
    DOMAIN=$(echo "$SMB_OUT" | awk '/Workgroup[ \t]+Master/ {getline; getline; print $1; exit}')
fi

# Strategy C: If still empty, query it directly with rpcclient as a failsafe
if [ -z "$DOMAIN" ]; then
    DOMAIN=$(rpcclient -U "" -N "$TARGET" -c "lsaquery" 2>/dev/null | awk '/Domain Name:/ {print $3; exit}')
fi

echo "$DOMAIN"
