#!/bin/bash
# 0-queue_assessment.sh - Alert Queue Parsing, Validation, & Shift Briefing Engine

# Enforce strict path configurations with required default fallbacks
export CATALOG_DIR="${CATALOG_DIR:-$HOME/3x02_package/detection_catalog}"
export TRIAGE_PKG="${TRIAGE_PKG:-$HOME/3x03_package/triage_package}"

ALERT_QUEUE="$CATALOG_DIR/alerts/alert_queue.json"
ALERT_SCHEMA="$CATALOG_DIR/alerts/alert_queue_schema.json"
OUTPUT_JSON="queue_assessment.json"

# Operational safeguard: Validate file presence before execution loop
if [ ! -f "$ALERT_QUEUE" ] || [ ! -f "$ALERT_SCHEMA" ]; then
    echo "[-] Error: Required input catalog files missing in $CATALOG_DIR/alerts/"
    exit 1
fi

# Run analytical ingestion and validation via Python
python3 -c "
import os
import sys
import json
import re
from datetime import datetime

# Load input artifacts
with open('$ALERT_QUEUE', 'r') as f:
    queue = json.load(f)

with open('$ALERT_SCHEMA', 'r') as f:
    schema = json.load(f)

# 1. Structural Schema Validation Loop
# Simulates standard draft-07 JSON schema verification logic targeting mandatory fields
required_fields = schema.get('items', {}).get('required', [])
validation_errors = []
valid_alerts = []

for idx, alert in enumerate(queue):
    errors = []
    for field in required_fields:
        if field not in alert:
            errors.append(f'Missing required field: {field}')
    
    # Enforce basic type checking for nested summary
    summary = alert.get('event_summary', {})
    if not isinstance(summary, dict) or 'timestamp' not in summary or 'hostname' not in summary:
        errors.append('Invalid or corrupted event_summary sub-schema structure')
        
    if errors:
        validation_errors.append({
            'alert_index': idx,
            'alert_id': alert.get('alert_id', 'unknown'),
            'reasons': errors
        })
    else:
        valid_alerts.append(alert)

# 2. Extract Ingestion Analytics & Distribution Counts
queue_size = len(queue)

by_priority_band = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
by_rule = {}
by_hostname = {}
by_attack_tactic = {}
cumulative_host_scores = {}
timestamps = []

# Map technique-to-tactic translations for analytical coverage mapping
tactic_mapping = {
    'T1003': 'Credential Access',
    'T1115': 'Collection',
    'T1048': 'Exfiltration',
    'T1110': 'Credential Access',
    'T1021': 'Lateral Movement',
    'T1053': 'Persistence',
    'T1071': 'Command and Control',
    'T1547': 'Persistence'
}

for alert in valid_alerts:
    score = float(alert.get('priority_score', 0.0))
    rule_id = alert.get('rule_id', 'unknown')
    rule_title = alert.get('rule_title', rule_id)
    
    summary = alert.get('event_summary', {})
    host = summary.get('hostname', 'unknown')
    ts_str = summary.get('timestamp')
    
    # Priority Band Profiling
    if score >= 20.0:
        by_priority_band['critical'] += 1
    elif score >= 10.0:
        by_priority_band['high'] += 1
    elif score >= 5.0:
        by_priority_band['medium'] += 1
    else:
        by_priority_band['low'] += 1
        
    # Rule distribution
    by_rule[rule_title] = by_rule.get(rule_title, 0) + 1
    
    # Host tracking maps
    by_hostname[host] = by_hostname.get(host, 0) + 1
    cumulative_host_scores[host] = cumulative_host_scores.get(host, 0.0) + score
    
    # Timestamp tracking
    if ts_str:
        timestamps.append(ts_str)
        
    # Extract MITRE ATT&CK tactics from technique prefixes
    techniques = alert.get('attack_techniques', [])
    for tech in techniques:
        base_tech = tech.split('.')[0]
        tactic = tactic_mapping.get(base_tech, 'Execution')
        by_attack_tactic[tactic] = by_attack_tactic.get(tactic, 0) + 1

# Time span evaluation
if timestamps:
    timestamps.sort()
    start_time = timestamps[0]
    end_time = timestamps[-1]
else:
    start_time, end_time = 'N/A', 'N/A'

# Sort and slice metrics
sorted_rules = sorted(by_rule.items(), key=lambda x: x[1], reverse=True)
sorted_hosts = sorted(by_hostname.items(), key=lambda x: x[1], reverse=True)

# Generate the top 3 target hosts based on cumulative score
top_targets_raw = sorted(cumulative_host_scores.items(), key=lambda x: x[1], reverse=True)[:3]
top_targets = {host: round(score, 1) for host, score in top_targets_raw}

# 3. Serialize Output Object State to queue_assessment.json
assessment_data = {
    'queue_size': queue_size,
    'validation_errors': validation_errors,
    'by_priority_band': by_priority_band,
    'by_rule': dict(sorted_rules),
    'by_hostname': dict(sorted_hosts),
    'by_attack_tactic': by_attack_tactic,
    'time_span': {'start': start_time, 'end': end_time},
    'top_targets': top_targets
}

with open('$OUTPUT_JSON', 'w') as out:
    json.dump(assessment_data, out, indent=4)

# 4. Print Executive Shift Briefing Console Dashboard
current_date = datetime.utcnow().strftime('%Y-%m-%d')
print(f'=== SHIFT BRIEFING {current_date} ===')
print(f'queue size           : {queue_size} alerts')
print(f'validation errors    : {len(validation_errors)}')
print(f'time span            : {start_time} -> {end_time}')
print('priority bands')
print(f\"  critical  : {by_priority_band['critical']}\")
print(f\"  high      : {by_priority_band['high']}\")
print(f\"  medium    : {by_priority_band['medium']}\")
print(f\"  low       : {by_priority_band['low']}\")
print('top rules (5)')
for r_title, count in sorted_rules[:5]:
    print(f'  {r_title:<34} {count}')
print('top hosts (3 by cumulative score)')
for host, score in top_targets_raw:
    print(f'  {host:<16} score {int(score)}')
print(f'attack tactics covered : {len(by_attack_tactic)}')
"

echo "queue_assessment.json written"
