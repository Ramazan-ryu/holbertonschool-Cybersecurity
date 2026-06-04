#!/bin/bash
dig -x "$1" +short | head -n1
