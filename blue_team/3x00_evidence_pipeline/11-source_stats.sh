#!/bin/bash
# 11-source_stats.sh
# Generates high-fidelity per-source type analytics and baseline metric health indicators.

ENRICHED_FILE="enriched_events.json"
OUTPUT_FILE="source_stats.json"

if [ ! -f "$ENRICHED_FILE" ]; then
    echo "Error: Missing input dataset file $ENRICHED_FILE."
    exit 1
fi

python3 - << 'EOF'
import json
import os
import sys
from datetime import datetime
from collections import Counter, defaultdict

input_path = "enriched_events.json"
output_path = "source_stats.json"

# Internal metric data storage mapping structure configuration arrays
sources_data = defaultdict(list)
global_events = []

def parse_iso(ts_str):
    if not ts_str:
        return None
    try:
        # Standardizes internal sub-second precision to fit flat tracking schemas cleanly
        clean_ts = ts_str.split('.')[0].replace('Z', '')
        if '+' in clean_ts:
            clean_ts = clean_ts.split('+')[0]
        return datetime.strptime(clean_ts[:19].replace('T', ' '), '%Y-%m-%d %H:%M:%S')
    except Exception:
        return None

# Stage 1: Records ingestion and linear sorting stream parsing allocation
with open(input_path, "r", encoding="utf-8") as infile:
    for line in infile:
        line = line.strip()
        if not line:
            continue
        
        record = json.loads(line)
        src_type = record.get("source_type", "unknown")
        ts_obj = parse_iso(record.get("timestamp"))
        
        if not ts_obj:
            continue
            
        payload = {
            "ts": ts_obj,
            "ts_str": record.get("timestamp"),
            "host": record.get("hostname", "unknown"),
            "category": record.get("event_category", "unknown")
        }
        
        sources_data[src_type].append(payload)
        global_events.append(payload)

# Chronologically sort the partitioned buffers to enable window metric lookups
for src in sources_data:
    sources_data[src].sort(key=lambda x: x["ts"])
global_events.sort(key=lambda x: x["ts"])

stats_out = {}

def build_metrics_summary(events_list):
    if not events_list:
        return {}
        
    count = len(events_list)
    first_ev = events_list[0]["ts_str"]
    last_ev = events_list[-1]["ts_str"]
    
    # Calculate unique hosts tracking metrics metrics arrays maps
    hosts = set(e["host"] for e in events_list)
    
    # Top 5 event categories profiling compilation
    categories = [e["category"] for e in events_list]
    cat_counts = Counter(categories).most_common(5)
    top_categories = {k: v for k, v in cat_counts}
    
    # Ingestion Velocity: Event tracking rate calculation over total tracking lifespan span hour delta
    time_span_seconds = (events_list[-1]["ts"] - events_list[0]["ts"]).total_seconds()
    time_span_hours = time_span_seconds / 3600.0
    
    if time_span_hours > 0:
        ev_per_hour = int(round(count / time_span_hours))
    else:
        ev_per_hour = count
        
    # Coverage Stream Gap Isolation Analytics Loop
    max_gap_minutes = 0.0
    for i in range(1, len(events_list)):
        delta_mins = (events_list[i]["ts"] - events_list[i-1]["ts"]).total_seconds() / 60.0
        if delta_mins > max_gap_minutes:
            max_gap_minutes = delta_mins
            
    return {
        "record_count": count,
        "first_event": first_ev,
        "last_event": last_ev,
        "unique_hosts": len(hosts),
        "top_event_categories": top_categories,
        "events_per_hour": ev_per_hour,
        "coverage_gap": int(round(max_gap_minutes))
    }

# Process specific logs data sets metrics configurations
for src_type, ev_list in sources_data.items():
    stats_out[src_type] = build_metrics_summary(ev_list)

# Process entire overall unified global metrics collection profiles summaries
stats_out["overall"] = build_metrics_summary(global_events)

# Write output file to disk space configuration parameters
with open(output_path, "w", encoding="utf-8") as outfile:
    json.dump(stats_out, outfile, indent=2)

# Stage 2: Emit formatted console verification matrix reporting dashboards matching execution requirements
print(f"{'source':<18}{'records':<11}{'hosts':<8}{'ev/hour':<10}{'max_gap(min)'}")

ordered_sources = ["windows_json", "linux_text", "firewall", "suricata_alert", "pcap_flow"]
for src in ordered_sources:
    if src in stats_out:
        s = stats_out[src]
        print(f"{src:<18}{s['record_count']:<11}{s['unique_hosts']:<8}{s['events_per_hour']:<10}{s['coverage_gap']}")
    else:
        # Fallback padding output display for mock validation states
        print(f"{src:<18}{0:<11}{0:<8}{0:<10}{0}")

# Output line for standard metrics trackers total parameters mapping sets
if "overall" in stats_out:
    o = stats_out["overall"]
    print(f"{'overall':<18}{o['record_count']:<11}{o['unique_hosts']:<8}{o['events_per_hour']:<10}{o['coverage_gap']}")

print("source_stats.json written")
EOF
