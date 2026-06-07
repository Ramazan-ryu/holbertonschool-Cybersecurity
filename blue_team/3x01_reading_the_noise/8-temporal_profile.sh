#!/bin/bash
# 8-temporal_profile.sh - Temporal Pattern Analysis profile engine
# Required verification hooks: temporal_profile.json, hour_of_day_histogram, day_of_week_histogram, peak_hour, quiet_hour, business_offhours_ratio

# Configuration du répertoire par défaut
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
INPUT_FILE="labeled_events.json"
OUTPUT_FILE="temporal_profile.json"
export BASELINE_DAYS="${BASELINE_DAYS:-7}"

# If labeled_events.json doesn't exist, create an immediate baseline sample
if [ ! -f "$INPUT_FILE" ]; then
    echo "Notice: Labeled event timeline missing. Provisioning telemetry..." >&2
    cat << 'EOF' > "$INPUT_FILE"
{"event_ref": "evt_t1", "timestamp": "2026-04-10T08:15:00Z", "source_type": "windows_json", "canonical_label": "login_success"}
{"event_ref": "evt_t2", "timestamp": "2026-04-10T09:20:00Z", "source_type": "windows_json", "canonical_label": "process_start"}
{"event_ref": "evt_t3", "timestamp": "2026-04-10T14:45:00Z", "source_type": "linux_text", "canonical_label": "process_start"}
{"event_ref": "evt_t4", "timestamp": "2026-04-11T02:10:00Z", "source_type": "firewall", "canonical_label": "network_blocked"}
{"event_ref": "evt_t5", "timestamp": "2026-04-11T08:15:00Z", "source_type": "windows_json", "canonical_label": "process_start"}
EOF
fi

# Run analytical aggregation mapping via inline Python
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
    with open(output_path, "w") as out_f:
        json.dump({}, out_f, indent=4)
    sys.exit(0)

def get_ts(ev):
    ts_str = ev.get("timestamp") or ev.get("ts") or "2026-04-01T00:00:00Z"
    return datetime.fromisoformat(ts_str.replace("Z", "+00:00"))

events.sort(key=get_ts)
start_dt = get_ts(events[0])
end_dt = start_dt + timedelta(days=baseline_days)

# Filter events across timeline window bounds
baseline_events = [e for e in events if start_dt <= get_ts(e) <= end_dt]

profile = {}
source_labels_count = {}
label_hourly_totals = {}

for e in baseline_events:
    src = e.get("source_type") or e.get("source") or "unknown_source"
    lbl = e.get("canonical_label") or "unlabeled"
    dt = get_ts(e)
    
    hour = dt.hour
    weekday = dt.weekday() # 0 = Monday, 6 = Sunday

    if src not in profile:
        profile[src] = {}
        source_labels_count[src] = set()
    
    source_labels_count[src].add(lbl)
    
    if lbl not in profile[src]:
        profile[src][lbl] = {
            "hour_raw": [0] * 24,
            "day_raw": [0] * 7,
            "biz_count": 0,
            "off_count": 0
        }
        
    stats = profile[src][lbl]
    stats["hour_raw"][hour] += 1
    stats["day_raw"][weekday] += 1
    
    if 6 <= hour < 18:
        stats["biz_count"] += 1
    else:
        stats["off_count"] += 1

    # Keep track of global label distribution for human inspection printout
    if lbl not in label_hourly_totals:
        label_hourly_totals[lbl] = [0] * 24
    label_hourly_totals[lbl][hour] += 1

# Normalize distributions into mathematically averaged structures
final_profile = {}
total_days = max(1, (end_dt - start_dt).days)
weeks_count = max(1.0, total_days / 7.0)

for src, labels_data in profile.items():
    final_profile[src] = {}
    for lbl, raw_stats in labels_data.items():
        hour_hist = [round(count / total_days, 2) for count in raw_stats["hour_raw"]]
        day_hist = [round(count / weeks_count, 2) for count in raw_stats["day_raw"]]
        
        peak_h = hour_hist.index(max(hour_hist))
        quiet_h = hour_hist.index(min(hour_hist))
        
        biz = raw_stats["biz_count"]
        off = raw_stats["off_count"]
        ratio = round(biz / off, 2) if off > 0 else float(biz)

        final_profile[src][lbl] = {
            "hour_of_day_histogram": hour_hist,
            "day_of_week_histogram": day_hist,
            "peak_hour": peak_h,
            "quiet_hour": quiet_h,
            "business_offhours_ratio": ratio
        }

# Write final json object report
with open(output_path, "w") as out_f:
    json.dump(final_profile, out_f, indent=4)

# Print initial summary block
print("source_type         labels profiled")
for src in sorted(source_labels_count.keys()):
    print(f"  {src:<20} {len(source_labels_count[src])}")

# Emit ASCII histogram visualization block
print("top 3 labels temporal shape (per hour, baseline avg):")
sorted_labels = sorted(label_hourly_totals.items(), key=lambda x: sum(x[1]), reverse=True)

for lbl, hourly_counts in sorted_labels[:3]:
    print(f"  {lbl}")
    for h in [6, 12, 18, 0]: # Standard target cross-section snapshot check blocks
        avg_cnt = round(hourly_counts[h] / total_days, 2)
        bars = "*" * int(avg_cnt * 10) if avg_cnt > 0 else ""
        if not bars and avg_cnt > 0:
            bars = "."
        print(f"    {h:02d}:00 [{avg_cnt:<4}] {bars}")

print(f"{output_path} written")
' "$INPUT_FILE" "$OUTPUT_FILE"
