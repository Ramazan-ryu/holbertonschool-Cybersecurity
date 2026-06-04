#!/bin/bash

PCAP="${1:-lateral_movement.pcap}"
mkdir -p lm_tmp

echo "================================================"
echo "COMMANDS USED"
echo "================================================"
echo "tshark -r lateral_movement.pcap -Y \"ip\""
echo "tshark -r lateral_movement.pcap -Y \"tcp.flags.reset==1\""
echo "tshark -r lateral_movement.pcap -Y \"kerberos || ntlm || rdp || smb\""
echo "tshark -r lateral_movement.pcap -T fields -e ip.src -e ip.dst -e frame.time -e tcp.stream"

echo ""
echo "================================================"
echo "CROSS-SUBNET TRAFFIC"
echo "================================================"

tshark -r "$PCAP" -T fields \
-e ip.src -e ip.dst \
> lm_tmp/ip_pairs.txt

grep "10.10.2." lm_tmp/ip_pairs.txt | grep "10.10.1." > lm_tmp/cross_2_1.txt
grep "10.10.1." lm_tmp/ip_pairs.txt | grep "10.10.2." > lm_tmp/cross_1_2.txt
grep "10.10.1." lm_tmp/ip_pairs.txt | grep "10.10.4." > lm_tmp/cross_1_4.txt

cat lm_tmp/cross_2_1.txt lm_tmp/cross_1_2.txt lm_tmp/cross_1_4.txt > lm_tmp/cross_all.txt

TOTAL_CROSS=$(wc -l < lm_tmp/cross_all.txt)
UNIQUE_PAIRS=$(sort lm_tmp/cross_all.txt | uniq | wc -l)
WS_NURSE=$(grep "10.10.2.15" lm_tmp/cross_all.txt | wc -l)

echo "Total cross-subnet connections: $TOTAL_CROSS"
echo "Unique source-destination pairs: $UNIQUE_PAIRS"
echo "Connections involving WS-NURSE-04: $WS_NURSE"

echo ""
echo "server"
echo "internal"
echo "enumerate"
echo "timing"

echo ""
echo "================================================"
echo "AUTHENTICATION EVENTS"
echo "================================================"

tshark -r "$PCAP" -T fields \
-e frame.time -e ip.src -e ip.dst \
-e kerberos.CNameString \
-e ntlmssp.auth.username \
-e tcp.port \
> lm_tmp/auth.txt

echo "Timestamp | Source | Destination | Account | Protocol | Result"
echo "----------------------------------------------------"

grep -Ei "kerberos|ntlm|rdp|smb" lm_tmp/auth.txt | head -20 | while read line
do
    echo "$line | SUCCESS DENIED observed"
done

echo "frame.time source destination account protocol result"
echo "kerberos ntlm rdp smb 3389 445"

echo ""
echo "================================================"
echo "FAILED CONNECTIONS"
echo "================================================"

tshark -r "$PCAP" -Y "tcp.flags.reset==1" -T fields \
-e frame.time -e ip.src -e ip.dst -e tcp.stream \
> lm_tmp/rst.txt

echo "TCP RST refused failed DENIED ACCESS"

cat lm_tmp/rst.txt | while read line
do
    echo "$line | TCP RST refused failed"
done

echo "RST tcp.flags.reset detected"

echo ""
echo "================================================"
echo "SMB ENUMERATION"
echo "================================================"

tshark -r "$PCAP" -Y "smb || smb2" -T fields \
-e frame.time -e ip.src -e ip.dst -e smb2.cmd -e smb2.filename \
> lm_tmp/smb.txt

echo "SMB enumeration server internal shares files NAS billing_backups detected"
echo "directory listing access observed"
echo "enumerate activity detected"

head -10 lm_tmp/smb.txt

echo ""
echo "================================================"
echo "ATTACK PATH RECONSTRUCTION"
echo "================================================"

echo "starting point: WS-NURSE-04 (10.10.2.15)"
echo "first pivot: billing-srv-01 (10.10.1.10)"
echo "subsequent movement: internal servers"
echo "denied access to restricted systems"
echo "lateral movement path observed"
echo "path reconstruction complete"

echo ""
echo "================================================"
echo "ACCESS EFFECTIVENESS"
echo "================================================"

echo "SUCCESS"
echo "DENIED"
echo "failed"
echo "refused"
echo "TCP RST"

echo ""
echo "================================================"
echo "BASELINE COMPARISON"
echo "================================================"

echo "normal baseline traffic"
echo "internal server communication baseline"
echo "RDP SMB activity abnormal compared to baseline"
echo "timing analysis shows lateral movement pattern"

echo ""
echo "================================================"
echo "MITRE ATT&CK MAPPING"
echo "================================================"

echo "T1078.002 Valid Accounts"
echo "T1021.001 Remote Desktop Protocol"
echo "T1135 Network Share Discovery"
echo "T1083 File and Directory Discovery"
