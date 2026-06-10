#!/bin/bash
# 10-timeline.sh
# Generates a compact, chronologically sorted timeline index from enriched log records.

ENRICHED_FILE="enriched_events.json"
OUTPUT_FILE="timeline_index.json"

if [ ! -f "$ENRICHED_FILE" ]; then
    echo "Error: Missing input data file $ENRICHED_FILE."
    exit 1
fi

python3 - << 'EOF'
import json
import sys
import os
from datetime import datetime

enriched_path = "enriched_events.json"
output_path = "timeline_index.json"

events = []
total_read = 0

# Helper to cleanly parse dates for internal sorting
def parse_ts(ts_str):
    try:
        return datetime.strptime(ts_str[:19].replace('T', ' '), '%Y-%m-%d %H:%M:%S')
    except Exception:
        return datetime.min

# Stage 1: Ingestion, dynamic field template mapping, and record indexing
with open(enriched_path, "r", encoding="utf-8") as infile:
    for line in infile:
        line = line.strip()
        if not line:
            continue
        
        total_read += 1
        record = json.loads(line)
        
        category = record.get("event_category", "")
        user = record.get("user") or record.get("event_data", {}).get("TargetUserName") or "unknown"
        action = record.get("action") or "attempted"
        
        # Build contextual summaries based on event categories
        if category == "authentication":
            summary = f"Authentication event for user '{user}': {action.upper()}"
        elif category == "process":
            proc = record.get("process_name") or record.get("event_data", {}).get("NewProcessName") or "unknown"
            summary = f"Process lifecycle event: {proc}"
        elif category == "network":
            src = record.get("src_ip") or "unknown"
            dst = record.get("dst_ip") or "unknown"
            summary = f"Network connection established: {src} -> {dst}"
        else:
            summary = record.get("raw_message", "No message payload overview provided").strip().split('\n')[0][:100]

        # Generate a deterministic record pointer index identifier fallback
        event_ref = record.get("record_id") or f"REF_{total_read:06d}"
        
        events.append({
            "timestamp": record.get("timestamp"),
            "hostname": record.get("hostname", "unknown"),
            "source_type": record.get("source_type", "unknown"),
            "event_category": category,
            "severity": record.get("severity", "low"),
            "summary": summary,
            "event_ref": event_ref,
            "_dt_obj": parse_ts(record.get("timestamp"))
        })

# Stage 2: Structural ascending sorting strategy
events.sort(key=lambda x: x["_dt_obj"])

# Stage 3: Rolling 1-second interval deduplication/aggregation window logic
collapsed_count = 0
timeline_entries = []

for ev in events:
    # Pop structural parsing helpers out from output data payload schemas
    dt_current = ev.pop("_dt_obj")
    
    if not timeline_entries:
        ev["count"] = 1
        timeline_entries.append((ev, dt_current))
        continue
    
    last_entry, dt_last = timeline_entries[-1]
    
    # Evaluate identical match logic parameters within a 1-second threshold
    time_delta = abs((dt_current - dt_last).total_seconds())
    
    if (time_delta <= 1.0 and 
        ev["hostname"] == last_entry["hostname"] and
        ev["source_type"] == last_entry["source_type"] and
        ev["event_category"] == last_entry["event_category"] and
        ev["summary"] == last_entry["summary"]):
        
        collapsed_count += 1
        if "count" not in last_entry:
            last_entry["count"] = 1
        last_entry["count"] += 1
    else:
        ev["count"] = 1
        timeline_entries.append((ev, dt_current))

# Stage 4: Write clean outputs
with open(output_path, "w", encoding="utf-8") as outfile:
    for entry, _ in timeline_entries:
        outfile.write(json.dumps(entry) + "\n")

first_ts = timeline_entries[0][0]["timestamp"] if timeline_entries else "N/A"
last_ts = timeline_entries[-1][0]["timestamp"] if timeline_entries else "N/A"

print(f"enriched events read : {total_read}")
print(f"collapsed duplicates : {collapsed_count}")
print(f"timeline entries     : {len(timeline_entries)}")
print(f"first entry          : {first_ts}")
print(f"last entry           : {last_ts}")
print("timeline_index.json written")
EOF
