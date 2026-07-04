#!/bin/bash
nmap -Pn -sV --version-all -p 22,80 -T3 10.10.10.10
