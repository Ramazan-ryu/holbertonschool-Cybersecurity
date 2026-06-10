#!/bin/bash
# evidence_pipeline.sh
# End-to-End Orchestrator Script for the Evidence Pack Processing Chain.

# Exit immediately if an unhandled pipeline error occurs outside our controlled wrappers
set -e

# Help / Usage configuration overview
if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 <path_to_evidence_pack_root>"
    exit 1
fi

EVIDENCE_ROOT_RAW="$1"
# Resolve absolute canonical directory paths cleanly
EVIDENCE_ROOT=$(cd "$EVIDENCE_ROOT_RAW" 2>/dev/null && pwd || echo "")

# 1. Verification and Structural Directory Constraints Validation
if [ -z "$EVIDENCE_ROOT" ] || [ ! -d "$EVIDENCE_ROOT" ]; then
    echo "Error: Directory '$EVIDENCE_ROOT_RAW' does not exist."
    exit 1
fi

REQUIRED_SUBDIRS=("windows" "linux" "network" "context" "student_telemetry")
for subdir in "${REQUIRED_SUBDIRS[@]}"; do
    if [ ! -d "$EVIDENCE_ROOT/$subdir" ]; then
        echo "Error: Missing required forensic evidence pack subdirectory context structural mapping: $subdir/"
        exit 1
    fi
done

# Ensure the task 4 schema definition file exists before starting compilation
if [ ! -f "event_schema.json" ]; then
    echo "Error: Missing required validation constraints baseline schema component 'event_schema.json' inside working directory."
    exit 1
fi

# Export environment variable mappings for standard use down the pipeline
export EVIDENCE_PACK="$EVIDENCE_ROOT"

# Pipeline tracking configuration array
PIPELINE_START=$(date +%s)

# Helper execution function wrapper for timestamp logs, timer calculations, and graceful fast-failing
run_stage() {
    local stage_num="$1"
    local stage_script="$2"
    local stage_desc="$3"
    
    # Pre-emptively fix execution permissions if missing
    if [ -f "$stage_script" ] && [ ! -x "$stage_script" ]; then
        chmod +x "$stage_script"
    fi
    
    # Check if script exists and is executable
    if [ ! -x "$stage_script" ]; then
        echo "Error: Stage script '$stage_script' is missing or not executable."
        echo "Pipeline aborted at stage $stage_num."
        exit 1
    fi
    
    local time_stamp=$(date +"%H:%M:%S")
    printf "[%s] stage %s %-19s ... " "$time_stamp" "$stage_num" "$stage_desc"
    
    local stage_start=$(date +%s)
    
    # Execute script capturing stdout/stderr but preserving correct status tracking bubbles
    set +e
    ./"$stage_script" > /dev/null 2>&1
    local exit_code=$?
    set -e
    
    local stage_end=$(date +%s)
    local duration=$((stage_end - stage_start))
    
    if [ $exit_code -ne 0 ]; then
        echo "FAILED"
        echo "Error: Execution stopped. Stage $stage_num ($stage_desc) exited with non-zero status code $exit_code."
        exit $exit_code
    else
        echo "ok (${duration}s)"
    fi
}

# 2. Sequential Sequential Fast-Fail Executions
run_stage "0" "0-source_inventory.sh" "source_inventory"
run_stage "1" "1-telemetry_import.sh" "telemetry_import"
run_stage "2" "2-windows_parse.sh"    "windows_parse"
run_stage "3" "3-linux_parse.sh"      "linux_parse"
run_stage "5" "5-normalize.sh"        "normalize"
run_stage "6" "6-network_normalize.sh" "network_normalize"
run_stage "7" "7-schema_validate.sh"  "schema_validate"
run_stage "8" "8-data_quality.sh"     "data_quality"
run_stage "9" "9-enrich.sh"           "enrich"
run_stage "10" "10-timeline.sh"       "timeline"
run_stage "11" "11-source_stats.sh"   "source_stats"

# 3. Compile Final Extraction Metadata Indicators metrics for output stdout tracking dashboard
PIPELINE_END=$(date +%s)
TOTAL_RUNTIME=$((PIPELINE_END - PIPELINE_START))

ENRICHED_FILE="enriched_events.json"
TOTAL_EVENTS=0
if [ -f "$ENRICHED_FILE" ]; then
    TOTAL_EVENTS=$(wc -l < "$ENRICHED_FILE" | tr -d ' ')
fi

echo "pipeline ok. ${TOTAL_EVENTS} enriched events in ${TOTAL_RUNTIME}s"
