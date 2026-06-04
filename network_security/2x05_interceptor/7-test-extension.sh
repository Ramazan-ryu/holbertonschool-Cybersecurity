#!/bin/bash
# Task 7: Test file type blocking through Squid

PROXY_IP="127.0.0.1"  # Replace with your proxy server IP if remote
TEST_FILE="http://example.com/test.exe"

# Expected HTTP response code: 403
EXPECTED_CODE=403

# Attempt to download blocked file type and display the HTTP status
curl -x http://$PROXY_IP:3128 -o /dev/null -s -w "%{http_code}\n" $TEST_FILE
