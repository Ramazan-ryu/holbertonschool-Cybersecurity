#!/bin/bash
nmap -Pn -sA -p 22,80,443,445,3389 -T3 10.10.10.10
