#!/bin/bash

OUTPUT="11-network_forensics_report.md"

echo "Generating 11-network_forensics_report.md..."

# =========================
# CREATE MARKDOWN FILE
# =========================

echo "# Network Forensics Investigation Report" > "$OUTPUT"

# =========================
# EXECUTIVE SUMMARY
# =========================

echo "" >> "$OUTPUT"
echo "## Executive Summary" >> "$OUTPUT"
echo "A coordinated phishing campaign led to credential compromise and unauthorized VPN access into the MedDefense network." >> "$OUTPUT"
echo "The attacker performed internal lateral movement, accessed sensitive systems, and conducted DNS-based data exfiltration." >> "$OUTPUT"
echo "The activity occurred between 2026-04-14 and 2026-04-15." >> "$OUTPUT"
echo "Stolen credentials likely enabled remote access and privilege reuse inside the network." >> "$OUTPUT"
echo "Some internal systems were accessed, while others successfully resisted or denied access." >> "$OUTPUT"

# =========================
# INVESTIGATION SCOPE
# =========================

echo "" >> "$OUTPUT"
echo "## Investigation Scope" >> "$OUTPUT"
echo "- phishing_click.pcap" >> "$OUTPUT"
echo "- c2_beaconing.pcap" >> "$OUTPUT"
echo "- dns_exfil.pcap" >> "$OUTPUT"
echo "- lateral_movement.pcap" >> "$OUTPUT"
echo "- full_timeline.pcap" >> "$OUTPUT"
echo "- Time period: 2026-04-14 to 2026-04-15" >> "$OUTPUT"
echo "- Tools: tshark, grep, base64 analysis, DNS inspection, TLS metadata review" >> "$OUTPUT"
echo "- External sources: No endpoint logs, no SIEM logs used" >> "$OUTPUT"

# =========================
# METHODOLOGY
# =========================

echo "" >> "$OUTPUT"
echo "## Methodology" >> "$OUTPUT"
echo "- Baseline traffic comparison" >> "$OUTPUT"
echo "- Known IOC correlation" >> "$OUTPUT"
echo "- DNS query inspection" >> "$OUTPUT"
echo "- TLS SNI and certificate metadata analysis" >> "$OUTPUT"
echo "- Timing and beacon interval analysis" >> "$OUTPUT"
echo "- Lateral movement tracking" >> "$OUTPUT"
echo "- Cross-PCAP correlation" >> "$OUTPUT"

# =========================
# FINDINGS BY PHASE
# =========================

echo "" >> "$OUTPUT"
echo "## Findings by Attack Phase" >> "$OUTPUT"

echo "### Phase 1 - Phishing (T1566.002)" >> "$OUTPUT"
echo "Evidence: phishing_click.pcap" >> "$OUTPUT"
echo "Timestamp: 2026-04-14 14:47" >> "$OUTPUT"
echo "MITRE: Spearphishing Link" >> "$OUTPUT"
echo "Confidence: STRONG INFERENCE" >> "$OUTPUT"
echo "Packet proof: DNS + TLS connection to phishing infrastructure observed" >> "$OUTPUT"

echo "" >> "$OUTPUT"

echo "### Phase 2 - C2 Beaconing (T1071.001)" >> "$OUTPUT"
echo "Evidence: c2_beaconing.pcap" >> "$OUTPUT"
echo "Timestamp: 2026-04-15 02:00–03:55" >> "$OUTPUT"
echo "MITRE: Application Layer Protocol" >> "$OUTPUT"
echo "Confidence: CONFIRMED" >> "$OUTPUT"
echo "Packet proof: periodic HTTPS sessions with fixed interval patterns" >> "$OUTPUT"

echo "" >> "$OUTPUT"

echo "### Phase 3 - VPN Pivot (T1133)" >> "$OUTPUT"
echo "Evidence: full_timeline.pcap" >> "$OUTPUT"
echo "Timestamp: 2026-04-15 13:45:22" >> "$OUTPUT"
echo "MITRE: External Remote Services" >> "$OUTPUT"
echo "Confidence: STRONG INFERENCE" >> "$OUTPUT"
echo "Packet proof: external IP VPN session into internal network" >> "$OUTPUT"

echo "" >> "$OUTPUT"

echo "### Phase 4 - Lateral Movement (T1021.001)" >> "$OUTPUT"
echo "Evidence: lateral_movement.pcap" >> "$OUTPUT"
echo "Timestamp: 2026-04-15 14:30–14:42" >> "$OUTPUT"
echo "MITRE: Remote Services (RDP/SMB)" >> "$OUTPUT"
echo "Confidence: CONFIRMED" >> "$OUTPUT"
echo "Packet proof: RDP and SMB traffic between internal hosts" >> "$OUTPUT"

echo "" >> "$OUTPUT"

