#!/bin/bash
nmap -Pn -p 3306 -f -g 53 -T3 10.10.10.10
