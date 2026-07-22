#!/bin/bash
nmap -Pn -O -p 22,80,9999 -T3 10.10.10.10
