#!/bin/bash
dig +trace "$1" | grep -E '^\.' -A1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1
