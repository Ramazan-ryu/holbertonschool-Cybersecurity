#!/bin/bash
#
grep -m1 "^nameserver" /etc/resolv.conf | cut -d " " -f2
