#!/bin/bash
# 3-containment.sh
# Simple containment script: block IP and pause process

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <attacker_ip> <malicious_pid>"
    exit 1
fi

ATTACKER_IP=$1
MALICIOUS_PID=$2

# Block all traffic from attacker
echo "Blocking all traffic from/to $ATTACKER_IP..."
sudo iptables -A INPUT -s $ATTACKER_IP -j DROP
sudo iptables -A OUTPUT -d $ATTACKER_IP -j DROP

# Pause the malicious process
echo "Pausing process $MALICIOUS_PID..."
kill -STOP $MALICIOUS_PID

echo "Containment applied!"
