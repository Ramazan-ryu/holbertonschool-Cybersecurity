#!/bin/bash
dig +short SOA astralis-cloud.example | cut -d ' ' -f 1 | grep -o '.*[^.]'

dig +short SOA @10.42.82.57 | cut -d ' ' -f 1 | grep -o '.*[^.]'
