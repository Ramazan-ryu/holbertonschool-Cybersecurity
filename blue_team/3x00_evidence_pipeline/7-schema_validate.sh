#!/bin/bash
# 7-schema_validate.sh
# Validates every record in normalized_events.json against event_schema.json

SCHEMA_FILE="event_schema.json"
DATA_FILE="normalized_events.json"
REPORT_FILE="validation_report.json"

# Check if required files exist
if [ ! -f "$SCHEMA_FILE" ] || [ ! -f "$DATA_FILE" ]; then
    echo "Error: Missing $SCHEMA_FILE or $DATA_FILE."
    exit 1
fi

# Run validation engine via embedded Python script
python3 - << 'EOF'
import json
import sys
import os

schema_path = "event_schema.json"
data_path = "normalized_events.json"
report_path = "validation_report.json"

# Load schema definition
with open(schema_path, "r", encoding="utf-8") as sf:
    schema = json.load(sf)

# Identify required fields and types from properties
properties = schema.get("properties", {})
required_fields = schema.get("required", [])

total_records = 0
compliant_count = 0
non_compliant_count = 0

# Count trackers for field completeness
field_presence_counts = {field: 0 for field in properties.keys()}
non_compliant_examples = []

def check_type(val, expected_type):
    if expected_type == "string":
        return isinstance(val, str)
    elif expected_type == "integer":
        return isinstance(val, int) and not isinstance(val, bool)
    elif expected_type == "number":
        return isinstance(val, (int, float)) and not isinstance(val, bool)
    elif expected_type == "boolean":
        return isinstance(val, bool)
    elif expected_type == "array":
        return isinstance(val, list)
    elif expected_type == "object":
        return isinstance(val, dict)
    elif expected_type == "null":
        return val is None
    return True

if os.path.exists(data_path):
    with open(data_path, "r", encoding="utf-8") as df:
        for line in df:
            line = line.strip()
            if not line:
                continue
            total_records += 1
            is_compliant = True
            reasons = []
            
            try:
                record = json.loads(line)
            except Exception as e:
                is_compliant = False
                reasons.append(f"Invalid JSON format: {str(e)}")
                record = {}

            # Evaluate properties and track field completeness
            for field, field_meta in properties.items():
                expected_type = field_meta.get("type", "string")
                
                if field in record and record[field] is not None:
                    field_presence_counts[field] += 1
                    # Check matching declared type
                    if not check_type(record[field], expected_type):
                        is_compliant = False
                        reasons.append(f"Field '{field}' has type {type(record[field]).__name__}, expected {expected_type}")
                else:
                    # Check if the missing/null field was required
                    if field in required_fields:
                        is_compliant = False
                        reasons.append(f"Required field '{field}' is missing or null")

            if is_compliant:
                compliant_count += 1
            else:
                non_compliant_count += 1
                if len(non_compliant_examples) < 20:
                    non_compliant_examples.append({
                        "record": record,
                        "reasons": reasons
                    })

# Calculate completeness percentages
completeness_pct = {}
for field, count in field_presence_counts.items():
    completeness_pct[field] = f"{(count / total_records * 100):.2f}%" if total_records > 0 else "0.00%"

# Generate summary metrics
compliance_rate = (compliant_count / total_records) if total_records > 0 else 0.0
compliance_rate_pct = compliance_rate * 100

report_data = {
    "summary": {
        "total_records": total_records,
        "compliant_records": compliant_count,
        "non_compliant_records": non_compliant_count,
        "compliance_rate_percentage": f"{compliance_rate_pct:.2f}%"
    },
    "per_field_completeness": completeness_pct,
    "non_compliant_examples": non_compliant_examples
}

# Write out the compliance JSON report
with open(report_path, "w", encoding="utf-8") as rf:
    json.dump(report_data, rf, indent=2)

# Output matching user expected syntax exactly
print(f"records checked       : {total_records}")
print(f"fully compliant       : {compliant_count} ({compliance_rate_pct:.2f}%)")
print(f"non-compliant         : {non_compliant_count}")
print("per-field completeness:")
for field, pct_str in completeness_pct.items():
    print(f"  {field:<15} {pct_str}")
print("validation_report.json written")

# Return explicit statuses back to Shell based on > 99% threshold rule
if compliance_rate_pct > 99.00:
    sys.exit(0)
else:
    sys.exit(1)
EOF

# Capture the Python status to ensure script exit compatibility
if [ $? -eq 0 ]; then
    exit 0
else
    exit 1
fi
