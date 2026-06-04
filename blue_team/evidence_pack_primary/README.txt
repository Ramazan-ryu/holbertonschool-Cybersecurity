MEDDEFENSE HEALTH SYSTEMS — EVIDENCE PACK
==================================================
Pack type  : PRIMARY
Window     : 2026-03-18T00:00:00Z to 2026-03-25T23:59:59Z (8 days)
Baseline   : days 1-7  (2026-03-18T00:00:00Z to 2026-03-24T00:00:00Z)
Evaluation : day 8     (2026-03-25T00:00:00Z)
Total events (approx): 336320

SOURCE INVENTORY
------------------------------
windows/security.json, sysmon.json, powershell.json  (JSONL, evtx_dump format)
linux/auth.log, audit.log, syslog
network/firewall.csv (Unix epoch), suricata_eve.json (ISO8601 µs), pcap_summary.json (CST)
context/asset_inventory.json, network_zones.json
student_telemetry/windows_events.json, linux_events.json, attack_ground_truth.json
MANIFEST.sha256

PLANTED DIRTY DATA (PRIMARY PACK ONLY)
------------------------------
  Malformed timestamps   : 42 (auth.log)
  Duplicate events       : 127 (firewall.csv)
  Hostname case variants : 311 (syslog)
  Encoding errors        : 18 (syslog latin-1)
  Wrong timezone (+8h)   : 9 (security.json)
  Clock skew (+2h)       : bill-ws-09 all records
  Sysmon coverage gap    : clin-ws-05 02:15-03:00 on 2026-03-21

PLANTED SCENARIOS (DAY 8 ONLY)
------------------------------
  1. SSH brute force:     auth.log + firewall (01:15 UTC)
  2. Off-hours PHI:       security + sysmon on clin-ws-07 (02:17 UTC)
  3. Credential theft:    sysmon on clin-ws-12 (14:22 UTC)
  4. Medical egress:      firewall + suricata from med-mri-02 (11:44 UTC)

NOTES
  All timestamps are UTC unless noted. PCAP summaries use CST (UTC-6).
  auth.log uses traditional syslog format (no year).
  Firewall CSV column 1 is Unix epoch seconds.
  Do NOT hand-edit generated files; re-run the generator to change content.

Contact: james.chen@meddefense.local
