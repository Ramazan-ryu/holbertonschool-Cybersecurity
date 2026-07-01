#!/bin/bash
timeout 120 nmap -sT -T2 --max-rate 100 -p 49152-65535 admin.astralis-cloud.example | grep 'open' | awk -F/ '{print $1}' | head -n 1
