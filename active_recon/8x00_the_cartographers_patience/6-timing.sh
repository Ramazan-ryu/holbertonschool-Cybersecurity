#!/bin/bash
nmap -Pn -p 8443 -T3 --max-rate 1 10.10.10.20
