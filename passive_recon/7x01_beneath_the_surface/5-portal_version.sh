#!/bin/bash
curl -s -I -m 10 portal.astralis-cloud.example | grep -i '^Server:' | head -n 1 | awk '{print $2}' | tr -d '\r'
