#!/bin/bash
# -----------------------------------------------------------------------------
# Project 3906: Verification & Cross-Platform Forensic Toolkit Checker
# File: 0-tool_check.sh
# Purpose: Validates binary path availability, checks directory baselines, 
#          and verifies matching state files for the triage sandbox environment.
# -----------------------------------------------------------------------------

# Set error trap for safety
set -e

# Flag to monitor overall health
STATUS_FAILED=0

# Helper function to print missing statuses or errors
log_error() {
    echo -e "$1" >&2
    STATUS_FAILED=1
}

# 1. Verify Binaries are on PATH and Output Versions
check_tool() {
    local cmd_name=$1
    local version_arg=$2
    if ! command -v "$cmd_name" &> /dev/null; then
        log_error "$cmd_name : MISSING from PATH"
        return
    fi
    
    # Extract only the main version string for cleaner terminal display
    local version_str
    version_str=$("$cmd_name" $version_arg 2>&1 | head -n 1 | awk '{print $1,$2,$3,$4}')
    
    # Clean up specific outputs for known tools
    if [[ "$cmd_name" == "jq" ]]; then
        version_str=$("jq" --version)
    elif [[ "$cmd_name" == "yq" ]]; then
        version_str=$("yq" --version | awk '{print $2}')
    elif [[ "$cmd_name" == "python3" ]]; then
        version_str=$("python3" --version | awk '{print $2}')
    elif [[ "$cmd_name" == "sigma" ]]; then
        version_str=$("sigma" --version 2>&1)
    elif [[ "$cmd_name" == "xmllint" ]]; then
        version_str=$("xmllint" --version 2>&1 | head -n 1 | awk '{print $5}')
    elif [[ "$cmd_name" == "curl" ]]; then
        version_str=$("curl" --version | head -n 1 | awk '{print $2}')
    fi

    # Pad output to replicate expected layout
    printf "%-12s: %s\n" "$cmd_name" "$version_str"
}

# Check all required CLI tools
check_tool "jq" "--version"
check_tool "yq" "--version"
check_tool "python3" "--version"

# Accommodate both standard system mappings for sigma-cli binary calls
if command -v sigma-cli &> /dev/null; then
    check_tool "sigma-cli" "--version"
else
    check_tool "sigma" "--version"
fi

check_tool "xmllint" "--version"
check_tool "curl" "--version"

# 2. Verify Directory Infrastructure Resolution
for var_name in HANDOFF_DIR BASELINE_PKG CATALOG_DIR TRIAGE_PKG ASSETS_DIR; do
    dir_val=$(eval echo "\$$var_name")
    if [[ -z "$dir_val" ]]; then
        log_error "Environment variable $var_name is unset or empty."
    elif [[ ! -d "$dir_val" ]]; then
        log_error "Directory path $var_name ($dir_val) does not exist."
    fi
done

# Terminate early if foundational paths are broken before parsing files
if [ $STATUS_FAILED -ne 0 ]; then
    echo "Initial dependency checks failed. Halting analysis."
    exit 1
fi

# 3. Check Enrichment Datasets Validation
ENRICHED_EVENTS_FILE="$HANDOFF_DIR/data/enriched_events.json"
if [[ -s "$ENRICHED_EVENTS_FILE" ]]; then
    echo "handoff      : ok (enriched_events.json present)"
else
    log_error "handoff      : failed (enriched_events.json missing or zero size)"
fi

# 4. Count Sigma Rules Repository Presence
SIGMA_RULES_PATH="$CATALOG_DIR/rules/sigma"
if [[ -d "$SIGMA_RULES_PATH" ]]; then
    RULE_COUNT=$(find "$SIGMA_RULES_PATH" -type f \( -name "*.yml" -o -name "*.yaml" \) | wc -l)
    echo "catalog      : ok ($RULE_COUNT sigma rules)"
else
    log_error "catalog      : failed (Sigma directory missing from rules repository path)"
fi

# 5. Confirm Wazuh Export Signatures & Workflow Traces State
W_EXPORT_DIR="$ASSETS_DIR/wazuh_exports"
EXPORT_CHECK_OK=true

declare -a expected_exports=(
    "field_mapping.json"
    "index_metadata.json"
    "anchor_search_results.json"
    "scenario_a_search_results.json"
    "scenario_b_search_results.json"
    "scenario_c_search_results.json"
    "anchor_dashboard_trace.json"
    "scenario_a_dashboard_trace.json"
    "scenario_b_dashboard_trace.json"
    "scenario_c_dashboard_trace.json"
)

for file_item in "${expected_exports[@]}"; do
    if [[ ! -s "$W_EXPORT_DIR/$file_item" ]]; then
        EXPORT_CHECK_OK=false
    fi
done

if [ "$EXPORT_CHECK_OK" = true ]; then
    echo "wazuh_exports : ok (field_mapping, index_metadata, 4 search_results, 4 dashboard_traces)"
else
    log_error "wazuh_exports : failed (one or more verification assets are empty or missing)"
fi

# 6. Parse and Cross-Match Anchor Baseline Records
ANCHOR_FILE="$ASSETS_DIR/anchor_event.json"
if [[ -s "$ANCHOR_FILE" ]]; then
    # Extract structural metadata values using jq
    TARGET_HOST=$(jq -r '.target_host // empty' "$ANCHOR_FILE")
    START_TIME=$(jq -r '.time_window.start // empty' "$ANCHOR_FILE")
    END_TIME=$(jq -r '.time_window.end // empty' "$ANCHOR_FILE")
    
    if [[ -z "$TARGET_HOST" || -z "$START_TIME" || -z "$END_TIME" ]]; then
        log_error "anchor      : failed (could not extract asset windows from anchor_event.json)"
    else
        # Cross-reference records inside enriched_events line-by-line or within explicit block mappings
        # Check if any row maps directly back to the target host value
        MATCH_COUNT=$(grep -c "$TARGET_HOST" "$ENRICHED_EVENTS_FILE" || true)
        
        if [ "$MATCH_COUNT" -gt 0 ]; then
            echo "anchor      : ok ($TARGET_HOST matched in enriched_events.json)"
        else
            log_error "anchor      : failed (no log items for $TARGET_HOST detected in downstream package)"
        fi
    fi
else
    log_error "anchor      : failed (anchor_event.json reference file missing)"
fi

# 7. Final Assessment Execution Route
if [ $STATUS_FAILED -eq 0 ]; then
    echo "all checks  : passed"
    exit 0
else
    echo "all checks  : failed"
    exit 1
fi
