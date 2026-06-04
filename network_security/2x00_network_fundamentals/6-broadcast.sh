#!/bin/bash
IFS=. read -r i1 i2 i3 i4 <<< "$1"; IFS=. read -r m1 m2 m3 m4 <<< "$2" && printf "%d.%d.%d.%d" $((i1|(~m1&255))) $((i2|(~m2&255))) $((i3|(~m3&255))) $((i4|(~m4&255)))