echo "### Phase 5 - DNS Exfiltration (T1048.003)" >> "$OUTPUT"
echo "Evidence: dns_exfil.pcap" >> "$OUTPUT"
echo "Timestamp: 2026-04-15 22:15–22:45" >> "$OUTPUT"
echo "MITRE: Exfiltration Over Alternative Protocol" >> "$OUTPUT"
echo "Confidence: CONFIRMED" >> "$OUTPUT"
echo "Packet proof: long encoded DNS TXT queries detected" >> "$OUTPUT"

# =========================
# IOC TABLE
# =========================

echo "" >> "$OUTPUT"
echo "## Network-Level IOC Table" >> "$OUTPUT"
echo "| Type | Value | Source | Confidence | Utility |" >> "$OUTPUT"
echo "|------|-------|--------|------------|---------|" >> "$OUTPUT"
echo "| IP | 154.118.42.89 | full_timeline.pcap | HIGH | VPN detection |" >> "$OUTPUT"
echo "| Domain | meddefense-portal.com | phishing_click.pcap | HIGH | BLOCK |" >> "$OUTPUT"
echo "| Domain | data-sync.meddefense-portal.com | dns_exfil.pcap | HIGH | BLOCK |" >> "$OUTPUT"
echo "| DNS Pattern | long encoded labels | dns_exfil.pcap | HIGH | DETECT |" >> "$OUTPUT"
echo "| Beacon | 300s interval HTTPS | c2_beaconing.pcap | HIGH | HUNT |" >> "$OUTPUT"

# =========================
# IMPACT
# =========================

echo "" >> "$OUTPUT"
echo "## Impact Assessment" >> "$OUTPUT"
echo "- Likely exfiltrated: structured clinical or billing-related data via DNS tunneling" >> "$OUTPUT"
echo "- Systems involved: WS-NURSE-04, billing-srv-01, NAS-01, VPN gateway" >> "$OUTPUT"
echo "- Systems resisted: 10.10.4.x subnet (RST / denied connections)" >> "$OUTPUT"
echo "- Credential exposure: dmarsh account likely compromised" >> "$OUTPUT"
echo "- Business risk: potential healthcare data exposure requiring legal escalation" >> "$OUTPUT"

# =========================
# DETECTION GAPS
# =========================

echo "" >> "$OUTPUT"
echo "## Detection Gap Analysis" >> "$OUTPUT"
echo "- No early DNS tunneling detection before exfiltration phase" >> "$OUTPUT"
echo "- No geo-anomaly VPN alerting observed in packet-only view" >> "$OUTPUT"
echo "- No behavioral RDP role restriction enforcement" >> "$OUTPUT"
echo "- Limited TLS SNI inspection for phishing infrastructure" >> "$OUTPUT"

# =========================
# DETECTION RULES
# =========================

echo "" >> "$OUTPUT"
echo "## Detection Rules Recommended" >> "$OUTPUT"
echo "- C2 beacon detection (frequency + interval analysis)" >> "$OUTPUT"
echo "- DNS long-label anomaly detection (>40 chars)" >> "$OUTPUT"
echo "- VPN geo-anomaly detection (ASN + country mismatch)" >> "$OUTPUT"
echo "- RDP role-based access control monitoring" >> "$OUTPUT"
echo "- DNS TXT high-frequency tunneling detection" >> "$OUTPUT"

# =========================
# RECOMMENDATIONS
# =========================

echo "" >> "$OUTPUT"
echo "## Recommendations" >> "$OUTPUT"
echo "Immediate:" >> "$OUTPUT"
echo "- isolate affected hosts" >> "$OUTPUT"
echo "- reset compromised credentials" >> "$OUTPUT"
echo "- block malicious domains and IPs" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "Short-term:" >> "$OUTPUT"
echo "- deploy behavioral detection rules" >> "$OUTPUT"
echo "- improve VPN logging and anomaly detection" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "Medium-term:" >> "$OUTPUT"
echo "- enforce email authentication (SPF/DKIM/DMARC)" >> "$OUTPUT"
echo "- improve DNS monitoring for tunneling detection" >> "$OUTPUT"

# =========================
# EVIDENCE CHAIN
# =========================

echo "" >> "$OUTPUT"
echo "## Evidence Chain" >> "$OUTPUT"
echo "- phishing_click.pcap → initial access" >> "$OUTPUT"
echo "- c2_beaconing.pcap → command & control behavior" >> "$OUTPUT"
echo "- full_timeline.pcap → VPN pivot" >> "$OUTPUT"
echo "- lateral_movement.pcap → internal propagation" >> "$OUTPUT"
echo "- dns_exfil.pcap → data exfiltration" >> "$OUTPUT"

# =========================
# CONTINUITY
# =========================

echo "" >> "$OUTPUT"
echo "## Continuity with 4x00" >> "$OUTPUT"
echo "- Credential compromise confirmed through network behavior" >> "$OUTPUT"
echo "- Attack timeline fully reconstructed end-to-end" >> "$OUTPUT"
echo "- DNS exfiltration expands original impact scope" >> "$OUTPUT"
echo "- Campaign infrastructure linked across all phases" >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "Done."
