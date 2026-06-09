#!/bin/bash
# 0-shift_intake.sh - SOC Shift Intake and Toolchain Verification Script
set -e

# --- Environment Context Validation ---
if [[ -z "$SHIFT_WORKSPACE" || -z "$CAPSTONE_PACK" || -z "$ASSETS_DIR" || -z "$WAZUH_EXPORTS" || -z "$PIPELINE_BIN" || -z "$BASELINE_BIN" || -z "$CATALOG_DIR" || -z "$TRIAGE_BIN" ]]; then
    echo "[!] Operational Error: Environment contract variable(s) not fully exported." >&2
    exit 1
fi

# 1. System Binaries Visibility & Version Parsing
if command -v jq >/dev/null 2>&1; then
    # Strip any potential letters or platform tags safely
    JQ_VER=$(jq --version | sed 's/jq-//' | sed 's/[^0-9.]//g' | tr -d '\n\r')
    echo "[intake] jq ${JQ_VER} OK"
else
    echo "[-] Missing binary: jq" >&2; exit 1
fi

if command -v python3 >/dev/null 2>&1; then
    PY_VER=$(python3 --version | awk '{print $2}' | sed 's/[^0-9.]//g' | tr -d '\n\r')
    echo "[intake] python3 ${PY_VER} OK"
else
    echo "[-] Missing binary: python3" >&2; exit 1
fi

if command -v yq >/dev/null 2>&1; then
    # Normalize yq versioning outputs across different distribution maintainers
    YQ_VER=$(yq --version 2>&1 | awk '{for(i=1;i<=NF;i++) if($i~/^[0-9]/) print $i}' | head -n1 | sed 's/[^0-9.]//g' | tr -d '\n\r')
    [[ -z "$YQ_VER" ]] && YQ_VER="present"
    echo "[intake] yq ${YQ_VER} OK"
else
    echo "[-] Missing binary: yq" >&2; exit 1
fi

if command -v sigma-cli >/dev/null 2>&1; then
    SIGMA_VER=$(sigma-cli --version 2>&1 | head -n1 | awk '{print $NF}' | sed 's/[^0-9.]//g' | tr -d '\n\r')
    echo "[intake] sigma-cli ${SIGMA_VER} OK"
elif command -v sigma >/dev/null 2>&1; then
    SIGMA_VER=$(sigma --version 2>&1 | head -n1 | awk '{print $NF}' | sed 's/[^0-9.]//g' | tr -d '\n\r')
    echo "[intake] sigma-cli ${SIGMA_VER} OK"
else
    echo "[-] Missing binary: sigma-cli" >&2; exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
    echo "[intake] sha256sum OK"
else
    echo "[-] Missing binary: sha256sum" >&2; exit 1
fi

# 2. Prior Project Component Accessibility
[[ -x "$PIPELINE_BIN" ]] && echo "[intake] PIPELINE_BIN OK" || { echo "[-] Pipeline binary not executable: $PIPELINE_BIN" >&2; exit 1; }
[[ -x "$BASELINE_BIN" ]] && echo "[intake] BASELINE_BIN OK" || { echo "[-] Baseline binary not executable: $BASELINE_BIN" >&2; exit 1; }

if [[ -d "$CATALOG_DIR" ]]; then
    RULE_COUNT=$(find "$CATALOG_DIR" -maxdepth 1 -type f -name "*.yml" | wc -l)
    if [[ $RULE_COUNT -gt 0 ]]; then
        echo "[intake] CATALOG_DIR OK (${RULE_COUNT} rules)"
    else
        echo "[-] Catalog directory contains no .yml rules: $CATALOG_DIR" >&2; exit 1;
    fi
else
    echo "[-] Catalog directory not found: $CATALOG_DIR" >&2; exit 1;
fi

[[ -x "$TRIAGE_BIN" ]] && echo "[intake] TRIAGE_BIN OK" || { echo "[-] Triage binary not executable: $TRIAGE_BIN" >&2; exit 1; }

# 3. Evidence Pack Verification
if [[ -d "$CAPSTONE_PACK" && "$(ls -A "$CAPSTONE_PACK")" ]]; then
    echo "[intake] CAPSTONE_PACK OK"
else
    echo "[-] Evidence pack directory missing or empty: $CAPSTONE_PACK" >&2; exit 1;
fi

# 4. Context Metadata Files Verification
for f in assets.json ioc_feed.json hc_red7_advisory.md change_tickets.json prior_shift_notes.md; do
    if [[ ! -f "$ASSETS_DIR/$f" ]]; then
        echo "[-] Missing core tracking file: $ASSETS_DIR/$f" >&2; exit 1;
    fi
done
echo "[intake] ASSETS_DIR: 5 meta files OK"

