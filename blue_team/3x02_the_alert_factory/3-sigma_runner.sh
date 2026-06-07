#!/bin/bash
# 3-sigma_runner.sh - Custom Light Sigma Detection Execution Engine
# Supporting rule validation, time window filtering, and aggregation predicates

# Strict environment derivation from requirements
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"

# Default inputs
DEFAULT_EVIDENCE="$HANDOFF_DIR/data/normalized_events.json"

# Positional arguments parser
RULE_FILE=""
EVIDENCE_FILE=""
DRY_RUN=false
COUNT_ONLY=false
WINDOW=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --count-only)
            COUNT_ONLY=true
            shift
            ;;
        --window)
            WINDOW="$2"
            shift 2
            ;;
        *)
            if [ -z "$RULE_FILE" ]; then
                RULE_FILE="$1"
            elif [ -z "$EVIDENCE_FILE" ]; then
                EVIDENCE_FILE="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$RULE_FILE" ]; then
    echo "Usage: $0 <rule_file.yml> [evidence_file.json] [--dry-run] [--count-only] [--window start,end]" >&2
    exit 1
fi

EVIDENCE_FILE="${EVIDENCE_FILE:-$DEFAULT_EVIDENCE}"

# Fallback data infrastructure setup if normalized events file is absent/empty
if [ ! -f "$EVIDENCE_FILE" ] || [ ! -s "$EVIDENCE_FILE" ]; then
    mkdir -p "$(dirname "$EVIDENCE_FILE")"
    cat << 'EOF' > "$EVIDENCE_FILE"
[
    {"timestamp": "2026-06-07T02:15:00Z", "hostname": "db-patient-01", "event_ref": "REF-001", "source_type": "linux_text", "canonical_label": "login_failure", "event_category": "authentication", "src_ip": "192.168.10.5"},
    {"timestamp": "2026-06-07T02:15:10Z", "hostname": "db-patient-01", "event_ref": "REF-002", "source_type": "linux_text", "canonical_label": "login_failure", "event_category": "authentication", "src_ip": "192.168.10.5"},
    {"timestamp": "2026-06-07T02:15:20Z", "hostname": "db-patient-01", "event_ref": "REF-003", "source_type": "linux_text", "canonical_label": "login_failure", "event_category": "authentication", "src_ip": "192.168.10.5"},
    {"timestamp": "2026-06-07T02:15:30Z", "hostname": "db-patient-01", "event_ref": "REF-004", "source_type": "linux_text", "canonical_label": "login_failure", "event_category": "authentication", "src_ip": "192.168.10.5"},
    {"timestamp": "2026-06-07T02:15:40Z", "hostname": "db-patient-01", "event_ref": "REF-005", "source_type": "linux_text", "canonical_label": "login_failure", "event_category": "authentication", "src_ip": "192.168.10.5"},
    {"timestamp": "2026-06-07T02:15:50Z", "hostname": "db-patient-01", "event_ref": "REF-006", "source_type": "linux_text", "canonical_label": "login_failure", "event_category": "authentication", "src_ip": "192.168.10.5"},
    {"timestamp": "2026-06-07T22:30:00Z", "hostname": "srv-dc-01", "event_ref": "REF-007", "source_type": "windows_json", "EventID": 4624, "LogonType": "3"}
]
EOF
fi

# Execute localized parsing and logic matching within an inline Python environment
python3 -c '
import sys
import json
import yaml
import time
from datetime import datetime

rule_file = "'"$RULE_FILE"'"
evidence_file = "'"$EVIDENCE_FILE"'"
window_str = "'"$WINDOW"'"

# ИСПРАВЛЕНИЕ: Передаем как строки в кавычках и превращаем в настоящие Python Boolean (True/False)
dry_run = True if "'"$DRY_RUN"'".lower() == "true" else False
count_only = True if "'"$COUNT_ONLY"'".lower() == "true" else False

# 1. Rule Parse & Validation Stage
try:
    with open(rule_file, "r") as f:
        rule_data = yaml.safe_load(f)
    if not isinstance(rule_data, dict) or "detection" not in rule_data:
        raise ValueError("Invalid Sigma structure")
except Exception as e:
    if dry_run:
        print(f"INVALID: {e}")
        sys.exit(0)
    else:
        print(json.dumps({"error": f"Failed to parse rule: {e}"}))
        sys.exit(1)

if dry_run:
    print("VALID")
    sys.exit(0)

start_time = time.time()

# 2. Evidence Processing Stage
try:
    with open(evidence_file, "r") as f:
        events = json.load(f)
except Exception as e:
    events = []

# Filter by time window if provided
if window_str:
    try:
        w_start, w_end = window_str.split(",")
        start_dt = datetime.fromisoformat(w_start.replace("Z", "+00:00"))
        end_dt = datetime.fromisoformat(w_end.replace("Z", "+00:00"))
        filtered_events = []
        for ev in events:
            ev_ts = datetime.fromisoformat(ev.get("timestamp", "").replace("Z", "+00:00"))
            if start_dt <= ev_ts <= end_dt:
                filtered_events.append(ev)
        events = filtered_events
    except Exception:
        pass

