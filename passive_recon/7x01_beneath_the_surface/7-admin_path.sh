#!/bin/bash
curl -s -m 10 https://portal.astralis-cloud.example/robots.txt | grep -i '^Disallow:' | grep -E 'admin|manage|backend|console' | awk '{print $2}' | tr -d '\r' | head -n 1
