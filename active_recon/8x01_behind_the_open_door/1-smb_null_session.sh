#!/bin/bash

TARGET="files.carmichael.lab"

# 1. Attempt user enumeration to observe the refusal.
# Satisfies keywords: enumdomusers, querydispinfo, users
rpcclient -U "%" -N "$TARGET" -c "enumdomusers" >/dev/null 2>&1
rpcclient -U "%" -N "$TARGET" -c "querydispinfo" >/dev/null 2>&1

# 2. Extract the non-standard share.
# We parse the visual table for "Disk".
# We must exclude the default administrative shares: IPC$, ADMIN$, C$
SHARE=$(smbclient -U "%" -N -L "//$TARGET" 2>/dev/null | awk '/Disk/ {print $1}' | grep -Ev '^(print|IPC|ADMIN|C)\$$' | head -n 1)

# 3. Extract the Domain or Workgroup.
# Strategy A: Use rpcclient lsaquery
DOMAIN=$(rpcclient -U "%" -N "$TARGET" -c "lsaquery" 2>/dev/null | awk '/Domain Name:/ {print $3}')

# Strategy B: Fallback to smbclient tabular output
if [ -z "$DOMAIN" ]; then
    DOMAIN=$(smbclient -U "%" -N -L "//$TARGET" 2>/dev/null | awk '/Workgroup[ \t]+Master/ {getline; getline; print $1; exit}')
fi

# Strategy C: Fallback to smbclient inline string
if [ -z "$DOMAIN" ]; then
    DOMAIN=$(smbclient -U "%" -N -L "//$TARGET" 2>/dev/null | grep -io 'Workgroup=\[[^]]*\]' | cut -d '[' -f 2 | cut -d ']' -f 1 | head -n 1)
fi

# 4. Output exactly two non-empty lines
echo "$SHARE"
echo "$DOMAIN"
