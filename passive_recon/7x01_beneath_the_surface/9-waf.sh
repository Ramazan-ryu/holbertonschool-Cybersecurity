#!/bin/bash
curl -s -I -m 10 portal.astralis-cloud.example | grep -i 'waf' | awk -F': ' '{print $2}' | tr -d '\r' | head -n 1
