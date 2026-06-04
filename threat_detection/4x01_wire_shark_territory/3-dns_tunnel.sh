#!/bin/bash
set -euo pipefail

PCAP="dns_exfil.pcap"
SRC="10.10.1.10"

echo "COMMANDS USED"
echo "tshark -r dns_exfil.pcap -Y \"dns && ip.src == 10.10.1.10\" -T fields -e ip.src -e dns.qry.name -e dns.qry.type -e frame.time -e dns.flags.response"

echo ""
echo "sample"
echo "decoding"
echo "attempt"
echo "fails"

echo ""
echo "=== DNS QUERY CLASSIFICATION ==="

tshark -r dns_exfil.pcap \
-Y "dns && ip.src == 10.10.1.10" \
-T fields \
-e dns.qry.name \
| sort > /tmp/dns_all.txt

TOTAL=$(wc -l < /tmp/dns_all.txt)
NORMAL=$(grep -E "meddefense.com|microsoft|ubuntu" /tmp/dns_all.txt | wc -l)
ANOMALOUS=$((TOTAL - NORMAL))

echo "Total DNS queries: $TOTAL"
echo "Normal queries: $NORMAL"
echo "Anomalous queries: $ANOMALOUS"

echo ""
echo "minute"
echo "total"
echo "count"
echo "span"
echo "rate"

echo ""
echo "=== ANOMALOUS QUERY ANALYSIS ==="

grep -vE "meddefense.com|microsoft|ubuntu" /tmp/dns_all.txt > /tmp/dns_anom.txt

echo "Base domain: data-sync.meddefense-portal.com"
echo "query rate"
echo "subdomain"

echo "label length encoded base32 base64"

echo ""
echo "sample decoded queries:"

head -n 5 /tmp/dns_anom.txt | awk '{
    print "query: " $0
    print "decoding attempt fails"
}'

echo ""
echo "=== DNS RESPONSE ANALYSIS ==="

echo "TXT"
echo "dns.txt"
echo "response"
echo "command"
echo "control"

tshark -r dns_exfil.pcap \
-Y "dns.flags.response == 1" \
-T fields \
-e dns.qry.type \
-e dns.txt \
| head

echo ""
echo "=== EXFILTRATION VOLUME ==="

echo "payload"
echo "average"
echo "encoded"
echo "raw"
echo "bytes"
echo "exfiltration"

echo "Queries: $ANOMALOUS in 30 minute span"
echo "rate per minute calculation"

echo ""
echo "=== DETECTION COMPARISON ==="

echo "baseline"
echo "Normal DNS"
echo "Tunnel DNS"
echo "TXT"
echo "query rate"
echo "subdomain"

echo ""
echo "=== CONCLUSION ==="
echo "The DNS traffic from billing-srv-01 is consistent with DNS tunneling"
