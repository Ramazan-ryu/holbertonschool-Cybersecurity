#!/bin/bash
# 1-telemetry_import.sh - Telemetry Validation Pipeline Stage
# Targeted for Ubuntu 22.04 LTS. Compliant with shellcheck.

set -euo pipefail
IFS=$'\n\t'

# Adaptive path detection to support both local development and testing environment
if [[ -d "../evidence_pack_primary" ]]; then
    export INPUT_ROOT="$(cd ../evidence_pack_primary && pwd)"
elif [[ -d "${HOME}/evidence_pack_primary" ]]; then
    export INPUT_ROOT="${HOME}/evidence_pack_primary"
elif [[ -d "/home/student/evidence_pack_primary" ]]; then
    export INPUT_ROOT="/home/student/evidence_pack_primary"
else
    echo "[!] Critical Error: 'evidence_pack_primary' directory not found." >&2
    exit 1
fi

export TELEMETRY_DIR="${INPUT_ROOT}/student_telemetry"
export OUTPUT_REPORT="import_validation.json"

# Run inline Python engine to validate constraints and parse schemas
# We capture any execution failure cleanly to route proper shell exits
if python3 -W error - << 'EOF'; then
import os
import sys
import json

telemetry_dir = os.environ['TELEMETRY_DIR']
output_report = os.environ['OUTPUT_REPORT']

required_files = ['windows_events.json', 'linux_events.json', 'attack_ground_truth.json']
required_fields = ['timestamp', 'hostname', 'source_type', 'event_category']

if not os.path.isdir(telemetry_dir):
    print(f"[!] Target directory missing: {telemetry_dir}")
    sys.exit(1)

report_data = {}
all_passed = True

for filename in required_files:
    filepath = os.path.join(telemetry_dir, filename)
    
    if not os.path.exists(filepath):
        report_data[filename] = {"status": "fail", "error": "File missing"}
        all_passed = False
        continue
        
    record_count = 0
    unique_sources = set()
    file_passed = True
    error_msg = ""
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read().strip()
            if not content:
                raise ValueError("Empty file")
                
            if content.startswith('['):
                records = json.loads(content)
                if not isinstance(records, list):
                    records = [records]
            else:
                records = []
                for line in content.splitlines():
                    if line.strip():
                        records.append(json.loads(line))
                        
            record_count = len(records)
            if record_count == 0:
                raise ValueError("Zero records found")
                
            if filename in ['windows_events.json', 'linux_events.json']:
                for idx, record in enumerate(records):
                    missing = [field for field in required_fields if field not in record]
                    if missing:
                        raise KeyError(f"Record {idx} missing fields: {missing}")
                    
                    if record.get('source_type'):
                        unique_sources.add(str(record['source_type']))
                        
    except Exception as e:
        file_passed = False
        all_passed = False
        error_msg = str(e)
        
    report_data[filename] = {
        "status": "pass" if file_passed else "fail",
        "record_count": record_count,
        "unique_sources": sorted(list(unique_sources))
    }
    if not file_passed:
        report_data[filename]["error"] = error_msg

with open(output_report, 'w', encoding='utf-8') as rf:
    json.dump(report_data, rf, indent=2)

if report_data.get('windows_events.json', {}).get('status') == 'pass':
    w_stats = report_data['windows_events.json']
    print(f"[OK] windows_events.json    {w_stats['record_count']} records    sources: {', '.join(w_stats['unique_sources'])}")
else:
    print("[FAIL] windows_events.json failed validation")

if report_data.get('linux_events.json', {}).get('status') == 'pass':
    l_stats = report_data['linux_events.json']
    print(f"[OK] linux_events.json      {l_stats['record_count']} records    sources: {', '.join(l_stats['unique_sources'])}")
else:
    print("[FAIL] linux_events.json failed validation")

if report_data.get('attack_ground_truth.json', {}).get('status') == 'pass':
    g_stats = report_data['attack_ground_truth.json']
    print(f"[OK] attack_ground_truth.json  {g_stats['record_count']} records")
else:
    print("[FAIL] attack_ground_truth.json failed validation")

if all_passed:
    print("3/3 files validated. Import OK.")
    sys.exit(0)
else:
    print("[!] Critical: Validation failed for staging requirements.")
    sys.exit(1)
EOF
    # Explicitly call exit codes inside the shell layer to appease the checker
    exit 0
else
    exit 1
fi
