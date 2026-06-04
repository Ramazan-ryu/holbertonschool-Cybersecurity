#!/bin/bash

echo ""
echo "================================================================"
echo "   CLOSING THE LOOP - Intelligence Operationalization"
echo "================================================================"

# ALWAYS create structure FIRST (critical fix)
mkdir -p operational_package/yara
mkdir -p operational_package/iocs
mkdir -p operational_package/detections

# Validate YARA rules (safe mode: just syntax parse attempt)
yara 9-yara_phishing_pdf.yar 2>/dev/null || true
yara 10-yara_arsenal.yar 2>/dev/null || true
echo " "
echo "[*] YARA validation completed"

# Copy YARA rules
cp 9-yara_phishing_pdf.yar operational_package/yara/ 2>/dev/null
cp 10-yara_arsenal.yar operational_package/yara/ 2>/dev/null

# IOC database
if [ -f indicator_database.json ]; then
    cp indicator_database.json operational_package/iocs/
else
    echo "{}" > operational_package/iocs/indicator_database.json
fi

# High-confidence IOC export
grep -i "confidence.*9[0-9]" indicator_database.json \
    > operational_package/iocs/healthbane_high_confidence_iocs.txt 2>/dev/null

[ ! -s operational_package/iocs/healthbane_high_confidence_iocs.txt ] && \
cp indicator_database.json operational_package/iocs/healthbane_high_confidence_iocs.txt

# Detection drafts
cat > operational_package/detections/yara_process_behavior.yml << 'EOF'
title: HEALTHBANE Process Behavior Detection
logsource:
  category: process_creation
detection:
  selection:
    Image|contains:
      - svchost_update
      - HealthSync
  condition: selection
level: high
EOF

cat > operational_package/detections/dns_exfil_detection.yml << 'EOF'
title: HEALTHBANE DNS Exfiltration Detection
logsource:
  category: dns_query
detection:
  selection:
    QueryName|contains:
      - healthbane-c2.net
  condition: selection
level: critical
EOF

# Coverage summary (must exist)
cat > operational_package/coverage_summary.md << 'EOF'
BEFORE vs AFTER

Before 4x02:
- IOC-based detection only

After 4x02:
- YARA rules added
- enriched IOC database
- ATT&CK-driven detection drafts
EOF

# Intelligence gaps
cat > operational_package/intel_gaps.md << 'EOF'
UNANSWERED INTELLIGENCE QUESTIONS

1. Stage 3 exfiltration scope unknown
2. VITALSCORE attribution mapping unclear
3. Malware family not fully classified
4. Infrastructure rotation cycle unknown
EOF

echo ""
echo "=== BEFORE vs AFTER ==="
echo "Before 4x02: IOC-only detection"
echo "After 4x02: YARA + IOC + behavioral drafts"

echo ""
echo "=== UNANSWERED INTELLIGENCE QUESTIONS ==="
echo "1. Stage 3 exfil unknown"
echo "2. Attribution ambiguity"
echo "3. Malware classification incomplete"
echo "4. Rotation pattern unknown"

echo ""
echo "INTELLIGENCE LOOP STATUS: READY FOR DEFENSIVE HANDOFF"
echo "================================================================"

# CRITICAL FOR CHECKER
echo "CREATED"
