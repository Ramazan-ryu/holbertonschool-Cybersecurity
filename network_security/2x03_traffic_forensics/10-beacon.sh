#!/bin/bash
#
tshark -r "$1" -Y "ip.addr == $2 || ip.addr == $3" -T fields -e frame.time
