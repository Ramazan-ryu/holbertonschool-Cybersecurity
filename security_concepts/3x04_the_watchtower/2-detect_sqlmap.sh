#!/usr/bin/env bash
# 2-detect_sqlmap.sh

grep "sqlmap" "$1" | cut -d' ' -f1,6-7 | cut -d'"' -f1,2 | tr ' ' ',' 
