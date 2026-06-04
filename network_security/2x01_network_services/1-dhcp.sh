#!/bin/bash
#
grep dhcp-server-identifier /var/lib/dhcp/* | head -n1 | cut -d " " -f3
