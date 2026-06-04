#!/bin/bash
dig +short CNAME "$1" | head -n1
