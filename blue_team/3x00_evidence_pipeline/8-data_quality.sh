#!/bin/bash
# 8-data_quality.sh
# Identifies and cleans up dirty data anomalies injected within the data files.

DATA_FILE="normalized_events.json"
CLEANED_FILE="cleaned_events.json"
LOG_FILE="cleaning_log.json"

# Validate requirements
if [ ! -f "$DATA_FILE" ]; then
    echo "Error: Missing $DATA_FILE."
    exit 1
fi

python3 - << 'EOF'
import json
import sys
import os
import re
from datetime import datetime, timezone, timedelta

data_path = "normalized_events.json"
cleaned_path = "cleaned_events.json"
log_path = "cleaning_log.json"

# Setup bounds: March 18, 2026 to March 25, 2026 UTC
START_BOUND = datetime(2026, 3, 18, 0, 0, 0, tzinfo=timezone.utc)
END_BOUND = datetime(2026, 3, 25, 23, 59, 59, tzinfo=timezone.utc)
ALLOWED_LOWER_SKEW = START_BOUND - timedelta(hours=12)
ALLOWED_UPPER_SKEW = END_BOUND + timedelta(hours=12)

# Metrics trackers
metrics = {
    "malformed_detected": 0, "malformed_repaired": 0, "malformed_dropped": 0,
    "duplicates_detected": 0, "duplicates_removed": 0,
    "hostname_case_normalized": 0,
    "encoding_detected": 0, "encoding_repaired": 0,
    "wrong_tz_flagged": 0
}

cleaning_log = []
seen_fingerprints = set()

def try_parse_iso(ts_str):
    if not ts_str:
        return None
    for fmt in ("%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%S"):
        try:
            dt = datetime.strptime(ts_str[:19], fmt[:19])
            return dt.replace(tzinfo=timezone.utc)
        except ValueError:
            continue
    return None

def attempt_timestamp_repair(ts_str):
    if not ts_str:
        return None
    # Check for Unix timestamps (digits only)
    if ts_str.isdigit():
        try:
            return datetime.fromtimestamp(int(ts_str), tz=timezone.utc)
        except Exception:
            pass
    # Common variations: Space delimiter instead of 'T'
    cleaned = ts_str.strip()
    cleaned_t = cleaned.replace(" ", "T")
    dt = try_parse_iso(cleaned_t)
    if dt:
        return dt
    return None

def repair_mojibake(raw_str):
    if not raw_str:
        return raw_str, False
    # Detect common placeholder characters or mojibake signatures
    if "" in raw_str or "Ã" in raw_str or "Â" in raw_str:
        try:
            # Fallback re-decoding attempt for Latin-1 bytes to UTF-8
            re_encoded = raw_str.encode('latin-1').decode('utf-8')
            if re_encoded != raw_str:
                return re_encoded, True
        except Exception:
            pass
    return raw_str, False

record_counter = 0

