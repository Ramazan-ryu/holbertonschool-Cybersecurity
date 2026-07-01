#!/bin/bash
gobuster dns --domain astralis-cloud.example -w /usr/share/wordlists/astralis-subdomains.txt -t 5 -q | grep -E 'internal|backend|admin' | grep -oE '[a-zA-Z0-9.-]+\.astralis-cloud\.example' | head -n 1
