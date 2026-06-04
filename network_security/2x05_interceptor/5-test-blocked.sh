#!/bin/bash
# Task: Test domain blocking through Squid proxy

PROXY_IP="127.0.0.1"           # Squid proxy IP
PROXY_PORT="3128"               # Squid proxy port
BLOCKED_DOMAIN="http://malware.com"  # Example blocked domain

# Attempt to access the blocked domain and print HTTP status code (expect 403)
curl -x http://$PROXY_IP:$PROXY_PORT -o /dev/null -s -w "%{http_code}\n" $BLOCKED_DOMAIN
