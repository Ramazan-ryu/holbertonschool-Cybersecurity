#!/bin/bash
# 0-format_analysis.sh - Profiling tool for enriched datasets

# Configuration du répertoire par défaut
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
INPUT_FILE="$HANDOFF_DIR/data/enriched_events.json"
OUTPUT_FILE="format_analysis.json"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Erreur : Le fichier d'entrée $INPUT_FILE n'existe pas." >&2
    exit 1
fi

# Localisation du script Python d'aide dans le même répertoire
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PYTHON_HELPER="$SCRIPT_DIR/format_analysis.py"

if [ ! -f "$PYTHON_HELPER" ]; then
    echo "Erreur : Le script d'aide Python $PYTHON_HELPER est introuvable." >&2
    exit 1
fi

# Exécution du traitement Python
python3 "$PYTHON_HELPER" "$INPUT_FILE" "$OUTPUT_FILE"
