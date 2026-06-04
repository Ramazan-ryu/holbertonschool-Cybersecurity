#!/bin/bash
# Task 10: Test HTTPS domain blocking (SNI peek)

PROXY_IP="127.0.0.1"  # Replace with your proxy server IP if remote
PROXY_PORT="3129"      # HTTPS intercept port

BLOCKED_DOMAIN="https://malware.com"

# Attempt to access the blocked domain through the proxy
# -k ignores SSL certificate validation (since we use self-signed CA)
# -s silent, -o /dev/null discards output
curl -x http://$PROXY_IP:$PROXY_PORT -k -s -o /dev/null -w "%{http_code}" $BLOCKED_DOMAIN
echo
