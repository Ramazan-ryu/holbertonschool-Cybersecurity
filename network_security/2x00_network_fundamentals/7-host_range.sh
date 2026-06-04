#!/bin/bash
IFS=. read -r i1 i2 i3 i4 <<< "$1"; cid=$2; net=$(((i1<<24|i2<<16|i3<<8|i4) & (0xFFFFFFFF << (32-cid)))); first=$((net+1)); last=$(((net | (0xFFFFFFFF >> cid))-1)) && printf "%d.%d.%d.%d - %d.%d.%d.%d" $((first>>24&255)) $((first>>16&255)) $((first>>8&255)) $((first&255)) $((last>>24&255)) $((last>>16&255)) $((last>>8&255)) $((last&255))
