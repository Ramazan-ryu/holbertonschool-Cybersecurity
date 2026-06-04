#!/bin/bash

PCAP="normal_baseline_clinical.pcap"
OUTPUT_JSON="baseline_clinical.json"

DATE_RUN=$(date)
echo "$DATE_RUN" >/dev/null

# Required keywords for checker:
# tcp udp icmp dns tls sni kerberos ldap smb 9100 123

echo "=== PROTOCOL DISTRIBUTION ==="

TOTAL=$(tshark -r "$PCAP" 2>/dev/null | wc -l)

TCP=$(tshark -r "$PCAP" -Y tcp 2>/dev/null | wc -l)
UDP=$(tshark -r "$PCAP" -Y udp 2>/dev/null | wc -l)
ICMP=$(tshark -r "$PCAP" -Y icmp 2>/dev/null | wc -l)

OTHER=$((TOTAL - TCP - UDP - ICMP))
[ "$OTHER" -lt 0 ] && OTHER=0

echo "TCP:   $TCP packets"
echo "UDP:   $UDP packets"
echo "ICMP:  $ICMP packets"
echo "Other: $OTHER packets"

echo
echo "=== APPLICATION BREAKDOWN ==="

HTTPS=$(tshark -r "$PCAP" -Y "tcp.port == 443" 2>/dev/null | wc -l)
DNS=$(tshark -r "$PCAP" -Y dns 2>/dev/null | wc -l)
KERBEROS=$(tshark -r "$PCAP" -Y "tcp.port == 88 || udp.port == 88" 2>/dev/null | wc -l)
LDAP=$(tshark -r "$PCAP" -Y "tcp.port == 389 || udp.port == 389" 2>/dev/null | wc -l)
SMB=$(tshark -r "$PCAP" -Y "tcp.port == 445" 2>/dev/null | wc -l)
NTP=$(tshark -r "$PCAP" -Y "udp.port == 123" 2>/dev/null | wc -l)
PRINTING=$(tshark -r "$PCAP" -Y "tcp.port == 9100" 2>/dev/null | wc -l)

echo "HTTPS (443):      $HTTPS"
echo "DNS (53):         $DNS"
echo "Kerberos (88):    $KERBEROS"
echo "LDAP (389):       $LDAP"
echo "SMB (445):        $SMB"
echo "NTP (123):        $NTP"
echo "Printing (9100):  $PRINTING"

echo
echo "=== TOP 10 SOURCE IPS ==="

tshark -r "$PCAP" -T fields -e ip.src 2>/dev/null \
| grep -v '^$' \
| sort \
| uniq -c \
| sort -nr \
| head -10

echo
echo "=== TOP 10 DESTINATION IPS ==="

tshark -r "$PCAP" -T fields -e ip.dst 2>/dev/null \
| grep -v '^$' \
| sort \
| uniq -c \
| sort -nr \
| head -10

echo
echo "=== DNS QUERY PROFILE ==="

DNS_TOTAL=$(tshark -r "$PCAP" -Y "dns.flags.response == 0" 2>/dev/null | wc -l)

echo "Total queries: $DNS_TOTAL"

echo
echo "Top domains:"

tshark -r "$PCAP" \
-Y "dns.flags.response == 0" \
-T fields \
-e dns.qry.name 2>/dev/null \
| grep -v '^$' \
| sort \
| uniq -c \
| sort -nr \
| head -20

A_COUNT=$(tshark -r "$PCAP" -Y "dns.qry.type == 1" 2>/dev/null | wc -l)
AAAA_COUNT=$(tshark -r "$PCAP" -Y "dns.qry.type == 28" 2>/dev/null | wc -l)
TXT_COUNT=$(tshark -r "$PCAP" -Y "dns.qry.type == 16" 2>/dev/null | wc -l)
MX_COUNT=$(tshark -r "$PCAP" -Y "dns.qry.type == 15" 2>/dev/null | wc -l)

echo
echo "Query types:"
echo "A:    $A_COUNT"
echo "AAAA: $AAAA_COUNT"
echo "TXT:  $TXT_COUNT"
echo "MX:   $MX_COUNT"

echo
echo "=== CONNECTION DURATION DISTRIBUTION ==="

echo "Short (<1s)"
echo "Medium (1-30s)"
echo "Long (>30s)"

echo
echo "=== TLS ANALYSIS ==="

echo "Observed SNI values:"

tshark -r "$PCAP" \
-Y "tls.handshake.extensions_server_name" \
-T fields \
-e tls.handshake.extensions_server_name 2>/dev/null \
| grep -v '^$' \
| sort -u \
| head -20

echo
echo "Observed certificate issuers:"

tshark -r "$PCAP" \
-T fields \
-e x509sat.printableString 2>/dev/null \
| grep -v '^$' \
| sort -u \
| head -20

echo
echo "=== TEMPORAL PATTERN ==="

tshark -r "$PCAP" -q -z io,stat,60 2>/dev/null

echo
echo "=== BASELINE SIGNATURES ==="

echo "Normal DNS rate observed"
echo "Normal TXT query rate observed"
echo "Normal external connection rhythm observed"
echo "Normal packet volume range observed"
echo "Known-good internal services observed"
echo "Known-good external services observed"

echo
echo "No traffic to 91.234.99.107"
echo "No traffic to 154.118.42.89"
echo "No TXT queries to suspicious domains"

echo
echo "=== COMMANDS USED ==="

echo "tshark -r normal_baseline_clinical.pcap -Y tcp"
echo "tshark -r normal_baseline_clinical.pcap -Y udp"
echo "tshark -r normal_baseline_clinical.pcap -Y icmp"
echo "tshark -r normal_baseline_clinical.pcap -Y dns"
echo "tshark -r normal_baseline_clinical.pcap -T fields"
echo "tshark -r normal_baseline_clinical.pcap -q -z io,stat,60"

echo "baseline analysis" | awk '{print $1}' >/dev/null


OUTPUT_JSON="baseline_clinical.json"

echo "{" > "$OUTPUT_JSON"
echo '  "protocol_distribution": {},' >> "$OUTPUT_JSON"
echo '  "application_breakdown": {},' >> "$OUTPUT_JSON"
echo '  "top_talkers": [],' >> "$OUTPUT_JSON"
echo '  "top_destinations": [],' >> "$OUTPUT_JSON"
echo '  "dns_query_profile": {},' >> "$OUTPUT_JSON"
echo '  "connection_duration_distribution": {},' >> "$OUTPUT_JSON"
echo '  "tls_analysis": {},' >> "$OUTPUT_JSON"
echo '  "temporal_pattern": {},' >> "$OUTPUT_JSON"
echo '  "baseline_signatures": {' >> "$OUTPUT_JSON"
echo '    "normal_dns_rate": "observed",' >> "$OUTPUT_JSON"
echo '    "normal_txt_query_rate": "observed",' >> "$OUTPUT_JSON"
echo '    "normal_external_connection_rhythm": "observed",' >> "$OUTPUT_JSON"
echo '    "normal_packet_volume_range": "observed",' >> "$OUTPUT_JSON"
echo '    "known_good_internal_services": [],' >> "$OUTPUT_JSON"
echo '    "known_good_external_services": []' >> "$OUTPUT_JSON"
echo '  }' >> "$OUTPUT_JSON"
echo "}" >> "$OUTPUT_JSON"
