# HC-RED7 Threat Advisory — MedDefense Capstone

**Classification:** TLP:AMBER — Healthcare Sector Only
**Cluster ID:** HC-RED7
**Advisory Date:** 2026-04-08
**Severity:** HIGH

## Summary

HC-RED7 is an activity cluster targeting regional healthcare networks across the
central US. Three hospitals have confirmed intrusions in the past 6 weeks. The
cluster uses credential brute force for initial access, installs a service-based
persistence mechanism, and beacons at irregular intervals to blend with legitimate
healthcare vendor traffic.

## TTPs Observed

| Tactic | Technique | Notes |
|--------|-----------|-------|
| Initial Access | T1110.003 — Password Spraying | SSH and RDP targeting clinical workstations and patient DB hosts |
| Persistence | T1543.003 — Windows Service | Service name MedSyncHelper or WinHealthAgent |
| C2 | T1071.001 — Web Protocols | HTTPS to 198.51.100.73 or 198.51.100.82 on port 443 |
| Exfiltration | T1041 — Exfiltration Over C2 | Gradual data staging; bytes_out increasing over multiple beacon intervals |
| Privilege Escalation | T1078.002 — Domain Accounts | Credential reuse after brute force success |

## Network Indicators

- C2 IPs: 198.51.100.73, 198.51.100.82
- Brute force sources: 203.0.113.41, 203.0.113.42, 203.0.113.44
- C2 domains: update.medinfo-portal.net, portal.healthsync-cdn.com
- Beacon interval: irregular (8–15 minutes) to blend with medical device traffic

## Host Indicators

- Service name: MedSyncHelper or WinHealthAgent
- Service account: med_svc_update (or variant)
- Loader hash (SHA-256 prefix): 4a8e2c1f9d3b7e6a0c5f2d8b1e4a7c3f9d2b6e5a

## Recommended Actions

1. Review auth logs for brute force sources 203.0.113.41/42/44
2. Check for outbound HTTPS to 198.51.100.73 or 198.51.100.82
3. Audit Windows services matching MedSyncHelper or WinHealthAgent
4. Check for service accounts matching med_svc_update pattern
5. Review firewall rules permitting medical IoT devices to initiate internet connections

## Analyst Notes

- At least one infection vector has exploited approved vendor update processes as cover
- The cluster is patient in operation — initial access to first detection gap can exceed 72 hours
- Change ticket cross-referencing is essential: some C2 traffic has been mis-classified as vendor maintenance

---
*Source: H-ISAC Regional Advisory (fictionalized for lab exercise)*
