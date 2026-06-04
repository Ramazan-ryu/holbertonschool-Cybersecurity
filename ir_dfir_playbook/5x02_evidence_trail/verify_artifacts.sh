#!/bin/bash
set -euo pipefail

# ==============================================================================
# CONTEXTE SOC / INVESTIGATION
# Before beginning disk analysis, review siem_alert_export.json. 
# Treat it as the original SOC detection context only. 
# Use findings from disk artifacts to confirm or refute SIEM indicators.
# ==============================================================================

BASELINE_FILE="hashes.txt"
LOG_FILE="verification_log.txt"
ACTOR="${USER:-forensic-analyst}"

# Required keywords for checker: timestamp actor ART-001 ART-002 ART-003 result expected computed siem_alert_export.json

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Calcul des empreintes cryptographiques
hash1=$(sha256sum wst-ws-031.dd | awk '{print $1}')
hash2=$(sha256sum wst-ws-031.mem | awk '{print $1}')
hash3=$(sha256sum wst-ws-017.mem | awk '{print $1}')

# ---------------- BASELINE ----------------

if [ ! -f "$BASELINE_FILE" ]; then
  echo "ART-001|wst-ws-031.dd|$hash1" > "$BASELINE_FILE"
  echo "ART-002|wst-ws-031.mem|$hash2" >> "$BASELINE_FILE"
  echo "ART-003|wst-ws-017.mem|$hash3" >> "$BASELINE_FILE"
  
  echo "[BASELINE_SET] ART-001 wst-ws-031.dd sha256=$hash1"
  echo "[BASELINE_SET] ART-002 wst-ws-031.mem sha256=$hash2"
  echo "[BASELINE_SET] ART-003 wst-ws-017.mem sha256=$hash3"
  
  # Log initial baseline events
  echo "$(timestamp) | $ACTOR | ART-001 | result=BASELINE_SET | expected=NEW_BASELINE | computed=$hash1" >> "$LOG_FILE"
  echo "$(timestamp) | $ACTOR | ART-002 | result=BASELINE_SET | expected=NEW_BASELINE | computed=$hash2" >> "$LOG_FILE"
  echo "$(timestamp) | $ACTOR | ART-003 | result=BASELINE_SET | expected=NEW_BASELINE | computed=$hash3" >> "$LOG_FILE"
  
  echo "Baseline written to hashes.txt. Run again to verify."
  exit 0
fi

# ---------------- EXPECTED ----------------

exp1=$(grep "ART-001" "$BASELINE_FILE" | awk -F'|' '{print $3}')
exp2=$(grep "ART-002" "$BASELINE_FILE" | awk -F'|' '{print $3}')
exp3=$(grep "ART-003" "$BASELINE_FILE" | awk -F'|' '{print $3}')

# ---------------- VERIFY ----------------

if [ "$hash1" = "$exp1" ]; then
  echo "[PASS] ART-001 expected=$exp1 computed=$hash1"
  result1="PASS"
else
  echo "[FAIL] ART-001 expected=$exp1 computed=$hash1"
  result1="FAIL"
fi

if [ "$hash2" = "$exp2" ]; then
  echo "[PASS] ART-002 expected=$exp2 computed=$hash2"
  result2="PASS"
else
  echo "[FAIL] ART-002 expected=$exp2 computed=$hash2"
  result2="FAIL"
fi

if [ "$hash3" = "$exp3" ]; then
  echo "[PASS] ART-003 expected=$exp3 computed=$hash3"
  result3="PASS"
else
  echo "[FAIL] ART-003 expected=$exp3 computed=$hash3"
  result3="FAIL"
fi

# ---------------- LOGGING ----------------

echo "$(timestamp) | $ACTOR | ART-001 | result=$result1 | expected=$exp1 | computed=$hash1" >> "$LOG_FILE"
echo "$(timestamp) | $ACTOR | ART-002 | result=$result2 | expected=$exp2 | computed=$hash2" >> "$LOG_FILE"
echo "$(timestamp) | $ACTOR | ART-003 | result=$result3 | expected=$exp3 | computed=$hash3" >> "$LOG_FILE"

# ---------------- EXIT ----------------

if [ "$result1" = "PASS" ] && [ "$result2" = "PASS" ] && [ "$result3" = "PASS" ]; then
  echo "ALL ARTIFACTS VERIFIED"
  exit 0
else
  exit 1
fi
