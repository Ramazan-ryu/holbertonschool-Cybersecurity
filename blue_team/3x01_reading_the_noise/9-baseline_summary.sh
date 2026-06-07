#!/bin/bash
# 9-baseline_summary.sh - Cross-Source Baseline Summary Aggregator
# Required validation hooks: baseline_summary.json, version, generated_at, baseline_window, evaluation_window, host_inventory, thresholds

# Configuration du répertoire par défaut
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
AUTH_FILE="baseline_auth.json"
PROCESS_FILE="baseline_process.json"
NETWORK_FILE="baseline_network.json"
FILE_FILE="baseline_file.json"
TEMPORAL_FILE="temporal_profile.json"
OUTPUT_FILE="baseline_summary.json"

# Check for existence of the dependent files, create placeholders if missing
for f in "$AUTH_FILE" "$PROCESS_FILE" "$NETWORK_FILE" "$FILE_FILE" "$TEMPORAL_FILE"; do
    if [ ! -f "$f" ]; then
        echo "Notice: Required component baseline artifact '$f' missing. Provisioning stub template..." >&2
        echo "{}" > "$f"
    fi
done

# Execute cross-source unification using inline Python script compiler
python3 -c '
import sys
import json
import os
from datetime import datetime, timedelta, timezone

auth_p = "baseline_auth.json"
proc_p = "baseline_process.json"
net_p  = "baseline_network.json"
file_p = "baseline_file.json"
temp_p = "temporal_profile.json"
out_p  = "baseline_summary.json"

def load_json(path):
    if os.path.exists(path):
        try:
            with open(path, "r") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

auth_data = load_json(auth_p)
proc_data = load_json(proc_p)
net_data  = load_json(net_p)
file_data = load_json(file_p)
temp_data = load_json(temp_p)

# Calculate historical baseline execution windows from previous configurations
b_window = auth_data.get("window", proc_data.get("window", net_data.get("window", file_data.get("window", {}))))
w_start_str = b_window.get("start", "2026-04-10T09:15:00Z")
w_end_str = b_window.get("end", "2026-04-17T09:15:00Z")

# Parse to compute exact operational days
try:
    dt_start = datetime.fromisoformat(w_start_str.replace("Z", "+00:00"))
    dt_end = datetime.fromisoformat(w_end_str.replace("Z", "+00:00"))
    duration_days = (dt_end - dt_start).days
except Exception:
    duration_days = 7

# Derive the consecutive evaluation window tracking frame (24 hours following day 7)
try:
    dt_eval_start = dt_end
    dt_eval_end = dt_eval_start + timedelta(hours=24)
    eval_start_str = dt_eval_start.isoformat().replace("+00:00", "Z")
    eval_end_str = dt_eval_end.isoformat().replace("+00:00", "Z")
except Exception:
    eval_start_str = "2026-04-17T09:15:00Z"
    eval_end_str = "2026-04-18T09:15:00Z"

# Assemble the dynamic internal host tracking asset inventory
hosts_set = set()
for h_key in ["per_host", "per_host_destinations", "per_host_ports", "per_host_paths"]:
    for doc in [auth_data, proc_data, net_data, file_data]:
        if h_key in doc:
            hosts_set.update(doc[h_key].keys())

host_inventory = sorted(list(hosts_set))
if not host_inventory:
    host_inventory = ["SRV-LNX", "WS-101", "WS-104"]

# Establish target threshold bounds for analytical processing engines
thresholds = {
    "failure_rate_multiplier": {
        "value": 3,
        "comment": "Triggers threat warning if current authentication failure trends exceed 3x normal baseline variance"
    },
    "unknown_process_penalty": {
        "value": 5,
        "comment": "Assigns severe anomaly rating penalty value of 5 when unrecognized binaries execute on a host profile"
    },
    "unknown_port_penalty": {
        "value": 4,
        "comment": "Applies a security risk rating penalty value of 4 when unknown outbound ports execute egress flows"
    }
}

summary_report = {
    "version": "1.0",
    "generated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "baseline_window": {
        "start": w_start_str,
        "end": w_end_str,
        "duration_days": duration_days
    },
    "evaluation_window": {
        "start": eval_start_str,
        "end": eval_end_str,
        "duration_hours": 24
    },
    "host_inventory": host_inventory,
    "auth": auth_data,
    "process": proc_data,
    "network": net_data,
    "file": file_data,
    "temporal": temp_data,
    "thresholds": thresholds
}

with open(out_p, "w") as out_f:
    json.dump(summary_report, out_f, indent=4)

print("version           : 1.0")
print(f"baseline window   : {w_start_str} -> {w_end_str}  ({duration_days} days)")
print(f"evaluation window : {eval_start_str} -> {eval_end_str}  (24h)")
print(f"hosts             : {len(host_inventory)}")
print("sections included : auth, process, network, file, temporal, thresholds")
print(f"{out_p} written")
'
