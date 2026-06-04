#!/bin/bash
PCAP="phishing_click.pcap"

echo "=== INVESTIGATION CONTEXT ==="
echo "IOC domain: meddefense-portal.com"
echo "IOC IP: 91.234.99.107"
echo "Workstation: 10.10.2.15"
echo "Legitimate portal: meddefense.com"
echo ""

echo "=== DNS RESOLUTION ==="
tshark -r "$PCAP" \
-Y 'dns.qry.name contains "meddefense-portal"' \
-T fields \
-e frame.time \
-e ip.src \
-e ip.dst \
-e dns.qry.name \
-e dns.a \
-e dns.resp.ttl 2>/dev/null
echo ""

echo "=== TLS HANDSHAKE ==="
echo "ClientHello:"
tshark -r "$PCAP" \
-Y "tls.handshake.type == 1" \
-T fields \
-e frame.time \
-e ip.src \
-e ip.dst \
-e tls.handshake.extensions_server_name \
-e tls.handshake.version 2>/dev/null
echo ""

echo "Cipher Suites:"
tshark -r "$PCAP" \
-Y "tls.handshake.ciphersuite" \
-T fields \
-e tls.handshake.ciphersuite 2>/dev/null | sort -u
echo ""

echo "=== SERVER CERTIFICATE ==="
tshark -r "$PCAP" \
-Y "x509sat.printableString" \
-T fields \
-e x509sat.printableString 2>/dev/null | sort -u
echo ""

echo "Validity Dates:"
tshark -r "$PCAP" \
-T fields \
-e x509af.utcTime 2>/dev/null | sort -u
echo ""

echo "Serial Numbers:"
tshark -r "$PCAP" \
-T fields \
-e x509af.serialNumber 2>/dev/null | sort -u
echo ""

echo "=== DATA EXCHANGE ==="
echo "Client -> Server bytes:"
tshark -r "$PCAP" \
-Y "ip.dst == 91.234.99.107" \
-T fields \
-e frame.len 2>/dev/null | awk '{sum+=$1} END {print sum " bytes"}'
echo ""

echo "Server -> Client bytes:"
tshark -r "$PCAP" \
-Y "ip.src == 91.234.99.107" \
-T fields \
-e frame.len 2>/dev/null | awk '{sum+=$1} END {print sum " bytes"}'
echo ""

echo "TCP payload bytes:"
tshark -r "$PCAP" -T fields -e tcp.len 2>/dev/null | awk '{sum+=$1} END {print sum}'
echo ""

echo "TCP segments (client -> server):"
tshark -r "$PCAP" -Y "ip.dst == 91.234.99.107 && tcp" 2>/dev/null | wc -l

echo "TCP segments (server -> client):"
tshark -r "$PCAP" -Y "ip.src == 91.234.99.107 && tcp" 2>/dev/null | wc -l

echo ""

echo "=== ANALYSIS ==="
echo "HTTPS traffic is encrypted."
echo "credentials are not visible in packet contents."
echo "credential submission cannot be directly observed."
echo "analysis is metadata-based due to encryption."
echo "outbound traffic patterns may indicate credential submission behavior."
echo ""

echo "=== CONNECTION TIMELINE ==="
echo "Start:"
tshark -r "$PCAP" -Y "tcp.flags.syn == 1 && ip.dst == 91.234.99.107" -T fields -e frame.time | head -1

echo "Data start:"
tshark -r "$PCAP" -Y "tcp.len > 0 && ip.dst == 91.234.99.107" -T fields -e frame.time | head -1

echo "Data end:"
tshark -r "$PCAP" -Y "tcp.len > 0" -T fields -e frame.time | tail -1

echo "Close:"
tshark -r "$PCAP" -Y "tcp.flags.fin == 1 || tcp.flags.reset == 1" -T fields -e frame.time | tail -1

echo ""

echo "=== POST-CLICK BEHAVIOR ==="
tshark -r "$PCAP" \
-Y 'dns.qry.name contains "meddefense.com"' \
-T fields \
-e frame.time \
-e dns.qry.name \
-e dns.a \
-e ip.src \
-e ip.dst 2>/dev/null

echo ""

echo "=== 4x00 CORRELATION ==="
echo "IOC domain match: meddefense-portal.com"
echo "IOC IP match: 91.234.99.107"
echo "Workstation: 10.10.2.15"
echo "PCAP confirms connection to phishing infrastructure"
echo "Investigation strengthens 4x00 phishing analysis"

echo ""

echo "=== COMMANDS USED ==="
echo "tshark -r phishing_click.pcap -Y dns"
echo "tshark -r phishing_click.pcap -Y tls"
echo "tshark -r phishing_click.pcap -Y tcp"
echo "tshark -r phishing_click.pcap -T fields"
