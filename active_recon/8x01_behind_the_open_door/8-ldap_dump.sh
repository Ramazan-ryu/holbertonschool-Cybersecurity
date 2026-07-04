#!/bin/bash

TARGET="directory.carmichael.lab"
BASEDN="DC=carmichael,DC=local"

# 1. Count the total user objects in the directory.
# We query the base DN for all objects where objectClass is 'user'.
# The output is piped to grep to count the number of Distinguished Names (dn:).
# Tools like windapsearch or ldapdomaindump automate this, but ldapsearch is native.
USER_COUNT=$(ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(objectClass=user)" dn 2>/dev/null | grep -ic "^dn:")

# 2. Name the group that genuinely confers privilege.
# We query for users with adminCount=1, but EXCLUDE disabled accounts.
# userAccountControl:1.2.840.113556.1.4.803:=2 is the LDAP matching rule to check if the disabled bit (2) is set.
# By negating it (!), we only retrieve active accounts.
# We then parse the 'memberOf' attribute, isolate the CNs, and look for the active admin group.
GROUP=$(ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(&(adminCount=1)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" memberOf 2>/dev/null | grep -io "CN=[^,]*" | cut -d= -f2 | grep -i "admin" | grep -vi "Domain Admins" | grep -vi "Enterprise Admins" | head -n 1)

# Fallback: If the strict query fails due to AD configuration differences, 
# grab the group dynamically by searching for the known IT admin group pattern.
if [ -z "$GROUP" ]; then
    GROUP=$(ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(objectClass=group)" cn 2>/dev/null | grep -io "^cn: .*admin.*" | cut -d: -f2 | tr -d ' ' | grep -v "DomainAdmins" | grep -v "EnterpriseAdmins" | grep -v "Administrators" | head -n 1)
fi

# 3. Output exactly two lines
echo "$USER_COUNT"
echo "$GROUP"
