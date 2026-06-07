#!/bin/bash
# MedDefense Module 3 — Environment Variables
# Sourced automatically from ~/.bashrc inside the lab container.
# Can also be sourced manually: source ~/m3_env.sh
#
# PLATFORM NOTE:
#   WAZUH_URL is NOT overridden here if it was already set by the platform.
#   Mode C platforms inject:  WAZUH_URL=http://meddefense-wazuh:5601
#   Mode B default:           WAZUH_URL=http://localhost:5601
#   The default below is only used if WAZUH_URL is not already in the environment.

# ── Project output directories ───────────────────────────────────────────────
export HANDOFF_DIR="$HOME/3x00_handoff/evidence_handoff"
export BASELINE_PKG="$HOME/3x01_package/baseline_package"
export CATALOG_DIR="$HOME/3x02_package/detection_catalog"
export TRIAGE_PKG="$HOME/3x03_package/triage_package"
export TOOL_EVAL="$HOME/3x04_package/tool_evaluation"

# ── Per-project asset directories (read-only lab inputs) ─────────────────────
# ASSETS_DIR is overridden per-project. Set it before running project tasks:
#   3x02: export ASSETS_DIR=$HOME/3x02_assets
#   3x03: export ASSETS_DIR=$HOME/3x03_assets
#   3x04: export ASSETS_DIR=$HOME/3x04_assets   (default below)
export ASSETS_DIR="${ASSETS_DIR:-$HOME/3x04_assets}"

# ── Wazuh dashboard URL ───────────────────────────────────────────────────────
# Do NOT override if already set (Mode C platform injection takes priority).
#   Mode C (platform sidecar):  platform sets WAZUH_URL=http://meddefense-wazuh:5601
#   Mode B (Docker socket):     default below is used, access via SSH tunnel
#   Mode A (CLI-only):          WAZUH_URL is set but Wazuh is not available
export WAZUH_URL="${WAZUH_URL:-http://localhost:5601}"

# ── Capstone overrides (uncomment and export at the start of 3x05) ───────────
# export CAPSTONE_PACK="/srv/bt-m3/capstone/pack"
# export HANDOFF_DIR="/srv/bt-m3/handoff"
# export ASSETS_DIR="$CAPSTONE_PACK/meta"
# export SHIFT_WORKSPACE="$HOME/bt/3x05/shift_pack"
# export PIPELINE_BIN="$HOME/bt/3x00/pipeline/run_pipeline.sh"
# export BASELINE_BIN="$HOME/bt/3x01/baseline/build_baseline.sh"
# export TRIAGE_BIN="$HOME/bt/3x03/triage/triage.sh"
