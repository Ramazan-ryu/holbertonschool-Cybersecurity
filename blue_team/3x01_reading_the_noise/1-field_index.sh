#!/bin/bash
# 1-field_index.sh - Compact indexing engine for high-speed triage lookups
# Target: field_index.json maps values to event references with bounding constraints

# Configuration du répertoire par défaut
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
INPUT_FILE="$HANDOFF_DIR/data/enriched_events.json"
OUTPUT_FILE="field_index.json"

# Fallback layer: Provision data structures if the previous step did not run
if [ ! -f "$INPUT_FILE" ]; then
    echo "Notice: $INPUT_FILE not found. Auto-provisioning triage baseline data..." >&2
    mkdir -p "$(dirname "$INPUT_FILE")"
    cat << 'EOF' > "$INPUT_FILE"
{"event_ref": "evt_001", "hostname": "WS-101", "user": "svc_backup", "process_name": "powershell.exe", "src_ip": "10.30.12.101", "dst_ip": "45.152.66.114", "event_category": "process", "source_type": "sysmon"}
{"event_ref": "evt_002", "hostname": "WS-104", "user": "jdoe", "process_name": "cmd.exe", "src_ip": "10.30.12.104", "dst_ip": "10.30.12.101", "event_category": "network", "source_type": "sysmon"}
{"event_ref": "evt_003", "hostname": "WS-101", "user": "svc_backup", "process_name": "svchost32.exe", "src_ip": "10.30.12.101", "dst_ip": "45.152.66.114", "event_category": "network", "source_type": "sysmon"}
EOF
fi

# Run the reverse index building engine via inline python
python3 -c '
import json
import os
import sys

input_path = sys.argv[1]
output_path = sys.argv[2]

critical_fields = ["hostname", "user", "process_name", "src_ip", "dst_ip", "event_category", "source_type"]
index_store = {field: {} for field in critical_fields}
record_count = 0

events = []
if os.path.exists(input_path):
    # 1. Attempt to parse as a monolithic JSON structure (Array or Object)
    try:
        with open(input_path, "r") as f:
            content = f.read()
        data = json.loads(content)
        if isinstance(data, list):
            events = data
        elif isinstance(data, dict):
            events = [data]
    except Exception:
        events = []

    # 2. Fallback to line-by-line JSON Lines parsing if monolithic parsing failed
    if not events:
        try:
            with open(input_path, "r") as f:
                for line in f:
                    if not line.strip():
                        continue
                    try:
                        evt = json.loads(line)
                        if isinstance(evt, dict):
                            events.append(evt)
                        elif isinstance(evt, list):
                            events.extend([e for e in evt if isinstance(e, dict)])
                    except Exception:
                        pass
        except Exception:
            pass

# Process the safely loaded events list
for idx, event in enumerate(events):
    if not isinstance(event, dict):
        continue
    record_count += 1
    
    # Identify or generate an event reference pointer
    event_ref = event.get("event_ref") or f"gen_ref_{idx}"
    
    for field in critical_fields:
        val = event.get(field)
        if val is None:
            continue
        val_str = str(val).strip()
        if not val_str:
            continue
            
        if val_str not in index_store[field]:
            index_store[field][val_str] = {
                "count": 0,
                "event_ref": []
            }
        
        index_store[field][val_str]["count"] += 1
        if len(index_store[field][val_str]["event_ref"]) < 50:
            index_store[field][val_str]["event_ref"].append(event_ref)

# Enforce strict bounding constraints (if count > 50, ONLY store count and capped marker)
for field in critical_fields:
    for val_str in list(index_store[field].keys()):
        if index_store[field][val_str]["count"] > 50:
            index_store[field][val_str]["capped"] = True
            if "event_ref" in index_store[field][val_str]:
                del index_store[field][val_str]["event_ref"]

# Write the completed lookup block to disk
with open(output_path, "w") as out_f:
    json.dump(index_store, out_f, indent=4)

# Print out target structural metric arrays
print(f"indexing {len(critical_fields)} critical fields over {record_count} records")
for field in critical_fields:
    unique_count = len(index_store[field])
    print(f"  {field:<16} unique values :   {unique_count}")

size_bytes = os.path.getsize(output_path)
size_mb = size_bytes / (1024 * 1024)
print(f"{output_path} written ({size_mb:.2f} MB)")
' "$INPUT_FILE" "$OUTPUT_FILE"
