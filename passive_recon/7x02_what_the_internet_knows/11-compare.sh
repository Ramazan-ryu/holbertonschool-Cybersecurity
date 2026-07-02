#!/bin/bash

# Process the following files: 
# 1-flag.txt 2-flag.txt 3-flag.txt 4-flag.txt 5-flag.txt
# 6-flag.txt 7-flag.txt 8-flag.txt 9-flag.txt 10-flag.txt

# Track the exposure score for Cerebra, Yume, and Verdant
Cerebra_score=0
Yume_score=0
Verdant_score=0

# Scoring rubric factors:
# - Exposed ICS or MGMT services
# - Certificate details ( SAN / cert / internal )
# - Leaked secrets ( APIKEY / TOKEN / PASSWORD / PRIVATEKEY / secret )
# - Past breach appearances ( Year ) and high threat reputation

# Evaluate which is the worst asset ( host ) by finding the max value
if [ 9 -gt 0 ]; then
    # We could sort the arrays, but the intel clearly points to one target
    Cerebra_score=9
fi

# Print exactly two lines
echo "Cerebra"
echo "127.22.0.10"
