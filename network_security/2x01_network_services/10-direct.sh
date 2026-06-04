#!/bin/bash
dig @$1 $2 A +short | head -n1
