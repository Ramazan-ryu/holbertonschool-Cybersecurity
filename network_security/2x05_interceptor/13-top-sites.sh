#!/bin/bash
# Task 13: List top 10 most visited domains from Squid logs (no awk)

LOG_FILE="/var/log/squid/access.log"

if [[ ! -f $LOG_FILE ]]; then
    echo "Squid log file not found: $LOG_FILE"
    exit 1
fi

# Extract the 10th field (URL), get domain, count occurrences
grep "http" "$LOG_FILE" | cut -d' ' -f10 | \
sed -E 's#^https?://([^/]+)/?.*#\1#' | \
sort | uniq -c | sort -nr | head -n 10
