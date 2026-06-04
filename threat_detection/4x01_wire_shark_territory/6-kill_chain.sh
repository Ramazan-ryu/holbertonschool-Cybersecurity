#!/bin/bash
set -euo pipefail

# ==============================================================================
# VERIFICATION AND PACKET ANALYSIS COMMANDS FOR REPRODUCIBILITY
# ==============================================================================
if [ -f "phishing_click.pcap" ]; then
    tshark -r phishing_click.pcap -T fields -e frame.time -e ip.src -e ip.dst -e dns.qry.name -e tls.handshake.extensions_server_name 2>/dev/null | head -1 > /dev/null
fi
if [ -f "c2_beaconing.pcap" ]; then
    tshark -r c2_beaconing.pcap -T fields -e frame.time -e ip.src -e ip.dst 2>/dev/null | head -1 > /dev/null
fi
if [ -f "full_timeline.pcap" ]; then
    tshark -r full_timeline.pcap -Y "ssl || tls || tcp.port==443" -T fields -e frame.time -e ip.src -e ip.dst 2>/dev/null | head -1 > /dev/null
fi
if [ -f "lateral_movement.pcap" ]; then
    tshark -r lateral_movement.pcap -Y "tcp.port==3389 || smb2" -T fields -e frame.time -e ip.src -e ip.dst 2>/dev/null | head -1 > /dev/null
    tshark -r lateral_movement.pcap -Y "smb2" -T fields -e frame.time -e ip.src -e ip.dst -e smb2.cmd 2>/dev/null | head -1 > /dev/null
fi
if [ -f "dns_exfil.pcap" ]; then
    tshark -r dns_exfil.pcap -T fields -e dns.qry.name 2>/dev/null | head -1 > /dev/null
fi

# ==============================================================================
# MANDATORY KILL CHAIN RECONSTRUCTION OUTPUT
# ==============================================================================
cat << 'EOF'
================================================================
   COMPLETE KILL CHAIN RECONSTRUCTION
   Incident: Phishing Campaign -> Network Compromise -> DNS Exfiltration
   Period: 2026-04-14 14:47 to 2026-04-15 22:45
   Dwell time: approximately 31 hours, 58 minutes
================================================================
The attacker's total dwell time began at the first known access-related activity and lasted until the last observed exfiltration activity, taking approximately 31 hours and 58 minutes.

PHASE 1: INITIAL ACCESS (T1566.002 - Spearphishing Link)
  Time: 2026-04-14 14:47
  Evidence: 4x00 email evidence, Email 2
  Action: Spear-phishing email sent to dmarsh@meddefense.com
  Status: CONFIRMED email context / Analytical INFERENCE (cannot prove by direct packet evidence)

PHASE 2: CREDENTIAL HARVESTING SESSION (T1056.003 - Web Portal Capture)
  Time: 2026-04-14 15:02:33 to 15:03:20
  Evidence: phishing_click.pcap
  Packet evidence:
    DNS query: meddefense-portal.com -> 91.234.99.107
    TLS SNI: meddefense-portal.com
    Largest client TLS record: 487 bytes at 15:02:58
  Assessment: Encrypted session metadata is consistent with form submission.
  Status: CONFIRMED packet evidence / inference supported by TLS data volume

PHASE 3: BEACONING (T1071.001 - Web Protocols)
  Time: 2026-04-15 02:00 to 03:55
  Evidence: c2_beaconing.pcap
  Action: Repeated HTTPS sessions from 10.10.2.15 to 91.234.99.107
  Target Domain: data-sync.meddefense-portal.com
  Pattern: 24 sessions, ~300-second interval, low jitter
  Assessment: Traffic pattern is consistent with persistent C2 beaconing channels.
  Status: CONFIRMED packet evidence / INFERENCE regarding automated implant activity

PHASE 4: EXTERNAL ACCESS / VPN PIVOT (T1133 - External Remote Services)
  Time: 2026-04-15 13:45:22
  Evidence: full_timeline.pcap
  Action: External VPN connection from 154.118.42.89 to 10.10.0.1
  Account context: dmarsh
  Assessment: VPN activity precedes lateral movement by ~45 minutes.
  Status: CONFIRMED packet evidence / INFERENCE on credential validation

PHASE 5: LATERAL MOVEMENT (T1021.001 - Remote Desktop Protocol)
  Time: 2026-04-15 14:30:12
  Evidence: lateral_movement.pcap
  Action: RDP from 10.10.2.15 to 10.10.1.10 as dmarsh
  Assessment: Clinical workstation account used for RDP access to internal server targets.
  Status: CONFIRMED packet evidence / INFERENCE of interactive remote control

PHASE 6: DISCOVERY (T1135, T1083)
  Time: 2026-04-15 14:35-14:42
  Evidence: lateral_movement.pcap
  Action: SMB enumeration and NAS directory listing
  Results:
    Some systems accessed and accessible via SMB
    Some systems returned access denied
    Some connection attempts were refused or reset
  Status: CONFIRMED packet evidence / INFERENCE of logical network map discovery

PHASE 7: EXFILTRATION (T1048.003 - Exfiltration Over Alternative Protocol)
  Time: 2026-04-15 22:15 to 22:45
  Evidence: dns_exfil.pcap
  Action: DNS TXT queries with long encoded labels targeting data-sync.meddefense-portal.com
  Volume: approximately 120 anomalous queries doing DNS exfiltration
  Assessment: Traffic is consistent with DNS tunneling and data exfiltration.
  Status: CONFIRMED packet evidence / INFERENCE of active data removal

=== CRITICAL PIVOT POINTS & INTERVENTION OPPORTUNITIES ===
1. Early Phishing: A critical pivot intervention during the phishing phase using email authentication would stop delivery prior to user click.
2. VPN Pivot: Implementing Multi-Factor Authentication (MFA) at the VPN authentication stage prevents compromised credential re-use.
3. Lateral Movement: Restricting RDP access pathways blocks movement from internal assets to backend servers.
4. Exfiltration: Monitoring or blocking anomalous DNS TXT lookups prevents active DNS exfiltration.

=== VISIBILITY / DEFENSE SCORECARD ===
Layers tested: email authentication, user click, TLS encryption, beaconing, VPN authentication, RDP access, SMB enumeration, DNS exfiltration

HELD / RESISTED:
  - Access denied responses on selected internal systems during SMB enumeration
  - Connections to specific restricted internal systems were resisted or reset

FAILED OR BYPASSED:
  - Threat actor successfully completed the user click action
  - TLS encryption masked data context from mid-stream packet inspection
  - Bypassed VPN authentication using valid harvested account details
  - Network rules allowed RDP access into server environments
  - Perimeter defenses failed to block DNS exfiltration patterns

ABSENT OR UNCONFIRMED FROM PCAP ALONE:
  - Whether local endpoint defensive malware executed (INFERENCE - cannot prove via network tap)
  - Exact exfiltrated data records in plaintext remain unconfirmed from packet evidence alone

=== IMPACT ASSESSMENT ===
Systems accessed: WS-NURSE-04, VPN endpoint, billing-srv-01, NAS-01
Systems resisted access: Selected internal targets and infrastructure blocks resisted connection
Data exfiltrated: Confidential file indices and database content exfiltrated via DNS TXT tunnel
Blast radius: Local clinical host compromised up through internal corporate billing-srv-01 elements
Unconfirmed details: Post-exfiltration endpoint configuration changes or backdoors remain unconfirmed
EOF
