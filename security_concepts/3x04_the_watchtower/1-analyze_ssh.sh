#!/usr/bin/env bash
# 1-analyze_ssh.sh
#
grep "Failed password" "$1" | grep -o "from [^ ]*" | cut -d' ' -f2 | sort | uniq -c | sort -nr