with open(data_path, "r", encoding="utf-8") as infile, \
     open(cleaned_path, "w", encoding="utf-8") as outfile:
    
    for line in infile:
        line = line.strip()
        if not line:
            continue
        
        record_counter += 1
        record_id = f"REC_{record_counter:06d}"
        
        try:
            record = json.loads(line)
        except Exception:
            # Drop unparseable lines directly
            metrics["malformed_detected"] += 1
            metrics["malformed_dropped"] += 1
            cleaning_log.append({
                "defect_type": "malformed_timestamp",
                "original_value": line,
                "corrected_value": None,
                "record_id": record_id,
                "reason": "Unparseable line JSON format structural failure"
            })
            continue

        original_hostname = record.get("hostname")
        original_ts = record.get("timestamp")
        original_raw = record.get("raw_message", "")

        # 1. Handle Encoding/Mojibake Errors
        fixed_raw, was_repaired = repair_mojibake(original_raw)
        if was_repaired:
            metrics["encoding_detected"] += 1
            metrics["encoding_repaired"] += 1
            record["raw_message"] = fixed_raw
            cleaning_log.append({
                "defect_type": "encoding_error",
                "original_value": original_raw,
                "corrected_value": fixed_raw,
                "record_id": record_id,
                "reason": "Re-decoded mojibake from Latin-1 into clean UTF-8 string data"
            })

        # 2. Handle Hostname Case Inconsistency
        if isinstance(original_hostname, str):
            if not original_hostname.islower():
                record["hostname"] = original_hostname.lower()
                metrics["hostname_case_normalized"] += 1
                cleaning_log.append({
                    "defect_type": "hostname_case_inconsistency",
                    "original_value": original_hostname,
                    "corrected_value": original_hostname.lower(),
                    "record_id": record_id,
                    "reason": "Normalized hostname to lowercase format string"
                })
        else:
            record["hostname"] = ""

        # 3. Handle Timestamps Validation & Timezones
        dt_parsed = try_parse_iso(original_ts)
        is_repaired_ts = False
        
        if not dt_parsed:
            metrics["malformed_detected"] += 1
            dt_parsed = attempt_timestamp_repair(original_ts)
            if dt_parsed:
                metrics["malformed_repaired"] += 1
                is_repaired_ts = True
                new_ts_str = dt_parsed.strftime("%Y-%m-%dT%H:%M:%SZ")
                record["timestamp"] = new_ts_str
                cleaning_log.append({
                    "defect_type": "malformed_timestamp",
                    "original_value": original_ts,
                    "corrected_value": new_ts_str,
                    "record_id": record_id,
                    "reason": "Successfully matched dynamic layout to target standard ISO8601 format"
                })
            else:
                metrics["malformed_dropped"] += 1
                cleaning_log.append({
                    "defect_type": "malformed_timestamp",
                    "original_value": original_ts,
                    "corrected_value": None,
                    "record_id": record_id,
                    "reason": "Timestamp could not be parsed or repaired via fallbacks; record dropped"
                })
                continue

        # Check for extreme Timezone skew / boundary anomalies
        if dt_parsed < ALLOWED_LOWER_SKEW or dt_parsed > ALLOWED_UPPER_SKEW:
            metrics["wrong_tz_flagged"] += 1
            cleaning_log.append({
                "defect_type": "suspected_wrong_tz",
                "original_value": record["timestamp"],
                "corrected_value": record["timestamp"],
                "record_id": record_id,
                "reason": "Valid ISO timestamp falls outside evidence pack range by more than 12 hours"
            })

        # 4. Handle Duplicate Removals (Retransmissions)
        fingerprint = (
            record["timestamp"],
            record.get("hostname", ""),
            record.get("source_type", ""),
            record.get("raw_message", "")
        )
        if fingerprint in seen_fingerprints:
            metrics["duplicates_detected"] += 1
            metrics["duplicates_removed"] += 1
            cleaning_log.append({
                "defect_type": "duplicate",
                "original_value": record["timestamp"],
                "corrected_value": None,
                "record_id": record_id,
                "reason": "Identical log signature duplicated by transport layer retransmission; duplicate removed"
            })
            continue
        
        seen_fingerprints.add(fingerprint)

        # Write out matching clean schema lines to output
        outfile.write(json.dumps(record) + "\n")

# Dump structured tracking operations summary list
with open(log_path, "w", encoding="utf-8") as log_file:
    json.dump(cleaning_log, log_file, indent=2)

# Format explicit text columns
print(f"malformed timestamps   :  detected {metrics['malformed_detected']:<10} repaired {metrics['malformed_repaired']:<10} dropped {metrics['malformed_dropped']}")
print(f"duplicates             :  detected {metrics['duplicates_detected']:<10} removed {metrics['duplicates_removed']}")
print(f"hostname case          :  normalized {metrics['hostname_case_normalized']}")
print(f"encoding errors        :  detected {metrics['encoding_detected']:<10} repaired {metrics['encoding_repaired']}")
print(f"suspected wrong tz     :  flagged {metrics['wrong_tz_flagged']}")
print("cleaned_events.json    written")
print("cleaning_log.json      written")
EOF
