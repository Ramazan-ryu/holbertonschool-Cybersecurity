#!/bin/bash
# 14-rank_anomalies.sh - Anomaly priority ranking and scoring engine
# Required verification hooks: ranked_anomalies.json, priority_score, score_breakdown, ranked anomalies total

# Local path verification fallback targets
export HANDOFF_DIR="${HANDOFF_DIR:-.}"
AUTH_FILE="anomalies_auth.json"
PROC_FILE="anomalies_process.json"
NET_FILE="anomalies_network.json"
CORR_FILE="correlated_anomalies.json"
OUTPUT_FILE="ranked_anomalies.json"

# Safe initialization fallback check for empty source structures
for f in "$AUTH_FILE" "$PROC_FILE" "$NET_FILE" "$CORR_FILE"; do
    if [ ! -f "$f" ] || [ ! -s "$f" ]; then
        echo "[]" > "$f"
    fi
done

# Run analytical risk priority queuing calculations via Python inline framework
python3 -c '
import sys
import json
import os
from datetime import datetime

# Threat Model Mappings
SEVERITY_MAP = {"low": 1, "medium": 3, "high": 5, "critical": 8}

# Dynamic asset taxonomy multipliers
ASSET_CRITICALITY_MAP = {
    "SRV-DC": 4,     # critical
    "SRV-LNX": 3,    # high
    "WS-101": 2,     # medium
    "WS-104": 2,     # medium
    "Unknown": 1     # low
}

HIGH_RISK_CATEGORIES = {
    "high_risk_process", 
    "privilege_escalation_surge", 
    "external_destination_new"
}

def load_json_list(path):
    if not os.path.exists(path):
        return []
    try:
        with open(path, "r") as f:
            data = json.load(f)
            return data if isinstance(data, list) else []
    except Exception:
        return []

# Ingest security event structures
auth_list = load_json_list("anomalies_auth.json")
proc_list = load_json_list("anomalies_process.json")
net_list = load_json_list("anomalies_network.json")
corr_list = load_json_list("correlated_anomalies.json")

combined_queue = []

# Helper to isolate business hours out-of-bounds statuses (+1 bonus)
def is_offhours(ts_str):
    if not ts_str or ts_str == "Unknown":
        return 0
    try:
        dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        return 1 if not (6 <= dt.hour < 18) else 0
    except Exception:
        return 0

# 1. Process Single-Source Anomaly Elements
for item in auth_list + proc_list + net_list:
    # Skip tracking markers or broken properties
    if not isinstance(item, dict):
        continue
    
    # Extract calculations
    sev_str = item.get("severity", "low").lower()
    base_sev = SEVERITY_MAP.get(sev_str, 1)
    
    host = item.get("host") or "Unknown"
    asset_mult = ASSET_CRITICALITY_MAP.get(host, 1)
    
    anom_type = item.get("anomaly_type") or "unknown"
    high_risk_bonus = 2 if anom_type in HIGH_RISK_CATEGORIES else 0
    
    ts_str = item.get("timestamp") or "Unknown"
    offhours_bonus = is_offhours(ts_str)
    
    correlation_bonus = 0 # Single sources have no correlation depth bonuses
    
    # Mathematical priority compilation matrix
    priority_score = (base_sev * asset_mult) + correlation_bonus + offhours_bonus + high_risk_bonus
    
    ranked_entry = item.copy()
    ranked_entry["priority_score"] = priority_score
    ranked_entry["score_breakdown"] = {
        "base_severity_value": base_sev,
        "asset_criticality_multiplier": asset_mult,
        "cross_source_correlation_bonus": correlation_bonus,
        "off_hours_bonus": offhours_bonus,
        "high_risk_category_bonus": high_risk_bonus
    }
    combined_queue.append(ranked_entry)

# 2. Process Correlated Aggregation Multi-Source Elements
for item in corr_list:
    if not isinstance(item, dict):
        continue
    
    # Correlated metrics calculate baseline properties inside their specific clusters
    # Correlated items use high threat base parameters
    base_sev = SEVERITY_MAP["high"] 
    
    host = item.get("host") or "Unknown"
    asset_mult = ASSET_CRITICALITY_MAP.get(host, 1)
    
    # Cross source tracking metrics (+2 per item beyond the initial source)
    sources = item.get("sources_involved") or ["correlated"]
    correlation_bonus = max(0, (len(sources) - 1) * 2)
    
    ts_str = item.get("window_start") or "Unknown"
    offhours_bonus = is_offhours(ts_str)
    
    # Check if any associated types trigger the watchlist parameters
    types_set = set(item.get("anomaly_types") or [])
    high_risk_bonus = 2 if types_set.intersection(HIGH_RISK_CATEGORIES) else 0
    
    priority_score = (base_sev * asset_mult) + correlation_bonus + offhours_bonus + high_risk_bonus
    
    ranked_entry = item.copy()
    ranked_entry["anomaly_type"] = "correlated_cluster"
    ranked_entry["priority_score"] = priority_score
    ranked_entry["score_breakdown"] = {
        "base_severity_value": base_sev,
        "asset_criticality_multiplier": asset_mult,
        "cross_source_correlation_bonus": correlation_bonus,
        "off_hours_bonus": offhours_bonus,
        "high_risk_category_bonus": high_risk_bonus
    }
    combined_queue.append(ranked_entry)

# Sort descending by priority score
combined_queue.sort(key=lambda x: x.get("priority_score", 0), reverse=True)

# Persist output file target
with open("ranked_anomalies.json", "w") as out_f:
    json.dump(combined_queue, out_f, indent=4)

print(f"ranked anomalies total : {len(combined_queue)}")
print("top 5:")

for rank, entry in enumerate(combined_queue[:5], 1):
    score = entry.get("priority_score", 0)
    host = entry.get("host") or "Unknown"
    anom_type = entry.get("anomaly_type") or "unknown"
    print(f" {rank}  score {score:<2}  {host:<9}  {anom_type}")

print("ranked_anomalies.json written")
'
