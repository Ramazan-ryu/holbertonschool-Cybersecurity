#!/bin/bash
for b in astralis astralis-cloud astralis-assets astralis-prod astralis-dev astralis-backup astralis-public astralis-static; do code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "https://${b}.s3.amazonaws.com"); if echo "$code" | grep -qE '^(2|3|403)'; then echo "$b"; break; fi; done
