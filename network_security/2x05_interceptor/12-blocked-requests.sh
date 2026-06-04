#!/bin/bash
# Extract 403 blocked requests from Squid access.log

LOG_FILE="/var/log/squid/access.log"

# Ensure the log file exists
[ ! -f "$LOG_FILE" ] && { echo "Log file not found: $LOG_FILE"; exit 1; }

# Parse the log: timestamp, client IP, URL for 403 responses
awk '$4 ~ /403/ {print $1, $3, $7}' "$LOG_FILE"
