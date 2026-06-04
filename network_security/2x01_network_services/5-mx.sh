#!/bin/bash
dig +short MX  "$1" | head -n1
