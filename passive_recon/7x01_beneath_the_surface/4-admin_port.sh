#!/bin/bash
timeout 120 nmap -sT -T2 -p 49152-65535 admin.astralis-cloud.example | grep -w 'open' | cut -d '/' -f 1 | head -n 1
