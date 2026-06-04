MEDDEFENSE HEALTH SYSTEMS — EVIDENCE PACK
==================================================
Pack type  : SECONDARY
Window     : 2026-04-01T00:00:00Z to 2026-04-08T23:59:59Z (8 days)
Baseline   : days 1-7  (2026-04-01T00:00:00Z to 2026-04-07T00:00:00Z)
Evaluation : day 8     (2026-04-08T00:00:00Z)
Total events (approx): 336112

SOURCE INVENTORY
------------------------------
windows/security.json, sysmon.json, powershell.json  (JSONL, evtx_dump format)
linux/auth.log, audit.log, syslog
network/firewall.csv (Unix epoch), suricata_eve.json (ISO8601 µs), pcap_summary.json (CST)
context/asset_inventory.json, network_zones.json
student_telemetry/windows_events.json, linux_events.json, attack_ground_truth.json
MANIFEST.sha256

NOTES
  All timestamps are UTC unless noted. PCAP summaries use CST (UTC-6).
  auth.log uses traditional syslog format (no year).
  Firewall CSV column 1 is Unix epoch seconds.
  Do NOT hand-edit generated files; re-run the generator to change content.

Contact: james.chen@meddefense.local
