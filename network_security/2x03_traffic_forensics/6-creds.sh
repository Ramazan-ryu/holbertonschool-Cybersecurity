#!/bin/bash
#
tshark -r "$1" -T fields -e urlencoded-form.value | grep -Ei 'password|pass|pwd'
