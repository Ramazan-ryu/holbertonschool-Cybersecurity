#!/bin/bash
ip addr show tun0 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -n1