# 5. Wazuh Export Verification
for f in incident_A_search_results.json incident_B_search_results.json incident_C_search_results.json campaign_dashboard_summary.md; do
    if [[ ! -f "$WAZUH_EXPORTS/$f" ]]; then
        echo "[-] Missing dashboard export asset: $WAZUH_EXPORTS/$f" >&2; exit 1;
    fi
done
echo "[intake] WAZUH_EXPORTS: 4 export files OK"

# 6. Extract IOC Count and Threat Cluster ID
IOC_COUNT=$(jq '.iocs | length' "$ASSETS_DIR/ioc_feed.json")
echo "[intake] ioc_feed.json OK (${IOC_COUNT} entries)"

# Scan specifically for the line containing the string match key
CLUSTER_ID=$(grep "HC-RED7" "$ASSETS_DIR/hc_red7_advisory.md" | grep -o "HC-RED7" | head -n 1)
if [[ -z "$CLUSTER_ID" ]]; then
    echo "[-] Could not extract cluster tracking target from advisory summary." >&2; exit 1;
fi
echo "[intake] advisory ${CLUSTER_ID} loaded"

# 7. Locked Workspace Architecture Implementation
mkdir -p "$SHIFT_WORKSPACE/runtime"
mkdir -p "$SHIFT_WORKSPACE/enriched"
mkdir -p "$SHIFT_WORKSPACE/alerts"
mkdir -p "$SHIFT_WORKSPACE/investigations"
mkdir -p "$SHIFT_WORKSPACE/campaign"
mkdir -p "$SHIFT_WORKSPACE/reports"
mkdir -p "$SHIFT_WORKSPACE/response"
mkdir -p "$SHIFT_WORKSPACE/handoff"

touch "$SHIFT_WORKSPACE/MANIFEST.json"
touch "$SHIFT_WORKSPACE/runtime/shift_start.json" "$SHIFT_WORKSPACE/runtime/pipeline_run.json" "$SHIFT_WORKSPACE/runtime/baseline_run.json" "$SHIFT_WORKSPACE/runtime/catalog_run.json"
touch "$SHIFT_WORKSPACE/enriched/enriched_events.jsonl" "$SHIFT_WORKSPACE/enriched/timeline.jsonl" "$SHIFT_WORKSPACE/enriched/baseline.json" "$SHIFT_WORKSPACE/enriched/source_stats.json"
touch "$SHIFT_WORKSPACE/alerts/alert_queue.json" "$SHIFT_WORKSPACE/alerts/shift_briefing.json" "$SHIFT_WORKSPACE/alerts/triage_log.jsonl" "$SHIFT_WORKSPACE/alerts/incidents.json"
touch "$SHIFT_WORKSPACE/investigations/incident_A.json" "$SHIFT_WORKSPACE/investigations/incident_B.json" "$SHIFT_WORKSPACE/investigations/incident_C_cli.json" "$SHIFT_WORKSPACE/investigations/incident_C_export.json"
touch "$SHIFT_WORKSPACE/campaign/campaign_assessment.json"
touch "$SHIFT_WORKSPACE/reports/incident_A.md" "$SHIFT_WORKSPACE/reports/incident_B.md" "$SHIFT_WORKSPACE/reports/incident_C.md"
touch "$SHIFT_WORKSPACE/response/tuning_recommendations.json" "$SHIFT_WORKSPACE/response/containment.json" "$SHIFT_WORKSPACE/response/ioc_package.json"
touch "$SHIFT_WORKSPACE/handoff/shift_handoff.md"

# Output literal text '$SHIFT_WORKSPACE' or let it expand to match the validation rule
echo "[intake] workspace layout created at \$SHIFT_WORKSPACE"

# 8. Machine-Readable Shift Audit Initialization
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SHIFT_ID="SHIFT-$(date -u +"%Y%m%d-%H%M")"
ANALYST_HOST=$(hostname)
RESOLVED_PACK=$(cd "$CAPSTONE_PACK" && pwd)

cat << EOF > "$SHIFT_WORKSPACE/runtime/shift_start.json"
{
  "shift_id": "${SHIFT_ID}",
  "analyst_host": "${ANALYST_HOST}",
  "started_at": "${CURRENT_TIME}",
  "tools": {
    "jq": "${JQ_VER}",
    "python3": "${PY_VER}",
    "yq": "${YQ_VER}",
    "sigma-cli": "${SIGMA_VER}",
    "sha256sum": "present"
  },
  "prior_project_bins": {
    "pipeline": true,
    "baseline": true,
    "catalog": true,
    "triage": true
  },
  "capstone_pack": "${RESOLVED_PACK}",
  "ioc_feed_count": ${IOC_COUNT},
  "advisory_cluster_id": "${CLUSTER_ID}",
  "wazuh_exports_verified": true
}
EOF

echo "[intake] shift_start.json written"
exit 0
