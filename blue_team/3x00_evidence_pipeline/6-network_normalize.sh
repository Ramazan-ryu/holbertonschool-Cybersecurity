#!/bin/bash
# 6-network_normalize.sh
# Normalizes firewall logs, Suricata alerts, and PCAP summaries into a unified schema.

# Define directories
INPUT_DIR="$HOME/evidence_pack_primary/network"
# Fallback to current directory if primary pack path doesn't exist (for localized testing environments)
if [ ! -d "$INPUT_DIR" ]; then
    INPUT_DIR="."
fi

# Run the normalization engine via embedded Python script
python3 - << 'EOF'
import os
import csv
import json
from datetime import datetime, timedelta, timezone

input_dir = os.path.expanduser("~/evidence_pack_primary/network")
if not os.path.exists(input_dir):
    input_dir = "."

fw_path = os.path.join(input_dir, "firewall.csv")
suricata_path = os.path.join(input_dir, "suricata_eve.json")
pcap_path = os.path.join(input_dir, "pcap_summary.json")

network_events = []

# 1. Ingest and Normalize firewall.csv
fw_count = 0
if os.path.exists(fw_path):
    with open(fw_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                epoch = int(row['timestamp'])
                dt = datetime.fromtimestamp(epoch, tz=timezone.utc)
                ts_str = dt.strftime("%Y-%m-%dT%H:%M:%SZ")
                
                evt = {
                    "timestamp": ts_str,
                    "source_type": "firewall",
                    "event_category": "network",
                    "src_ip": row.get("src_ip"),
                    "src_port": int(row.get("src_port")) if row.get("src_port") else None,
                    "dst_ip": row.get("dst_ip"),
                    "dst_port": int(row.get("dst_port")) if row.get("dst_port") else None,
                    "protocol": row.get("protocol", "").lower(),
                    "action": row.get("action"),
                    "interface": row.get("interface"),
                    "rule_id": row.get("rule_id"),
                    "bytes_in": int(row.get("bytes_in")) if row.get("bytes_in") else None,
                    "bytes_out": int(row.get("bytes_out")) if row.get("bytes_out") else None
                }
                network_events.append(evt)
                fw_count += 1
            except Exception:
                pass

# 2. Ingest and Normalize suricata_eve.json
suricata_count = 0
if os.path.exists(suricata_path):
    with open(suricata_path, mode='r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
                ts_raw = obj.get("timestamp", "")
                if ts_raw:
                    dt = datetime.strptime(ts_raw[:19], "%Y-%m-%dT%H:%M:%S")
                    ts_str = dt.strftime("%Y-%m-%dT%H:%M:%SZ")
                else:
                    ts_str = None
                
                alert_obj = obj.get("alert", {})
                evt = {
                    "timestamp": ts_str,
                    "source_type": "suricata",
                    "event_category": "network_alert",
                    "src_ip": obj.get("src_ip"),
                    "src_port": int(obj.get("src_port")) if obj.get("src_port") is not None else None,
                    "dst_ip": obj.get("dest_ip"),
                    "dst_port": int(obj.get("dest_port")) if obj.get("dest_port") is not None else None,
                    "protocol": obj.get("proto", "").lower(),
                    "signature": alert_obj.get("signature"),
                    "severity": alert_obj.get("severity"),
                    "flow_id": obj.get("flow_id"),
                    "in_iface": obj.get("in_iface")
                }
                network_events.append(evt)
                suricata_count += 1
            except Exception:
                pass

# 3. Ingest and Normalize pcap_summary.json
pcap_count = 0
if os.path.exists(pcap_path):
    with open(pcap_path, mode='r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
                st_raw = obj.get("start_time", "")
                if st_raw:
                    dt_local = datetime.strptime(st_raw, "%m/%d/%Y %I:%M:%S %p")
                    dt_utc = dt_local + timedelta(hours=6)  # Adjust CST (UTC-6) to UTC
                    ts_str = dt_utc.strftime("%Y-%m-%dT%H:%M:%SZ")
                else:
                    ts_str = None
                
                evt = {
                    "timestamp": ts_str,
                    "source_type": "pcap",
                    "event_category": "network_flow",
                    "src_ip": obj.get("src_ip"),
                    "src_port": int(obj.get("src_port")) if obj.get("src_port") is not None else None,
                    "dst_ip": obj.get("dst_ip"),
                    "dst_port": int(obj.get("dst_port")) if obj.get("dst_port") is not None else None,
                    "protocol": obj.get("protocol", "").lower(),
                    "session_id": obj.get("session_id"),
                    "duration_seconds": obj.get("duration_seconds"),
                    "packets": obj.get("packets"),
                    "bytes_total": obj.get("bytes_total"),
                    "flags": obj.get("flags")
                }
                network_events.append(evt)
                pcap_count += 1
            except Exception:
                pass

# Output standalone network_events.json
with open("network_events.json", "w", encoding="utf-8") as f:
    for evt in network_events:
        f.write(json.dumps(evt) + "\n")

# Append to cumulative normalized_events.json
with open("normalized_events.json", "a", encoding="utf-8") as f:
    for evt in network_events:
        f.write(json.dumps(evt) + "\n")

# Format output to match requested padding and alignment
print(f"firewall.csv        :  {fw_count} records normalized")
print(f"suricata_eve.json   :   {suricata_count} records normalized")
print(f"pcap_summary.json   :   {pcap_count} records normalized")
print("appended to normalized_events.json")
print("network_events.json written")
EOF
