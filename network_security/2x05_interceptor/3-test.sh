#!/bin/bash
# Task 3: Test Squid proxy
PROXY_IP="127.0.0.1"   # Replace with your proxy server IP if remote
# Test HTTP request through proxy
curl -x http://$PROXY_IP:3128 -o /dev/null -s -w "%{http_code}" http://example.com
