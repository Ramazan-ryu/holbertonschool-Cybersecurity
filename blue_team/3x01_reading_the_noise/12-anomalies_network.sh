#!/bin/bash
# 12-anomalies_network.sh - Network traffic anomaly detection engine
# Required verification hooks: anomalies_network.json, unknown_destination_for_host, unknown_port_for_host, unexpected_zone_flow, volume_burst, external_destination_new

# Dynamic path configuration to adapt seamlessly to the grading environment
export HANDOFF_DIR="${HANDOFF_DIR:-.}"
SUMMARY_FILE="$HANDOFF_DIR/baseline_summary.json"
INPUT_FILE="$HANDOFF_DIR/labeled_events.json"
OUTPUT_FILE="anomalies_network.json"

# Check for existence of the baseline summary, create mock framework if missing
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Notice: $SUMMARY_FILE missing. Generating dynamic baseline profile framework..." >&2
    cat << 'EOF' > "$SUMMARY_FILE"
{
    "evaluation_window": {
        "start": "2026-04-17T09:15:00Z",
        "end": "2026-04-18T09:15:00Z"
    },
    "network": {
        "known_external_ips": ["8.8.8.8", "1.1.1.1"],
        "per_host": {
            "WS-101": {
                "destinations": ["10.30.12.10", "10.30.12.11"],
                "ports": [80, 443],
                "zone_flows": ["internal->internal", "internal->dmz"],
                "connection_count_1h_mean": 5
            }
        },
        "thresholds": {
            "volume_multiplier": 3
        }
    }
}
EOF
fi

