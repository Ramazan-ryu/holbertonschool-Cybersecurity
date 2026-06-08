#!/usr/bin/bash
# 0-queue_assessment.sh - SOC Queue Triage Assessment & Schema Validation Engine
# Strictly executes under Ubuntu 22.04 LTS and passes shellcheck validation

# Safely read dependency paths from environment variables, fallback to local user directories
CATALOG_DIR="${CATALOG_DIR:-$HOME/3x02_package/detection_catalog}"
TRIAGE_PKG="${TRIAGE_PKG:-$HOME/3x03_package/triage_package}"

# Ensure output triage package directory exists safely relative to the user's home
mkdir -p "$TRIAGE_PKG"

# Python execution core targeting strict error handling (-W error)
python3 -W error - << 'EOF'
import os
import sys
import json
from datetime import datetime
from collections import Counter, defaultdict

def run_assessment():
    # Fetch environment variables dynamically parsed from the shell layer
    catalog_dir = os.getenv("CATALOG_DIR", os.path.expanduser("~/3x02_package/detection_catalog"))
    triage_pkg = os.getenv("TRIAGE_PKG", os.path.expanduser("~/3x03_package/triage_package"))
    
    queue_path = os.path.join(catalog_dir, "alerts", "alert_queue.json")
    output_path = "queue_assessment.json"

    # Verify critical file pathing cleanly
    if not os.path.exists(queue_path):
        print(f"[-] Critical Error: alert_queue.json not found at {queue_path}", file=sys.stderr)
        print(f"[*] Hint: Ensure $CATALOG_DIR or your local folder structure matches.", file=sys.stderr)
        sys.exit(1)

    with open(queue_path, 'r') as f:
        queue_data = json.load(f)
        
    # Manual validation schema tracking
    validation_errors = []
    required_fields = ["alert_id", "rule_id", "priority_score", "hostname", "event_summary"]
    
    for idx, alert in enumerate(queue_data):
        missing = [field for field in required_fields if field not in alert]
        if missing:
            validation_errors.append({
                "index": idx,
                "alert_id": alert.get("alert_id", "UNKNOWN"),
                "missing_fields": missing
            })

    # Data collection matrices
    queue_size = len(queue_data)
    priority_bands = {"critical": 0, "high": 0, "medium": 0, "low": 0}
    rule_counter = Counter()
    host_counter = Counter()
    host_scores = defaultdict(int)
    tactic_set = set()
    timestamps = []

    for alert in queue_data:
        score = alert.get("priority_score", 0)
        if score >= 20:
            priority_bands["critical"] += 1
        elif 10 <= score <= 19:
            priority_bands["high"] += 1
        elif 5 <= score <= 9:
            priority_bands["medium"] += 1
        elif 1 <= score <= 4:
            priority_bands["low"] += 1

        rule_id = alert.get("rule_id", "UNKNOWN_RULE")
        rule_counter[rule_id] += 1
        
        hostname = alert.get("hostname", "UNKNOWN_HOST")
        host_counter[hostname] += 1
        host_scores[hostname] += score

        tags = alert.get("tags", [])
        if isinstance(tags, list):
            for tag in tags:
                if "tactic:" in tag.lower():
                    tactic_set.add(tag.split(":")[-1].strip().lower())
        elif isinstance(tags, dict):
            tactic = tags.get("tactic")
            if tactic:
                tactic_set.add(tactic.lower())

        evt_summary = alert.get("event_summary", {})
        ts = evt_summary.get("timestamp")
        if ts:
            timestamps.append(ts)

    if timestamps:
        sorted_ts = sorted(timestamps)
        start_time = sorted_ts[0]
        end_time = sorted_ts[-1]
    else:
        start_time, end_time = "N/A", "N/A"

    by_rule_sorted = dict(rule_counter.most_common())
    by_hostname_sorted = dict(host_counter.most_common())
    
    top_targets_list = sorted(host_scores.items(), key=lambda x: x[1], reverse=True)[:3]
    top_targets = [{"hostname": h, "cumulative_score": s} for h, s in top_targets_list]

    # Map out strict output JSON architecture
    assessment_output = {
        "queue_size": queue_size,
        "validation_errors": validation_errors,
        "by_priority_band": priority_bands,
        "by_rule": by_rule_sorted,
        "by_hostname": by_hostname_sorted,
        "by_attack_tactic": list(tactic_set),
        "time_span": {
            "start": start_time,
            "end": end_time
        },
        "top_targets": top_targets
    }

    with open(output_path, 'w') as out_f:
        json.dump(assessment_output, out_f, indent=2)
        out_f.write("\n")

    # Generate Shift Briefing format directly to stdout
    current_date = datetime.utcnow().strftime("%Y-%m-%d")
    print(f"=== SHIFT BRIEFING {current_date} ===")
    print(f"queue size           : {queue_size} alerts")
    print(f"validation errors    : {len(validation_errors)}")
    print(f"time span            : {start_time} -> {end_time}")
    print("priority bands")
    print(f"  critical  : {priority_bands['critical']}")
    print(f"  high      : {priority_bands['high']}")
    print(f"  medium    : {priority_bands['medium']}")
    print(f"  low       : {priority_bands['low']}")
    
    print("top rules (5)")
    for rule, count in rule_counter.most_common(5):
        print(f"  {rule:<34} {count}")
        
    print("top hosts (3 by cumulative score)")
    for host, score in top_targets_list:
        print(f"  {host:<15} score {score}")
        
    print(f"attack tactics covered : {len(tactic_set)}")
    print("queue_assessment.json written")

if __name__ == '__main__':
    run_assessment()
EOF
