#!/bin/bash
# Task 14: Validate and reload Squid without loops or conditionals

SQUID_CONF="/home/ryu/holbertonschool-Cybersecurity/network_security/2x05_interceptor/squid.conf"

# Parse config and reload if valid; otherwise print error
sudo squid -k parse -f "$SQUID_CONF" && sudo squid -k reconfigure && echo "Squid reloaded successfully." || echo "Invalid configuration. Fix errors first."
