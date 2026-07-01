#!/bin/bash
timeout 10 openssl s_client -connect portal.astralis-cloud.example:443 -servername portal.astralis-cloud.example < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -Eo 'DNS:[a-zA-Z0-9.-]+' | cut -d ':' -f 2 | grep -E 'internal|backend|admin|mgmt' | head -n 1
