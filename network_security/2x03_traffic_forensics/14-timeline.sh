#!/bin/bash
tshark -r "$1" -Y "ip.addr == $2" -T fields -e frame.time | head -n1
tshark -r "$1" -Y "ip.addr == $2" -T fields -e frame.time | tail -n1
