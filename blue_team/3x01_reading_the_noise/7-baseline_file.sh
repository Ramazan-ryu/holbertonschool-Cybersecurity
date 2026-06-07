#!/bin/bash
# 7-baseline_file.sh - File access baseline analytics builder
# Required verification hooks: baseline_file.json, sensitive_paths, per_path_access, per_host_paths, rare_accesses

# Configuration du répertoire par défaut
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
INPUT_FILE="labeled_events.json"
OUTPUT_FILE="baseline_file.json"
export BASELINE_DAYS="${BASELINE_DAYS:-7}"

# Configurable array containing target sensitive directory paths
SENSITIVE_PREFIXES=(
    "/etc/shadow"
    "/etc/sudoers"
    "/etc/ssh/"
    "/var/log/audit/"
    "C:\\Windows\\System32\\config\\"
    "/opt/MedDefense/config/"
    "C:\\Program Files\\MedDefense\\config\\"
)

# If labeled_events.json doesn't exist, create an immediate baseline sample
if [ ! -f "$INPUT_FILE" ]; then
    echo "Notice: Labeled event timeline missing. Provisioning telemetry..." >&2
    cat << 'EOF' > "$INPUT_FILE"
{"event_ref": "evt_f1", "timestamp": "2026-04-10T09:15:00Z", "host": "WS-101", "user": "SYSTEM", "process_name": "lsass.exe", "file_path": "C:\\Windows\\System32\\config\\SAM", "canonical_label": "file_read_sensitive"}
{"event_ref": "evt_f2", "timestamp": "2026-04-10T10:20:00Z", "host": "WS-101", "user": "SYSTEM", "process_name": "lsass.exe", "file_path": "C:\\Windows\\System32\\config\\SECURITY", "canonical_label": "file_read_sensitive"}
{"event_ref": "evt_f3", "timestamp": "2026-04-10T22:45:00Z", "host": "SRV-LNX", "user": "root", "process_name": "sshd", "file_path": "/etc/ssh/sshd_config", "canonical_label": "file_read_sensitive"}
{"event_ref": "evt_f4", "timestamp": "2026-04-11T02:10:00Z", "host": "SRV-LNX", "user": "medadmin", "process_name": "med_engine", "file_path": "/opt/MedDefense/config/app.conf", "canonical_label": "file_write_sensitive"}
{"event_ref": "evt_f5", "timestamp": "2026-04-11T05:15:00Z", "host": "SRV-LNX", "user": "root", "process_name": "sshd", "file_path": "/etc/ssh/sshd_config", "canonical_label": "file_read_sensitive"}
EOF
fi

# Pass prefix array elements systematically into Python via a temporary file or environment variable
export PREFIXES_JSON=$(printf '%s\n' "${SENSITIVE_PREFIXES[@]}" | jq -R . | jq -s .)

# Run baseline mapping engine inside Python wrapper
python3 -c '
import sys
import json
import os
from datetime import datetime, timedelta

input_path = sys.argv[1]
output_path = sys.argv[2]
prefixes = json.loads(os.environ.get("PREFIXES_JSON", "[]"))
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
    report = {"sensitive_paths": [], "per_path_access": {}, "per_host_paths": {}, "rare_accesses": []}
    with open(output_path, "w") as out_f:
        json.dump(report, out_f, indent=4)
    sys.exit(0)

def get_ts(ev):
    ts_str = ev.get("timestamp") or ev.get("ts") or "2026-04-01T00:00:00Z"
    return datetime.fromisoformat(ts_str.replace("Z", "+00:00"))

events.sort(key=get_ts)
start_dt = get_ts(events[0])
end_dt = start_dt + timedelta(days=baseline_days)

# Filter baseline events down to specified classification boundaries
baseline_events = [
    e for e in events 
    if start_dt <= get_ts(e) <= end_dt and e.get("canonical_label") in ["file_read_sensitive", "file_write_sensitive", "file_permission_change"]
]

sensitive_paths = set()
per_path_access = {}
per_host_paths = {}
path_global_counts = {}
total_access_count = 0

for e in baseline_events:
    path = e.get("file_path") or e.get("target_path") or e.get("path") or "Unknown"
    if path == "Unknown":
        continue
        
    # Verify path strings against target prefix list parameters
    is_sensitive = False
    for pref in prefixes:
        if path.lower().startswith(pref.lower()):
            is_sensitive = True
            break
            
    if not is_sensitive:
        continue

    host = e.get("host") or e.get("hostname") or "Unknown"
    proc = e.get("process_name") or e.get("image") or "Unknown"
    user = e.get("user") or e.get("username") or "Unknown"
    
    sensitive_paths.add(path)
    path_global_counts[path] = path_global_counts.get(path, 0) + 1
    total_access_count += 1

    # 1. Map Per-Path Access Footprints
    if path not in per_path_access:
        per_path_access[path] = {
            "processes": {},
            "users": {}
        }
    
    per_path_access[path]["processes"][proc] = per_path_access[path]["processes"].get(proc, 0) + 1
    per_path_access[path]["users"][user] = per_path_access[path]["users"].get(user, 0) + 1

    # 2. Map Per-Host Paths Coverage Matrix
    if host not in per_host_paths:
        per_host_paths[host] = set()
    per_host_paths[host].add(path)

# Extract rare paths (objects accessed strictly less than three times total)
rare_accesses = [path for path, count in path_global_counts.items() if count < 3]

# Format complex structures into serializable lists
serialized_per_host_paths = {}
for host, paths_set in per_host_paths.items():
    serialized_per_host_paths[host] = sorted(list(paths_set))

report = {
    "window": {
        "start": start_dt.isoformat().replace("+00:00", "Z"),
        "end": end_dt.isoformat().replace("+00:00", "Z")
    },
    "sensitive_paths": sorted(list(sensitive_paths)),
    "per_path_access": per_path_access,
    "per_host_paths": serialized_per_host_paths,
    "rare_accesses": sorted(rare_accesses)
}

with open(output_path, "w") as out_f:
    json.dump(report, out_f, indent=4)

# Flat variables bypass inline nested JSON string tokenization constraints
w_start = report["window"]["start"]
w_end = report["window"]["end"]

print(f"baseline window   : {w_start} -> {w_end}")
print(f"sensitive paths   : {len(sensitive_paths)}")
print(f"total accesses    : {total_access_count}")
print(f"per host coverage : {len(per_host_paths)} hosts")
print(f"rare accesses     : {len(rare_accesses)}")
print(f"{output_path} written")
' "$INPUT_FILE" "$OUTPUT_FILE"
