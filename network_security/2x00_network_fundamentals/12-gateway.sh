#!/bin/bash
gw=$(ip route | awk '/^default/ {print $3; exit}') && echo $gw
