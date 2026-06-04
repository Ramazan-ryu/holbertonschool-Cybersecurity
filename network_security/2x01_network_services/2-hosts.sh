#!/bin/bash
#
grep localhost /etc/hosts | head -n1 | cut -f1|tr -d '\n'
