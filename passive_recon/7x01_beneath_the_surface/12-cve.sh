#!/bin/bash
version=$(curl -s -I -m 10 portal.astralis-cloud.example | grep -i 'Server:' | awk '{print $2}' | tr -d '\r') && curl -s -m 10 "http://cve.astralis-cloud.example/api?keyword=$version" | jq -r '.vulnerabilities | sort_by(.cve.metrics.cvssMetricV31[0].cvssData.baseScore) | last | .cve.id'
