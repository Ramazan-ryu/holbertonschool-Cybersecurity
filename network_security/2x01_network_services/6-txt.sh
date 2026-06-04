#!/bin/bash
dig +short TXT "$1" | head -n1