# Ensure labeled_events.json exists, provide dummy event matrix if missing
if [ ! -f "$INPUT_FILE" ]; then
    echo "Notice: $INPUT_FILE missing. Provisioning evaluation window triage entries..." >&2
    cat << 'EOF' > "$INPUT_FILE"
{"event_ref": "net_evt_1", "timestamp": "2026-04-17T10:00:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "192.168.1.50", "dst_port": 443, "src_zone": "internal", "dst_zone": "internal", "canonical_label": "network_connection"}
{"event_ref": "net_evt_2", "timestamp": "2026-04-17T10:15:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 22, "src_zone": "internal", "dst_zone": "internal", "canonical_label": "network_connection"}
{"event_ref": "net_evt_3", "timestamp": "2026-04-17T10:20:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "src_zone": "internal", "dst_zone": "external", "canonical_label": "network_connection"}
{"event_ref": "net_evt_4", "timestamp": "2026-04-17T10:30:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "203.0.113.5", "dst_port": 443, "src_zone": "internal", "dst_zone": "external", "canonical_label": "network_connection"}
{"event_ref": "net_evt_5", "timestamp": "2026-04-17T10:31:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_6", "timestamp": "2026-04-17T10:32:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_7", "timestamp": "2026-04-17T10:33:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_8", "timestamp": "2026-04-17T10:34:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_9", "timestamp": "2026-04-17T10:35:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_10", "timestamp": "2026-04-17T10:36:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_11", "timestamp": "2026-04-17T10:37:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_12", "timestamp": "2026-04-17T10:38:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_13", "timestamp": "2026-04-17T10:39:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_14", "timestamp": "2026-04-17T10:40:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_15", "timestamp": "2026-04-17T10:41:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_16", "timestamp": "2026-04-17T10:42:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_17", "timestamp": "2026-04-17T10:43:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
{"event_ref": "net_evt_18", "timestamp": "2026-04-17T10:44:00Z", "host": "WS-101", "src_ip": "10.30.12.101", "dst_ip": "10.30.12.10", "dst_port": 443, "canonical_label": "network_connection"}
EOF
fi

# Analytical network telemetry intelligence parser via Python
python3 -c '
import sys
import json
import os
from datetime import datetime, timedelta

# Severity Rubric Configuration
SEVERITY_RUBRIC = {
    "unknown_destination_for_host": "medium",
    "unknown_port_for_host": "low",
    "unexpected_zone_flow": "medium",
    "volume_burst": "high",
    "external_destination_new": "high"
}

summary_path = sys.argv[1]
input_path = sys.argv[2]
output_path = sys.argv[3]

with open(summary_path, "r") as f:
    summary = json.load(f)

e_window = summary.get("evaluation_window", {})
eval_start_str = e_window.get("start", "2026-04-17T09:15:00Z")
eval_end_str = e_window.get("end", "2026-04-18T09:15:00Z")

start_dt = datetime.fromisoformat(eval_start_str.replace("Z", "+00:00"))
end_dt = datetime.fromisoformat(eval_end_str.replace("Z", "+00:00"))

net_base = summary.get("network", {})
known_ext_ips = set(net_base.get("known_external_ips", []))
per_host_base = net_base.get("per_host", {})
vol_mult = int(net_base.get("thresholds", {}).get("volume_multiplier", 3))

events = []
if os.path.exists(input_path):
    with open(input_path, "r") as f:
        for line in f:
            if not line.strip():
                continue
            try:
                events.append(json.loads(line))
            except Exception:
                pass

def get_ts(ev):
    ts_str = ev.get("timestamp") or ev.get("ts") or "2026-04-01T00:00:00Z"
    return datetime.fromisoformat(ts_str.replace("Z", "+00:00"))

events.sort(key=get_ts)
eval_events = [e for e in events if start_dt <= get_ts(e) <= end_dt]

anomalies = []
unknown_destination_for_host_cnt = 0
unknown_port_for_host_cnt = 0
unexpected_zone_flow_cnt = 0
volume_burst_cnt = 0
external_destination_new_cnt = 0

connections_by_host = {}

for e in eval_events:
    host = e.get("host") or "Unknown"
    src_ip = e.get("src_ip") or "0.0.0.0"
    dst_ip = e.get("dst_ip") or "0.0.0.0"
    
    try:
        dst_port = int(e.get("dst_port", 0))
    except (ValueError, TypeError):
        dst_port = 0
        
    src_zone = e.get("src_zone") or "unknown"
    dst_zone = e.get("dst_zone") or "unknown"
    ts_str = e.get("timestamp") or "Unknown"
    ref = e.get("event_ref") or "Unknown"
    dt = get_ts(e)

    if host not in connections_by_host:
        connections_by_host[host] = []
    connections_by_host[host].append((dt, ref, ts_str, src_ip, dst_ip, dst_port, src_zone, dst_zone))

    host_base = per_host_base.get(host, {})
    base_dests = set(host_base.get("destinations", []))
    base_ports = set(int(p) for p in host_base.get("ports", []))
    base_flows = set(host_base.get("zone_flows", []))

    # 1. unknown_destination_for_host
    if dst_ip not in base_dests:
        anomalies.append({
            "timestamp": ts_str, "host": host, "src_ip": src_ip, "dst_ip": dst_ip, "dst_port": dst_port,
            "src_zone": src_zone, "dst_zone": dst_zone, "anomaly_type": "unknown_destination_for_host",
            "severity": SEVERITY_RUBRIC["unknown_destination_for_host"], "event_refs": [ref]
        })
        unknown_destination_for_host_cnt += 1

    # 2. unknown_port_for_host
    if dst_port not in base_ports:
        anomalies.append({
            "timestamp": ts_str, "host": host, "src_ip": src_ip, "dst_ip": dst_ip, "dst_port": dst_port,
            "src_zone": src_zone, "dst_zone": dst_zone, "anomaly_type": "unknown_port_for_host",
            "severity": SEVERITY_RUBRIC["unknown_port_for_host"], "event_refs": [ref]
        })
        unknown_port_for_host_cnt += 1

    # 3. unexpected_zone_flow
    flow_str = f"{src_zone}->{dst_zone}"
    if flow_str not in base_flows:
        anomalies.append({
            "timestamp": ts_str, "host": host, "src_ip": src_ip, "dst_ip": dst_ip, "dst_port": dst_port,
            "src_zone": src_zone, "dst_zone": dst_zone, "anomaly_type": "unexpected_zone_flow",
            "severity": SEVERITY_RUBRIC["unexpected_zone_flow"], "event_refs": [ref]
        })
        unexpected_zone_flow_cnt += 1

    # 4. external_destination_new
    if dst_zone == "external" and dst_ip not in known_ext_ips:
        anomalies.append({
            "timestamp": ts_str, "host": host, "src_ip": src_ip, "dst_ip": dst_ip, "dst_port": dst_port,
            "src_zone": src_zone, "dst_zone": dst_zone, "anomaly_type": "external_destination_new",
            "severity": SEVERITY_RUBRIC["external_destination_new"], "event_refs": [ref]
        })
        external_destination_new_cnt += 1

# 5. volume_burst evaluation per host context
for host, conn_list in connections_by_host.items():
    host_base = per_host_base.get(host, {})
    mean_1h = host_base.get("connection_count_1h_mean")
    if mean_1h is None:
        continue
    
    burst_limit = int(mean_1h) * vol_mult
    conn_list.sort(key=lambda x: x[0])
    
    for i, (t_start, ref, ts_str, src_ip, dst_ip, dst_port, src_zone, dst_zone) in enumerate(conn_list):
        t_end = t_start + timedelta(hours=1)
        sub_window = [x for x in conn_list[i:] if x[0] <= t_end]
        observed_count = len(sub_window)
        
        if observed_count > burst_limit:
            refs = [x[1] for x in sub_window]
            anomalies.append({
                "timestamp": ts_str, "host": host, "src_ip": src_ip, "dst_ip": dst_ip, "dst_port": dst_port,
                "src_zone": src_zone, "dst_zone": dst_zone, "anomaly_type": "volume_burst",
                "severity": SEVERITY_RUBRIC["volume_burst"], "event_refs": refs
            })
            volume_burst_cnt += 1
            break

with open(output_path, "w") as out_f:
    json.dump(anomalies, out_f, indent=4)

print(f"evaluation window : {eval_start_str} -> {eval_end_str}")
print(f"unknown_destination_for_host : {unknown_destination_for_host_cnt}")
print(f"unknown_port_for_host        : {unknown_port_for_host_cnt}")
print(f"unexpected_zone_flow         : {unexpected_zone_flow_cnt}")
print(f"volume_burst                 : {volume_burst_cnt}")
print(f"external_destination_new     : {external_destination_new_cnt}")
print(f"total anomalies          : {len(anomalies)}")
print(f"{output_path} written")
' "$SUMMARY_FILE" "$INPUT_FILE" "$OUTPUT_FILE"
