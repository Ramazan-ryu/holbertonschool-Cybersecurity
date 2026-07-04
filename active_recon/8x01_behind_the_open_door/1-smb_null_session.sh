#!/bin/bash
#
# 1-smb_null_session.sh
# Layer 1 - Anonymous SMB null session enumeration against files.carmichael.lab
#
# Uses an empty (null) credential to pull what the server volunteers to
# an unauthenticated connection: share list, OS/workgroup/domain info.
# Also attempts user enumeration to observe (and log) the expected refusal.
#
# Output: exactly two non-empty lines
#   1) the non-standard share name (excluding print$, IPC$, ADMIN$, C$)
#   2) the domain / workgroup name

TARGET="files.carmichael.lab"

# --- 1. Attempt user enumeration to observe the refusal (silenced) ---------
# A null session is typically not allowed to enumerate domain users; this is
# expected to fail/refuse. We still run it (silently) so the attempt/refusal
# is exercised, and revisit defeating this refusal later.
rpcclient -N -U "" "$TARGET" -c "enumdomusers" >/dev/null 2>&1
rpcclient -N -U "" "$TARGET" -c "querydispinfo" >/dev/null 2>&1

# --- 2. Extract the non-standard share -------------------------------------
# Parse the share table from `smbclient -L` for "Disk" type shares, then
# drop the standard administrative/hidden shares.
SHARE=$(smbclient -N -U "" -L "//$TARGET" 2>/dev/null \
    | awk '/Disk/ {print $1}' \
    | grep -v '^print\$$' \
    | grep -v '^IPC\$$' \
    | grep -v '^ADMIN\$$' \
    | grep -v '^C\$$' \
    | head -n 1)

# Fallback: use rpcclient's netshareenum if smbclient gave nothing usable.
if [ -z "$SHARE" ]; then
    SHARE=$(rpcclient -N -U "" "$TARGET" -c "netshareenum" 2>/dev/null \
        | grep "netname:" \
        | cut -d: -f2 \
        | tr -d ' \t' \
        | grep -v '^print\$$' \
        | grep -v '^IPC\$$' \
        | grep -v '^ADMIN\$$' \
        | grep -v '^C\$$' \
        | head -n 1)
fi

# --- 3. Extract the Domain / Workgroup -------------------------------------
# Strategy A: rpcclient lsaquery -> "Domain Name: CARMICHAEL"
DOMAIN=$(rpcclient -N -U "" "$TARGET" -c "lsaquery" 2>/dev/null \
    | grep "Domain Name:" \
    | awk -F': ' '{print $2}' \
    | tr -d ' \t')

# Strategy B: rpcclient srvinfo -> "... domain:[CARMICHAEL]" style output
if [ -z "$DOMAIN" ]; then
    DOMAIN=$(rpcclient -N -U "" "$TARGET" -c "srvinfo" 2>/dev/null \
        | grep -i "domain" \
        | grep -io '\[[^]]*\]' \
        | tr -d '[]' \
        | head -n 1)
fi

# Strategy C: smbclient -L Workgroup=[CARMICHAEL] string
if [ -z "$DOMAIN" ]; then
    DOMAIN=$(smbclient -N -U "" -L "//$TARGET" 2>/dev/null \
        | grep -io 'Workgroup=\[[^]]*\]' \
        | sed -E 's/.*\[([^]]*)\].*/\1/' \
        | head -n 1)
fi

# --- 4. Output exactly two non-empty lines ---------------------------------
echo "$SHARE"
echo "$DOMAIN"
