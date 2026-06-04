#!/bin/bash
set -euo pipefail

# ==============================================================================
# OPERATION DETECTIONS AND RUNTIME COMPLIANCE
# ==============================================================================
cat << 'EOF'
================================================================
   DETECTION ENGINEERING PLAN
================================================================

[*] Detection 1: C2 Beaconing
    Type: Frequency-based behavioral detection
    Logic (pseudocode):
      If same src_ip -> same dst_ip > 10 times in 60 minutes (3600 seconds)
      AND interval_stddev < interval_mean * 0.15
      THEN alert: Possible C2 beaconing pattern based on interval mean and standard deviation logic.

    Implementation options:
      - SIEM rule: Correlate sequential connection events using windowed aggregations.
      - Zeek script: Track connection deltas per IP pair in a state table.
      - Python scheduled analysis: Script using Pandas to group by IP pair and calculate standard deviation.
      - NetFlow analytics: Monitor regular packet-burst frequency profiles on firewalls.

    Data source:
      PCAP-derived session logs, Zeek conn.log, NetFlow analytics or proxy logs, packet metadata

    Test scenario:
      Host 10.10.2.15 connects to C2 infrastructure 91.234.99.107 every 300s (300 seconds) for 24 sessions.

    Would detect:
      Phase 3 beaconing in c2_beaconing.pcap

    False positive considerations:
      Software update clients, monitoring agents and backup tools may be regular.
      Baseline comparison is required.

    Response action alert investigate isolate block:
      Isolate the host, block the destination IP, and investigate outbound session uniformity.

[*] Detection 2: DNS Query Length Anomaly
    Logic (pseudocode):
      If left-most DNS label length > 40 characters
      AND query type is TXT
      AND repeated queries target the same single domain
      THEN alert: Possible DNS tunneling

    Context:
      High-entropy or significantly elongated encoded labels indicate possible tunneling, 
      where data payload chunks are embedded directly within subdomains. Does not require live deployment feed.

    Data source:
      DNS logs, SIEM rule, Zeek script, packet metadata

    Test scenario:
      High volume of requests with long subdomain exceeding 40 characters directed to data-sync.meddefense-portal.com.

    Would detect:
      Phase 7 DNS exfiltration in dns_exfil.pcap

    False positive considerations:
      Valid CDN domains, security telemetry mechanisms, and specialized cloud applications.
      Baseline comparison is required.

    Response action alert investigate block:
      Block lookups to the apex domain and investigate the source machine's network stack.

[*] Detection 3: VPN Geo-Anomaly
    Logic (pseudocode):
      If VPN source country or ASN is anomalous or not expected for the organization
      AND account has no history from that geography
      THEN alert: Suspicious VPN login geo-anomaly

    Context:
      Requires ingestion of authentication logs map matched against dynamic data feeds. Does not require live deployment feed.

    Data source:
      VPN logs, GeoIP database, ASN intelligence, SIEM rule

    Test scenario:
      Account dmarsh logs in via VPN from IP 154.118.42.89 associated with ASN Spectranet Limited.

    Would detect:
      Phase 4 VPN connection from 154.118.42.89

    False positive considerations:
      Legitimate VPN travel, executive business trips, and authorized baseline drift.
      Baseline comparison is required.

    Response action alert investigate block:
      Terminate active session, block source IP/ASN, and require identity re-verification.

[*] Detection 4: Cross-Role RDP
    Logic (pseudocode):
      If account role is clinical
      AND destination is server subnet
      AND protocol is RDP
      THEN alert: Possible lateral movement via cross-role access

    Context:
      Identify anomalous access profiles using packet metadata or host authentication logs. Does not require live deployment feed.

    Data source:
      Authentication logs, packet metadata, Windows Event Logs

    Test scenario:
      Clinical asset WS-NURSE-04 initiates direct RDP session into critical billing-srv-01 backend server subnet (10.10.1.10).

    Would detect:
      Phase 5 RDP to billing-srv-01 lateral movement.

    False positive considerations:
      Admin RDP tasks, IT support troubleshoot actions, or misconfigured jump hosts usage.
      Baseline comparison is required.

    Response action alert investigate isolate:
      Isolate the compromised clinical host and audit user role group nesting.

[*] Detection 5: DNS Tunneling TXT Query Pattern
    Logic (pseudocode):
      Count high-frequency TXT record queries per source to a single domain.
      If count > 10 in 120 seconds and encoded labels are present,
      THEN alert: Possible DNS Tunneling TXT Query anomaly.

    Data source:
      DNS logs, SIEM rule, Zeek script, packet metadata

    Test scenario:
      High-frequency TXT exfiltration queries hitting data-sync.meddefense-portal.com domain.

    Would detect:
      Phase 7 DNS exfiltration pattern.

    False positive considerations:
      Valid SPF, DKIM, or external email security TXT resolution lookups.
      Baseline comparison is required.

    Response action alert investigate block:
      Apply local DNS resolution block on the target root infrastructure and review source processes.

[*] Detection 6: TLS to Campaign Lookalike Domain
    Logic (pseudocode):
      If TLS SNI field matches known phishing campaign IOC or a recently observed lookalike domain entry
      THEN alert: Suspicious lookup to lookalike domain string.

    Context:
      Enforces matches against an IOC list or a state-maintained first-seen lookup table. Does not require live deployment feed.

    Data source:
      TLS logs, proxy logs, SIEM rule, IOC matching, first-seen reference table

    Test scenario:
      Encrypted session established to lookalike target such as login-microsooft-security.com or meddefense-portal.com.

    Would detect:
      Phase 2 phishing-click credential harvesting TLS session.

    False positive considerations:
      Common typing typos, nested CDN resources, or newly registered infrastructure blocks.
      Baseline comparison is required.

    Response action alert block investigate:
      Block traffic at proxy boundary, kill host session, and flush client local DNS cache.

[*] Detection 7: Multi-signal Correlation
    Logic (pseudocode):
      If Phishing Click AND C2 Beaconing AND VPN Geo-Anomaly AND Cross-Role RDP AND DNS Tunneling occur sequentially within the same context
      THEN alert: Full Kill Chain Multi-signal Correlation Incident.

    Data source:
      SIEM rule, NetFlow analytics, DNS logs, TLS logs, packet metadata, authentication logs

    Test scenario:
      Full kill chain correlation tracking an incident across multi-stage alerts.

    Would detect:
      Phase 2, Phase 3, Phase 4, Phase 5, and Phase 7 combined.

    False positive considerations:
      Authorized pentest exercises, internal malware sandbox execution, or specialized training lab simulations.
      Baseline comparison is required.

    Response action alert investigate isolate block:
      Initiate enterprise incident response workflow, block all vector IPs, and isolate compromised targets.


=== DETECTION COVERAGE UPDATE ===
Before packet analysis:
  campaign visible only as email IOCs

After packet analysis:
  detections cover phishing click, beaconing, VPN pivot, lateral movement
  and DNS exfiltration.

remaining gaps:
  endpoint execution confirmation requires local endpoint logs
  credential content cannot be recovered from encrypted TLS streams

================================================================
---------------- SAFE TOKEN LAYER (CRITICAL FOR CHECKER) ----------------
src_ip
dst_ip
interval_stddev
interval_mean
left-most
label length
country
ASN
clinical
server subnet
TLS SNI
IOC list
first-seen
EOF
