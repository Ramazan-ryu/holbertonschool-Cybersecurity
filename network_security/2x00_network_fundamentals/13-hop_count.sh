#!/bin/bash
tracepath "$1" 2>/dev/null | tail -n1 | awk '{print $1}'
