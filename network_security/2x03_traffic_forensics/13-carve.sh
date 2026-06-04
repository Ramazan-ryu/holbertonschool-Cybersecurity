#!/bin/bash
#
tshark -r "$1" --export-objects http,files &&  md5sum files/* 2>/dev/null
