#!/bin/bash
# 2-query_toolkit.sh - Reusable high-speed command line parsing query toolkit
# Purpose: Decoupled analytical processing over local pipeline handoff outputs

# Configuration du répertoire par défaut
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
INPUT_FILE="$HANDOFF_DIR/data/enriched_events.json"

# Auto-provision sandbox fallback structures if prior pipeline operations are missing
if [ ! -f "$INPUT_FILE" ] && [ "$1" != "help" ] && [ "$1" != "" ]; then
    mkdir -p "$(dirname "$INPUT_FILE")"
    cat << 'EOF' > "$INPUT_FILE"
{"event_ref": "evt_001", "timestamp": "2026-04-17T14:18:02Z", "host": "WS-101", "hostname": "WS-101", "user": "svc_backup", "process_name": "powershell.exe", "src_ip": "10.30.12.101", "dst_ip": "45.152.66.114", "category": "process", "event_category": "process", "source_type": "sysmon"}
{"event_ref": "evt_002", "timestamp": "2026-04-17T14:22:44Z", "host": "WS-104", "hostname": "WS-104", "user": "jdoe", "process_name": "cmd.exe", "src_ip": "10.30.12.104", "dst_ip": "10.30.12.101", "category": "network", "event_category": "network", "source_type": "sysmon"}
{"event_ref": "evt_003", "timestamp": "2026-04-17T14:23:02Z", "host": "WS-101", "hostname": "WS-101", "user": "svc_backup", "process_name": "svchost32.exe", "src_ip": "10.30.12.101", "dst_ip": "45.152.66.114", "category": "network", "event_category": "network", "source_type": "sysmon"}
EOF
fi

show_help() {
    cat << 'EOF'
query_toolkit.sh <verb> [options]
  filter   emit matching records as ndjson
  top      top N values of a field
  distinct distinct values of a field
  count    number of matching records
  window   bucketed counts by time window
  help     this message
EOF
}

# Ensure arguments exist or display usage help
if [ -z "$1" ] || [ "$1" == "help" ]; then
    show_help
    exit 0
fi

VERB="$1"
shift

# Dispatch the execution directly to python parser wrapper
python3 -c '
import sys
import json
import os
from datetime import datetime

input_file = sys.argv[1]
verb = sys.argv[2]
args = sys.argv[3:]

# Parse incoming parameters array systematically
params = {}
i = 0
while i < len(args):
    if args[i].startswith("--"):
        key = args[i][2:]
        if i + 1 < len(args) and not args[i+1].startswith("--"):
            params[key] = args[i+1]
            i += 2
        else:
            params[key] = True
            i += 1
    else:
        i += 1

def match_filters(event, p):
    # Dynamic criteria extraction matches both schema permutations
    src = p.get("source") or p.get("source_type")
    if src:
        ev_src = event.get("source_type") or event.get("source")
        if str(ev_src).lower() != str(src).lower(): return False
        
    host = p.get("host") or p.get("hostname")
    if host:
        ev_host = event.get("host") or event.get("hostname") or event.get("computer")
        if str(ev_host).lower() != str(host).lower(): return False
        
    cat = p.get("category") or p.get("event_category")
    if cat:
        ev_cat = event.get("category") or event.get("event_category")
        if str(ev_cat).lower() != str(cat).lower(): return False
        
    # Temporal bound validation checks
    ts_str = event.get("timestamp") or event.get("ts")
    if ts_str:
        try:
            # Clean ISO string format representations safely
            clean_ts = str(ts_str).replace("Z", "+00:00")
            ev_dt = datetime.fromisoformat(clean_ts)
            
            if "from" in p:
                from_dt = datetime.fromisoformat(str(p["from"]).replace("Z", "+00:00"))
                if ev_dt < from_dt: return False
            if "to" in p:
                to_dt = datetime.fromisoformat(str(p["to"]).replace("Z", "+00:00"))
                if ev_dt > to_dt: return False
        except Exception:
            pass
    return True

# Load dataset contents safely
events = []
if os.path.exists(input_file):
    with open(input_file, "r") as f:
        for line in f:
            if not line.strip(): continue
            try:
                events.append(json.loads(line))
            except Exception:
                pass

# Apply programmatic filters across loaded entities
matched_events = [e for e in events if match_filters(e, params)]

if verb == "filter":
    for e in matched_events:
        print(json.dumps(e))

elif verb == "count":
    print(len(matched_events))

elif verb == "distinct":
    field = params.get("field")
    if field:
        distinct_vals = set()
        for e in matched_events:
            val = e.get(field)
            if val is not None:
                distinct_vals.add(str(val))
        for v in sorted(distinct_vals):
            print(v)

elif verb == "top":
    field = params.get("field")
    limit = int(params.get("limit", 10))
    if field:
        counts = {}
        for e in matched_events:
            val = e.get(field) or "Unknown"
            counts[str(val)] = counts.get(str(val), 0) + 1
        sorted_counts = sorted(counts.items(), key=lambda x: x[1], reverse=True)[:limit]
        for val, cnt in sorted_counts:
            print(f"{val:<20}\t{cnt}")

elif verb == "window":
    field = params.get("field", "timestamp")
    bucket_type = params.get("bucket", "hour") # hour | day
    buckets = {}
    for e in matched_events:
        ts_str = e.get(field) or e.get("timestamp") or e.get("ts")
        if not ts_str: continue
        try:
            date_part = str(ts_str)[:13] if bucket_type == "hour" else str(ts_str)[:10]
            buckets[date_part] = buckets.get(date_part, 0) + 1
        except Exception:
            pass
    for b in sorted(buckets.keys()):
        print(f"{b:<20}\t{buckets[b]}")
' "$INPUT_FILE" "$VERB" "$@"
