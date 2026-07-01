#!/bin/bash
wafw00f portal.astralis-cloud.example | grep -i 'is behind' | awk '{print $NF}' || curl -s -I -m 10 portal.astralis-cloud.example | grep -iE 'Server:|CF-RAY|X-Amz-Cf-Id|X-Served-By' | grep -vi 'nginx' | awk -F': ' '{print $2}' | tr -d '\r' | head -n 1
