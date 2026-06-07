# ==============================================================================
# PHASE 1: LOCAL ENVIRONMENT OVERRIDE & MOCK BASELINE GENERATION
# ==============================================================================

# 1. Update the environment script to map dynamically to your workspace path
cat << 'EOF' > m3_env.sh
#!/bin/bash
export BASE_WORKSPACE="$(pwd)"

export CATALOG_DIR="$BASE_WORKSPACE"
export HANDOFF_DIR="$BASE_WORKSPACE"
export BASELINE_PKG="$BASE_WORKSPACE"
export TRIAGE_PKG="$BASE_WORKSPACE/3x03_package/triage_package"
export ASSETS_DIR="$BASE_WORKSPACE/3x03_assets"
EOF

# 2. Source the newly updated environment maps
source ./m3_env.sh

# 3. Build structural directory scaffolds expected by the assembly runner
mkdir -p context data baselines alerts spec "$TRIAGE_PKG/tickets" "$TRIAGE_PKG/spec"

# 4. Synchronize your methodology specification document with the triage package path
if [ -f "triage_methodology.md" ]; then
    cp triage_methodology.md "$TRIAGE_PKG/spec/"
fi

# 5. Populate structural database stubs to ensure the context join logic executes
echo '[{"hostname": "db-patient-01", "criticality": "high", "role": "database", "data_classification": "phi", "owner": "clinical_ops", "network_zone": "medical_devices"}]' > context/asset_inventory.json
echo '[{"event_ref": "evt_001", "src_ip": "10.0.1.15", "dst_ip": "192.168.44.10", "user": "adm_local"}]' > data/enriched_events.json
echo '[{"hostname": "db-patient-01", "baseline_rules": []}]' > baselines/baseline_summary.json
echo '[{"alert_id": "alt_001", "priority_score": 24.5, "rule_id": "010_credential_theft_chain", "rule_title": "Credential Theft Chain", "event_ref": "evt_001", "attack_techniques": ["T1003.001"], "event_summary": {"hostname": "db-patient-01", "timestamp": "2026-06-07T12:00:00Z", "src_ip": "10.0.1.15"}}]' > alerts/alert_queue.json


# ==============================================================================
# PHASE 2: CONTEXT ASSEMBLY PIPELINE SCRIPT GENERATION
# ==============================================================================

cat << 'EOF' > 2-context_assembly.sh
#!/bin/bash
# 2-context_assembly.sh - Unified SOC Triage Context Assembly Pipeline Engine

export CATALOG_DIR="${CATALOG_DIR:-$HOME/3x02_package/detection_catalog}"
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
export BASELINE_PKG="${BASELINE_PKG:-$HOME/3x01_package/baseline_package}"
export ASSETS_DIR="${ASSETS_DIR:-$HOME/3x03_assets}"
export TRIAGE_PKG="${TRIAGE_PKG:-$HOME/3x03_package/triage_package}"

ALERT_QUEUE="$CATALOG_DIR/alerts/alert_queue.json"
ASSET_INVENTORY="$HANDOFF_DIR/context/asset_inventory.json"
ENRICHED_EVENTS="$HANDOFF_DIR/data/enriched_events.json"
BASELINE_SUMMARY="$BASELINE_PKG/baselines/baseline_summary.json"
IOC_CONTEXT="$ASSETS_DIR/ioc_context.json"
OUTPUT_JSON="enriched_queue.json"

for file in "$ALERT_QUEUE" "$ASSET_INVENTORY" "$ENRICHED_EVENTS" "$BASELINE_SUMMARY" "$IOC_CONTEXT"; do
    if [ ! -f "$file" ]; then
        echo "[-] Error: Mandatory input component missing: $file"
        exit 1
    fi
done

mkdir -p tickets "$TRIAGE_PKG/tickets"

python3 -c "
import os
import json

with open('$ALERT_QUEUE', 'r') as f: queue = json.load(f)
with open('$ASSET_INVENTORY', 'r') as f: assets = json.load(f)
with open('$ENRICHED_EVENTS', 'r') as f: events = json.load(f)
with open('$BASELINE_SUMMARY', 'r') as f: baselines = json.load(f)
with open('$IOC_CONTEXT', 'r') as f: iocs = json.load(f)

asset_map = {a.get('hostname'): a for a in assets if 'hostname' in a}
event_map = {e.get('event_ref'): e for e in events if 'event_ref' in e}
baseline_map = {b.get('hostname'): b for b in baselines if 'hostname' in b}

alerts_processed = 0
assets_joined = 0
missing_asset_records = 0
alerts_with_ioc_hits = 0
ioc_counts = {'malicious': 0, 'suspicious': 0, 'unknown': 0}
baseline_profiles_joined = 0
enriched_queue = []

for alert in queue:
    alerts_processed += 1
    score = float(alert.get('priority_score', 0.0))
    event_ref = alert.get('event_ref')
    
    if score >= 20.0: priority_band = 'critical'
    elif score >= 10.0: priority_band = 'high'
    elif score >= 5.0: priority_band = 'medium'
    else: priority_band = 'low'
    
    summary = alert.get('event_summary', {})
    host = summary.get('hostname', 'unknown')
    
    asset_record = asset_map.get(host, {})
    if asset_record: assets_joined += 1
    else: missing_asset_records += 1
        
    event_record = event_map.get(event_ref, {})
    host_baseline = baseline_map.get(host, {})
    if host_baseline: baseline_profiles_joined += 1
        
    matched_iocs = []
    has_ioc_match = False
    extracted_indicators = set()
    
    for field in ['src_ip', 'dst_ip', 'destination_ip', 'source_ip', 'domain', 'destination_host']:
        if field in summary and summary[field]: extracted_indicators.add(summary[field])
        if field in event_record and event_record[field]: extracted_indicators.add(event_record[field])
            
    for indicator in extracted_indicators:
        if indicator in iocs:
            ioc_data = iocs[indicator].copy()
            ioc_data['indicator'] = indicator
            rep = ioc_data.get('reputation', 'unknown')
            if rep != 'clean':
                ioc_data['ioc_flag'] = True
                if rep in ioc_counts: ioc_counts[rep] += 1
                has_ioc_match = True
            else:
                ioc_data['ioc_flag'] = False
            matched_iocs.append(ioc_data)
            
    if has_ioc_match: alerts_with_ioc_hits += 1

    enriched_entry = alert.copy()
    enriched_entry.update({
        'asset': asset_record,
        'baseline_host_profile': host_baseline,
        'event_record': event_record,
        'ioc_hits': matched_iocs,
        'priority_band': priority_band
    })
    enriched_queue.append(enriched_entry)

with open('$OUTPUT_JSON', 'w') as out:
    json.dump(enriched_queue, out, indent=4)

size_kb = int(os.path.getsize('$OUTPUT_JSON') / 1024) or 1
print(f'alerts processed          : {alerts_processed}')
print(f'assets joined             : {assets_joined}')
print(f'missing asset records     : {missing_asset_records}')
print(f'alerts with IOC hits      : {alerts_with_ioc_hits}')
print(f\"  malicious               : {ioc_counts['malicious']}\")
print(f\"  suspicious              : {ioc_counts['suspicious']}\")
print(f\"  unknown                 : {ioc_counts['unknown']}\")
print(f'baseline profiles joined  : {baseline_profiles_joined}')
print(f'enriched_queue.json written ({size_kb} KB)')
"
EOF

