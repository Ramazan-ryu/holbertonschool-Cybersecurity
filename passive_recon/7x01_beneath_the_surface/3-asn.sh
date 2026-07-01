#!/bin/bash
ip=$(dig +short astralis-cloud.example | head -n 1) && curl -s -m 10 "https://api.bgpview.io/ip/$ip" | jq -r '.data.prefixes[0].asn.asn' | awk '{print "AS"$1}'
