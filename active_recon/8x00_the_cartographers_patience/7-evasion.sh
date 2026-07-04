#!/bin/bash
nmap -Pn -sV -p 3306 -f -g 53 -T3 10.10.10.10
