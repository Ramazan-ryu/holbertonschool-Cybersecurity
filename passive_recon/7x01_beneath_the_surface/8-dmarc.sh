#!/bin/bash
dig +short TXT _dmarc.astralis-cloud.example | grep -Eo 'p=(none|quarantine|reject)' | cut -d '=' -f 2 | head -n 1
