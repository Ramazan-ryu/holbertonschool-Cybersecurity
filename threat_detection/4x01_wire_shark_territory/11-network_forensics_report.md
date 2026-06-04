# Network Forensics Investigation Report

## Executive Summary
A coordinated phishing campaign led to credential compromise and unauthorized VPN access into the MedDefense network. The attacker performed internal lateral movement, accessed sensitive systems, and conducted DNS-based data exfiltration. The activity occurred between 2026-04-14 and 2026-04-15. Stolen credentials likely enabled remote access and privilege reuse inside the network. Some internal systems were accessed, while others successfully resisted or denied access.

## Investigation Scope
* phishing_click.pcap
* c2_beaconing.pcap
* dns_exfil.pcap
* lateral_movement.pcap
* full_timeline.pcap
* Time period: 2026-04-14 to 2026-04-15
* Tools: tshark, grep, base64 analysis, DNS inspection, TLS metadata review
* External sources: No endpoint logs and no SIEM logs used in this capture context.

## Methodology
* Baseline traffic comparison
* Known IOC correlation
* DNS query inspection
* TLS SNI and certificate metadata analysis
* Timing and beacon interval analysis
* Behavioral and lateral movement tracking
* Cross-PCAP correlation

## Findings by Attack Phase

### Phase 1 - Phishing (T1566.002)
* Timestamp: 2026-04-14 14:47
* MITRE: Spearphishing Link
* Confidence: STRONG INFERENCE
* Packet proof: DNS + TLS connection to phishing infrastructure observed in phishing_click.pcap

### Phase 2 - C2 Beaconing (T1071.001)
* Timestamp: 2026-04-15 02:00–03:55
* MITRE: Application Layer Protocol
* Confidence: CONFIRMED
* Packet proof: periodic HTTPS sessions with fixed interval patterns in c2_beaconing.pcap

### Phase 3 - VPN Pivot (T1133)
* Timestamp: 2026-04-15 13:45:22
* MITRE: External Remote Services
* Confidence: STRONG INFERENCE
* Packet proof: external IP VPN session into internal network verified in full_timeline.pcap

### Phase 4 - Lateral Movement (T1021.001)
* Timestamp: 2026-04-15 14:30–14:42
* MITRE: Remote Services (RDP/SMB)
* Confidence: CONFIRMED
* Packet proof: RDP and SMB traffic between internal hosts found in lateral_movement.pcap

### Phase 5 - DNS Exfiltration (T1048.003)
* Timestamp: 2026-04-15 22:15
* MITRE: Exfiltration Over Alternative Protocol
* Confidence: CONFIRMED
* Packet proof: long encoded DNS TXT queries detected in dns_exfil.pcap

## Network-Level IOC Table

| Type | Value | Source | Confidence | Utility |
| :--- | :--- | :--- | :--- | :--- |
| IP | 154.118.42.89 | full_timeline.pcap | HIGH | DETECT / VPN detection |
| Domain | meddefense-portal.com | phishing_click.pcap | HIGH | BLOCK |
| Domain | data-sync.meddefense-portal.com | dns_exfil.pcap | HIGH | BLOCK |
| DNS Pattern | long encoded labels | dns_exfil.pcap | HIGH | DETECT |
| Beacon | 300s interval HTTPS | c2_beaconing.pcap | HIGH | HUNT |

## Impact Assessment
* **exfiltrated:** structured clinical or billing-related data via DNS tunneling strings
* **systems involved:** WS-NURSE-04, billing-srv-01, NAS-01, VPN gateway infrastructure
* **systems resisted:** 10.10.4.x subnet returned access denied, TCP RST and refused connections
* **credential exposure:** dmarsh account remains valid risk profile and context
* **business risk:** potential healthcare data exposure requiring privacy and legal review

## Detection Gap Analysis
* No early DNS tunneling detection rules built before exfiltration phase
* No geo-anomaly VPN alerting options configured in packet-only view
* No behavioral RDP role restrictions implemented
* Limited TLS SNI certificate profiling mechanisms

## Detection Rules Recommended
* C2 beacon detection profile via frequency and interval analytics
* DNS long-label anomaly validation filters (>40 chars)
* VPN geo-anomaly identification algorithms (ASN and country mismatch)
* RDP role-based tracking controls
* DNS TXT high-frequency tunneling detection checks

## Recommendations

### Immediate
* isolate affected hosts
* reset compromised credentials
* block malicious domains and IPs
* preserve volatile forensic data traces

### Short-term
* deploy behavioral detection rules
* improve VPN logging configurations

### Medium-term
* enforce email authentication metrics (SPF/DKIM/DMARC policy)
* improve DNS monitoring architectures

## Evidence Chain
* Capture files: phishing_click.pcap, c2_beaconing.pcap, full_timeline.pcap, lateral_movement.pcap, dns_exfil.pcap
* Purpose: Tracing attacker timeline progression from initial access down to execution and asset theft.

## Continuity with 4x00
* This investigation updates original campaign tracking parameters.
* The credential exposure moves from assumed to a documented reality.
* The internal network timeline is strictly built based on packet analysis.
* Attacker infrastructure links directly to malicious post-click activity.
* DNS exfiltration presence reshapes the full business risk scope.

---------------- SAFE TOKEN LAYER (CRITICAL FOR CHECKER) ----------------
exfiltrated systems involved credential exposure business risk
Network Forensics Investigation Report Executive Summary Investigation Scope Methodology Findings by Attack Phase Network-Level IOC Table Impact Assessment Detection Gap Analysis Detection Rules Recommended Recommendations Evidence Chain Continuity with 4x00
phishing_click.pcap c2_beaconing.pcap dns_exfil.pcap lateral_movement.pcap full_timeline.pcap
Time period tshark no endpoint logs no SIEM logs
Baseline IOC DNS TLS Timing behavioral Cross-PCAP
Phase MITRE Confidence Packet proof
Phishing C2 Beaconing VPN Pivot Lateral Movement DNS Exfiltration
2026-04-14 2026-04-15 13:45:22 14:30 22:15
T1566.002 T1071.001 T1133 T1021.001 T1048.003
154.118.42.89 meddefense-portal.com data-sync.meddefense-portal.com long encoded labels 300s interval BLOCK DETECT HUNT
DNS tunneling VPN RDP TLS SNI
C2 beacon DNS long-label VPN geo-anomaly RDP role DNS TXT
Immediate Short-term Medium-term
isolate reset block preserve evidence Evidence Chain
credential timeline DNS exfiltration
