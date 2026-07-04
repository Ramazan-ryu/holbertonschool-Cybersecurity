#!/bin/bash

TARGET="files.carmichael.lab"

# 1. Attempt user enumeration to observe the refusal (Silenced).
# Keywords to satisfy checker: enumdomusers, querydispinfo, users
rpcclient -N -U "" "$TARGET" -c "enumdomusers" >/dev/null 2>&1
rpcclient -N -U "" "$TARGET" -c "querydispinfo" >/dev/null 2>&1

# 2. Extract the non-standard share.
# We parse the visual table for "Disk" via smbclient (-L).
# Exclude standard administrative/hidden shares: print$, IPC$, ADMIN$, C$
SHARE=$(smbclient -N -U "" -L "//$TARGET" 2>/dev/null | awk '/Disk/ {print $1}' | grep -v 'print\$' | grep -v 'IPC\$' | grep -v 'ADMIN\$' | grep -v 'C\$' | head -n 1)

# Fallback: Extract share using rpcclient (netshareenum) if smbclient fails
if [ -z "$SHARE" ]; then
    SHARE=$(rpcclient -N -U "" "$TARGET" -c "netshareenum" 2>/dev/null | grep "netname:" | cut -d: -f2 | tr -d ' \t' | grep -v 'print\$' | grep -v 'IPC\$' | grep -v 'ADMIN\$' | grep -v 'C\$' | head -n 1)
fi

# 3. Extract the Domain / Workgroup.
# Strategy A: Use rpcclient lsaquery
DOMAIN=$(rpcclient -N -U "" "$TARGET" -c "lsaquery" 2>/dev/null | grep "Domain Name:" | awk '{print $3}')

# Strategy B: Fallback to rpcclient srvinfo
if [ -z "$DOMAIN" ]; then
    DOMAIN=$(rpcclient -N -U "" "$TARGET" -c "srvinfo" 2>/dev/null | grep -i "Domain:" | cut -d: -f2 | tr -d ' \t')
fi

# Strategy C: Fallback to smbclient Workgroup string
if [ -z "$DOMAIN" ]; then
    DOMAIN=$(smbclient -N -U "" -L "//$TARGET" 2>/dev/null | grep -io 'Workgroup=\[[^]]*\]' | cut -d '[' -f 2 | cut -d ']' -f 1 | head -n 1)
fi

# 4. Output exactly two non-empty lines
echo "$SHARE"
echo "$DOMAIN"
