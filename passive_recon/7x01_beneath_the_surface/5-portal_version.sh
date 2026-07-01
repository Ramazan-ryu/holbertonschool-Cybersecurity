#!/bin/bash
curl -s -I -m 10 portal.astralis-cloud.example | grep -i '^Server:' | awk '{print $2}' | sed 's/\r//g'
