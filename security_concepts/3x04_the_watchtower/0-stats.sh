#!/usr/bin/env bash

echo "File: /var/log/auth.log - Lines: $(wc -l < /var/log/auth.log 2>/dev/null || echo 0)"
echo "File: /var/log/syslog - Lines: $(wc -l < /var/log/syslog 2>/dev/null || echo 0)"
echo "File: /var/log/kern.log - Lines: $(wc -l < /var/log/kern.log 2>/dev/null || echo 0)"
