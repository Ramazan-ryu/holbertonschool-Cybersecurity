#!/bin/bash
mask=$(( 0xFFFFFFFF ^ ((1 << (32 - $1)) - 1))) && printf "%d.%d.%d.%d" $(( (mask>>24)&255 )) $(( (mask>>16)&255 )) $(( (mask>>8)&255 )) $(( mask&255 ))
