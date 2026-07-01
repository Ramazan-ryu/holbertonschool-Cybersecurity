#!/bin/bash
product="nginx"; version=$(curl -s -I -m 10 portal.astralis-cloud.example | grep -i 'Server:' | awk '{print $2}' | cut -d/ -f2 | tr -d '\r'); curl -s -m 10 "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${product}+${version}" | jq -r '.vulnerabilities | sort_by(.cve.metrics.cvssMetricV31[0].cvssData.baseScore) | last | .cve.id' | grep 'CVE' | head -n 1
