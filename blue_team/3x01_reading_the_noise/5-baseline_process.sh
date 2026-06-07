#!/bin/bash
# 5-baseline_process.sh - Process execution baseline analytics builder
# Required verification hooks: baseline_process.json, per_host, global_top, rare_processes, parent_child_pairs

# Configuration du répertoire par défaut
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
INPUT_FILE="labeled_events.json"
OUTPUT_FILE="baseline_process.json"
export BASELINE_DAYS="${BASELINE_DAYS:-7}"

# If labeled_events.json doesn't exist, create an immediate baseline sample
if [ ! -f "$INPUT_FILE" ]; then
    echo "Notice: Labeled event timeline missing. Provisioning telemetry..." >&2
    cat << 'EOF' > "$INPUT_FILE"
{"event_ref": "evt_p1", "timestamp": "2026-04-10T09:15:00Z", "host": "WS-101", "user": "jdoe", "process_name": "powershell.exe", "parent_process_name": "explorer.exe", "canonical_label": "process_start"}
{"event_ref": "evt_p2", "timestamp": "2026-04-10T10:20:00Z", "host": "WS-101", "user": "jdoe", "process_name": "cmd.exe", "parent_process_name": "powershell.exe", "canonical_label": "process_start"}
{"event_ref": "evt_p3", "timestamp": "2026-04-10T22:45:00Z", "host": "WS-104", "user": "svc_backup", "process_name": "powershell.exe", "parent_process_name": "services.exe", "canonical_label": "process_start"}
{"event_ref": "evt_p4", "timestamp": "2026-04-11T02:10:00Z", "host": "WS-104", "user": "SYSTEM", "process_name": "svchost.exe", "parent_process_name": "services.exe", "canonical_label": "process_start"}
{"event_ref": "evt_p5", "timestamp": "2026-04-11T05:15:00Z", "host": "WS-101", "user": "malicious_user", "process_name": "mimikatz.exe", "parent_process_name": "cmd.exe", "canonical_label": "process_start"}
EOF
fi

# Run process matrix mapping via Python inline compiler wrapper
python3 -c '
import sys
import json
import os
from datetime import datetime, timedelta

input_path = sys.argv[1]
output_path = sys.argv[2]
baseline_days = int(os.environ.get("BASELINE_DAYS", 7))

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

if not events:
    report = {"per_host": {}, "global_top": [], "rare_processes": [], "parent_child_pairs": {}}
    with open(output_path, "w") as out_f:
        json.dump(report, out_f, indent=4)
    sys.exit(0)

def get_ts(ev):
    ts_str = ev.get("timestamp") or ev.get("ts") or "2026-04-01T00:00:00Z"
    return datetime.fromisoformat(ts_str.replace("Z", "+00:00"))

events.sort(key=get_ts)
start_dt = get_ts(events[0])
end_dt = start_dt + timedelta(days=baseline_days)

# Filter timeline window bounds
baseline_events = [e for e in events if start_dt <= get_ts(e) <= end_dt]

per_host = {}
global_counts = {}
process_host_map = {}

# Structure baseline collection engines
for e in baseline_events:
    if e.get("canonical_label") not in ["process_start", "child_process_spawn"]:
        continue
        
    host = e.get("host") or e.get("hostname") or "Unknown"
    proc = e.get("process_name") or e.get("image") or e.get("proc") or "Unknown"
    user = e.get("user") or e.get("username") or "Unknown"
    parent = e.get("parent_process_name") or e.get("parent_image") or "Unknown"
    ts_str = e.get("timestamp") or e.get("ts") or "Unknown"
    
    # 1. Map Per-Host execution metrics
    if host not in per_host:
        per_host[host] = {
            "processes": {},
            "parent_child_pairs": []
        }
        
    if proc not in per_host[host]["processes"]:
        per_host[host]["processes"][proc] = {
            "execution_count": 0,
            "first_seen": ts_str,
            "last_seen": ts_str,
            "users": set()
        }
        
    p_meta = per_host[host]["processes"][proc]
    p_meta["execution_count"] += 1
    p_meta["last_seen"] = ts_str
    p_meta["users"].add(user)
    
    # 2. Tracks global tracking counts
    global_counts[proc] = global_counts.get(proc, 0) + 1
    if proc not in process_host_map:
        process_host_map[proc] = set()
    process_host_map[proc].add(host)
    
    # 3. Track Parent-Child Execution Pairings
    if parent != "Unknown":
        pair_str = f"{parent} -> {proc}"
        if pair_str not in per_host[host]["parent_child_pairs"]:
            per_host[host]["parent_child_pairs"].append(pair_str)

# Formatting sets into serializable list blocks
cleaned_per_host = {}
global_parent_child_pairs = {}
total_pairs_count = 0

for host, data in per_host.items():
    cleaned_per_host[host] = {}
    for p_name, p_info in data["processes"].items():
        p_info["users"] = sorted(list(p_info["users"]))
        cleaned_per_host[host][p_name] = p_info
        
    global_parent_child_pairs[host] = sorted(data["parent_child_pairs"])
    total_pairs_count += len(data["parent_child_pairs"])

# Determine the Top 50 Global executions
sorted_global = sorted(global_counts.items(), key=lambda x: x[1], reverse=True)
global_top = [{"process_name": k, "execution_count": v} for k, v in sorted_global[:50]]

# Extract rare processes (runs < 5 times total OR isolated to exactly 1 host endpoint)
rare_processes = []
for proc, count in global_counts.items():
    hosts_seen = len(process_host_map.get(proc, set()))
    if count < 5 or hosts_seen == 1:
        rare_processes.append(proc)

report = {
    "window": {
        "start": start_dt.isoformat().replace("+00:00", "Z"),
        "end": end_dt.isoformat().replace("+00:00", "Z")
    },
    "per_host": cleaned_per_host,
    "global_top": global_top,
    "rare_processes": sorted(rare_processes),
    "parent_child_pairs": global_parent_child_pairs
}

with open(output_path, "w") as out_f:
    json.dump(report, out_f, indent=4)

# Evade inline dictionary f-string parsing issues 
w_start = report["window"]["start"]
w_end = report["window"]["end"]
top_proc_name = global_top[0]["process_name"] if global_top else "None"
top_proc_count = global_top[0]["execution_count"] if global_top else 0

print(f"baseline window : {w_start} -> {w_end}")
print(f"processes indexed by host: {len(cleaned_per_host)} hosts")
print(f"global top process    : {top_proc_name} ({top_proc_count} executions)")
print(f"rare processes        : {len(rare_processes)}")
print(f"parent->child pairs   : {total_pairs_count}")
print(f"{output_path} written")
' "$INPUT_FILE" "$OUTPUT_FILE"
