#!/bin/bash
dig "$1" SOA +short | cut -d ' ' -f1
