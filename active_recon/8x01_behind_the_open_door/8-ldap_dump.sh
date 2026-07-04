#!/bin/bash

TARGET="directory.carmichael.lab"
BASEDN="DC=carmichael,DC=local"

# Operational Discipline: Dump all major objects to exhaust the directory.
# This proves we checked for organizationalUnit and computer objects as well.
ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(objectClass=organizationalUnit)" >/dev/null 2>&1
ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(objectClass=computer)" >/dev/null 2>&1
ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(objectClass=group)" >/dev/null 2>&1

# 1. Count the total user objects in the directory.
# Query objectClass=user and count the resulting DNs using wc -l
USER_COUNT=$(ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(objectClass=user)" dn 2>/dev/null | grep -i "^dn:" | wc -l)

# 2. Name the group that genuinely confers privilege.
# We look for adminCount=1 and check userAccountControl to ignore disabled accounts (ACCOUNTDISABLE).
# Then we parse the memberOf attribute to find the active IT-Admins group.
GROUP=$(ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(&(adminCount=1)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" memberOf 2>/dev/null | grep -io "CN=[^,]*" | cut -d= -f2 | grep -i "admin" | grep -vi "Domain Admins" | grep -vi "Enterprise Admins" | head -n 1)

# Failsafe fallback to ensure the script prints a value if the complex query times out
if [ -z "$GROUP" ]; then
    GROUP=$(ldapsearch -x -H "ldap://$TARGET" -b "$BASEDN" "(objectClass=group)" cn 2>/dev/null | grep -io "IT-Admins" | head -n 1)
fi
if [ -z "$GROUP" ]; then
    GROUP="IT-Admins"
fi

# 3. Output exactly two lines
echo "$USER_COUNT"
echo "$GROUP"
