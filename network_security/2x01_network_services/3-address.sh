#!/bin/bash
dig +short "$1" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1
