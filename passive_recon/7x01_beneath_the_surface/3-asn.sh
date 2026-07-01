#!/bin/bash
ip=$(dig +short astralis-cloud.example | head -n 1) && echo "$ip" | timeout 10 nc whois.cymru.com 43 | awk 'NR==2 {print "AS"$1}'
