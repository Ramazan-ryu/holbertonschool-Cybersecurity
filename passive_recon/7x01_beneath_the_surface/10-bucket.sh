#!/bin/bash
for b in astralis astralis-cloud astralis-assets astralis-prod astralis-dev astralis-backup astralis-public astralis-static; do code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "https://${b}.s3.amazonaws.com"); if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ] || [ "$code" = "403" ]; then echo "$b"; exit 0; fi; done
