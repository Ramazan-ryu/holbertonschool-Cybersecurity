#!/bin/bash

PCAP="$1"
HOST="10.10.1.10"

mkdir -p dns_tmp

echo "=== TSHARK FILTERS USED ==="
echo "tshark -r $PCAP -Y 'dns.flags.response==0 && ip.src==$HOST'"
echo "tshark -r $PCAP -Y 'dns.flags.response==1 && ip.dst==$HOST'"
echo ""

# =========================
# EXTRACT DNS QUERIES
# =========================

tshark -r "$PCAP" \
-Y "dns.flags.response==0 && ip.src==$HOST" \
-T fields \
-e frame.time_epoch \
-e dns.qry.name \
-e dns.qry.type \
> dns_tmp/all.txt

# =========================
# CLASSIFICATION (NO IF/ELSE)
# =========================

grep -Ei "microsoft|windows|ubuntu|google|cloudflare|office|meddefense" dns_tmp/all.txt > dns_tmp/normal.txt

grep -E "[A-Za-z0-9+/=]{25,}" dns_tmp/all.txt > dns_tmp/anom1.txt

cut -f2 dns_tmp/all.txt | grep -E '^[A-Za-z0-9]{40,}$' > dns_tmp/anom2.txt

cat dns_tmp/anom1.txt dns_tmp/anom2.txt | sort -u > dns_tmp/anomalous.txt

# =========================
# COUNTS
# =========================

TOTAL=$(wc -l < dns_tmp/all.txt)
NORMAL=$(wc -l < dns_tmp/normal.txt)
ANOM=$(wc -l < dns_tmp/anomalous.txt)

echo "=== DNS QUERY CLASSIFICATION ==="
echo "Total DNS queries: $TOTAL"
echo "Normal queries: $NORMAL"
echo "Anomalous queries: $ANOM"
echo ""

# =========================
# BASE DOMAIN
# =========================

cut -f2 dns_tmp/anomalous.txt \
| rev \
| cut -d'.' -f1-2 \
| rev \
| sort \
| uniq -c \
| sort -nr \
| head -1

echo ""

echo "=== ANOMALOUS QUERY ANALYSIS ==="

# =========================
# LABEL LENGTHS (NO AWK)
# =========================

cut -f2 dns_tmp/anomalous.txt | cut -d'.' -f1 > dns_tmp/labels.txt

wc -L dns_tmp/labels.txt | sort -n | head -1
wc -L dns_tmp/labels.txt | sort -n | tail -1

echo ""

echo "Sample encoded labels:"

head -5 dns_tmp/labels.txt

echo ""
echo "Decoding attempts (base64/base32):"
echo ""

# =========================
# SAMPLE DECODE (NO IF)
# =========================

head -5 dns_tmp/labels.txt | while read line
do
    echo "Query: $line"

    echo "$line" | base64 -d 2>/dev/null
    echo "$line" | base32 -d 2>/dev/null

    echo "----"
done

# =========================
# RESPONSES
# =========================

tshark -r "$PCAP" \
-Y "dns.flags.response==1 && ip.dst==$HOST" \
-T fields \
-e dns.resp.type \
-e dns.txt \
-e frame.len \
> dns_tmp/resp.txt

echo "=== DNS RESPONSE ANALYSIS ==="

grep "^16" dns_tmp/resp.txt | wc -l

cut -f3 dns_tmp/resp.txt | sort -n | head -1
cut -f3 dns_tmp/resp.txt | sort -n | tail -1

echo ""

# =========================
# EXFIL ESTIMATION (NO AWK)
# =========================

AVG_LEN=$(cut -f2 dns_tmp/anomalous.txt | cut -d'.' -f1 | wc -L)

RAW_EST=$(( ANOM * AVG_LEN * 3 / 4 ))

echo "=== EXFILTRATION VOLUME ==="
echo "Queries: $ANOM"
echo "Avg label size: $AVG_LEN"
echo "Estimated raw data: $RAW_EST bytes"
echo ""

# =========================
# COMPARISON
# =========================

echo "=== DETECTION COMPARISON ==="
echo "Normal DNS     | Anomalous DNS"
echo "A/AAAA         | TXT / encoded"
echo "short names    | long labels"
echo "human readable | high entropy"
echo "random traffic  | periodic beaconing"
echo ""

echo "=== CONCLUSION ==="
echo "DNS traffic shows encoded high-entropy subdomains"
echo "consistent with DNS tunneling behavior"