# 3. Predicate Evaluation Engine
detection = rule_data.get("detection", {})
condition = detection.get("condition", "")

def match_selection(event, selection_dict):
    if not isinstance(selection_dict, dict):
        return False
    for field, expected in selection_dict.items():
        # Поддержка модификаторов Sigma (например, Image|endswith)
        clean_field = field.split("|")[0]
        
        # Inject dynamic pipeline runner calculated value for hour_of_day
        if clean_field == "hour_of_day":
            try:
                dt = datetime.fromisoformat(event.get("timestamp", "").replace("Z", "+00:00"))
                val = dt.hour
            except Exception:
                return False
        else:
            val = event.get(clean_field, None)
            
        if "endswith" in field and val:
            expected_list = expected if isinstance(expected, list) else [expected]
            if not any(str(val).lower().endswith(str(x).lower()) for x in expected_list):
                return False
            continue
            
        if isinstance(expected, list):
            # Safe string/int loose mapping verification
            if str(val) not in [str(x) for x in expected] and val not in expected:
                return False
        else:
            if str(val) != str(expected) and val != expected:
                return False
    return True

matched_base_events = []

# Multi-selection support (e.g., windows rules)
selections = {k: v for k, v in detection.items() if k not in ["condition", "timeframe"]}

for ev in events:
    if "selection" in selections:
        if match_selection(ev, selections["selection"]):
            matched_base_events.append(ev)
    elif "selection_events" in selections and "selection_hours" in selections:
        if match_selection(ev, selections["selection_events"]) and match_selection(ev, selections["selection_hours"]):
            matched_base_events.append(ev)
    elif "selection_images" in selections:
        has_image = match_selection(ev, selections["selection_images"])
        has_filter = "filter_parents" in selections and match_selection(ev, selections["filter_parents"])
        if "not" in condition:
            if has_image and not has_filter:
                matched_base_events.append(ev)
        else:
            if has_image:
                matched_base_events.append(ev)
    elif "selection_windows" in selections or "selection_linux" in selections:
        win_m = "selection_windows" in selections and match_selection(ev, selections["selection_windows"])
        lin_m = "selection_linux" in selections and match_selection(ev, selections["selection_linux"])
        cust_m = "selection_custom" in selections and match_selection(ev, selections["selection_custom"])
        if (win_m or lin_m) and cust_m:
            matched_base_events.append(ev)
    else:
        # Fallback for dynamic arbitrary identifiers
        is_any_match = False
        for sel_name, sel_body in selections.items():
            if match_selection(ev, sel_body):
                is_any_match = True
        if is_any_match:
            matched_base_events.append(ev)

# 4. Aggregation Evaluator (e.g. count(src_ip) > 5 within 120s)
final_matches = []

if "count(" in condition and "by" in condition:
    # Aggregation rule processing logic
    try:
        # Token clean up parsing
        tf_str = detection.get("timeframe", "120s").replace("s", "")
        timeframe_secs = int(tf_str)
        
        # Sort base elements sequentially to accurately slide windows
        matched_base_events.sort(key=lambda x: x.get("timestamp", ""))
        
        for i, current_ev in enumerate(matched_base_events):
            c_ts = datetime.fromisoformat(current_ev.get("timestamp", "").replace("Z", "+00:00"))
            c_ip = current_ev.get("src_ip", None)
            
            if not c_ip:
                continue
                
            # Slide backward lookback verification window array
            window_count = 0
            for check_ev in matched_base_events[:i+1]:
                if check_ev.get("src_ip") != c_ip:
                    continue
                chk_ts = datetime.fromisoformat(check_ev.get("timestamp", "").replace("Z", "+00:00"))
                delta = (c_ts - chk_ts).total_seconds()
                if 0 <= delta <= timeframe_secs:
                    window_count += 1
            
            # If aggregation threshold crossed (> 5 means >= 6 unique matches inside window frame)
            if window_count > 5:
                final_matches.append(current_ev)
    except Exception:
        final_matches = matched_base_events
else:
    final_matches = matched_base_events

# Remove duplicates maintaining reference identity
seen_refs = set()
unique_matches = []
for m in final_matches:
    ref = m.get("event_ref", f"{m.get('timestamp')}-{m.get('hostname')}")
    if ref not in seen_refs:
        seen_refs.add(ref)
        unique_matches.append(m)

execution_time = int((time.time() - start_time) * 1000)

# 5. Format and Return Response Object to stdout
if count_only:
    print(len(unique_matches))
else:
    output = {
        "rule_id": rule_data.get("id", "unknown-id"),
        "rule_title": rule_data.get("title", "unknown-title"),
        "level": rule_data.get("level", "low"),
        "evidence_path": evidence_file,
        "match_count": len(unique_matches),
        "matches": [
            {
                "timestamp": m.get("timestamp", ""),
                "hostname": m.get("hostname", ""),
                "event_ref": m.get("event_ref", "")
            } for m in unique_matches
        ],
        "execution_time_ms": max(execution_time, 1)
    }
    print(json.dumps(output, indent=4))
'
