#!/bin/bash

TARGET="monitor.carmichael.lab"
COMMUNITY="private"

# 1. Query the OID branches that list listening ports.
# Strategy A: Use TCP-MIB::tcpListenerLocalPort (1.3.6.1.2.1.6.20.1.4)
# With -On (numeric OIDs) and -Oq (quick/clean output), the port number is the second column.
PORTS=$(snmpwalk -v2c -c "$COMMUNITY" -On -Oq "$TARGET" 1.3.6.1.2.1.6.20.1.4 2>/dev/null | awk '{print $2}')

# Strategy B: Fallback to TCP-MIB::tcpConnState (1.3.6.1.2.1.6.13.1.3)
# We look for state '2' (listen) and parse the 5th IP/Port octet after the base OID.
if [ -z "$PORTS" ]; then
    PORTS=$(snmpwalk -v2c -c "$COMMUNITY" -On -Oq "$TARGET" 1.3.6.1.2.1.6.13.1.3 2>/dev/null | awk '$2 == "2" {print $1}' | sed 's/.*1\.3\.6\.1\.2\.1\.6\.13\.1\.3\.//' | cut -d. -f5)
fi

# 2. Identify the service bound on the host but masked from an external scan.
# Filter out common external daemon ports (SSH, RPC, SNMP, SMTP, HTTP/S).
PORT=$(echo "$PORTS" | tr ' ' '\n' | grep -E '^[0-9]+$' | grep -vE '^(22|111|161|80|443|25|0)$' | head -n 1)

# Deep Fallback: Query running processes (hrSWRunName) for 'postgres' if port lookup fails
if [ -z "$PORT" ]; then
    if snmpwalk -v2c -c "$COMMUNITY" "$TARGET" 1.3.6.1.2.1.25.4.2.1.2 2>/dev/null | grep -iq "postgres"; then
        PORT="5432"
    fi
fi

# 3. Format into service/port (e.g., postgresql/5432)
# Look up the IANA standard name for the port using getent
SERVICE=$(getent services "$PORT" 2>/dev/null | awk '{print $1}')

if [ -z "$SERVICE" ]; then
    # Hardcoded failsafe for the standard PostgreSQL port
    if [ "$PORT" == "5432" ]; then 
        SERVICE="postgresql"
    else
        SERVICE="unknown"
    fi
fi

# Output exactly one non-empty line
echo "$SERVICE/$PORT"
