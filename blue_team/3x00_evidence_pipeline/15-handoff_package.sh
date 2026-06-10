#!/bin/bash
# 15-handoff_package.sh - Evidence Handoff Package Assembler
# Targeted for Ubuntu 22.04 LTS. Compliant with shellcheck.

set -euo pipefail
IFS=$'\n\t'

# Определение целевой директории сборки пакета с дефолтным значением
TARGET_DIR="${HANDOFF_DIR:-${HOME}/3x00_handoff/evidence_handoff}"

# Списки файлов по целевым категориям (структура контракта)
declare -a DATA_FILES=("normalized_events.json" "enriched_events.json" "timeline_index.json" "network_events.json" "quarantine.json")
declare -a REPORT_FILES=("source_inventory.json" "validation_report.json" "cleaning_log.json" "source_stats.json" "pipeline_test_report.json")
declare -a SCHEMA_FILES=("event_schema.json")
declare -a PIPELINE_FILES=("evidence_pipeline.sh" "0-source_inventory.sh" "1-telemetry_import.sh" "2-windows_parse.sh" "3-linux_parse.sh" "5-normalize.sh" "6-network_normalize.sh" "7-schema_validate.sh" "8-data_quality.sh" "9-enrich.sh" "10-timeline.sh" "11-source_stats.sh")

# Полная очистка целевой директории перед сборкой для точности MANIFEST.json
if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
fi

# Подготовка дерева каталогов
mkdir -p "$TARGET_DIR/data"
mkdir -p "$TARGET_DIR/context"
mkdir -p "$TARGET_DIR/reports"
mkdir -p "$TARGET_DIR/schema"
mkdir -p "$TARGET_DIR/pipeline"

# 1. Копирование секции data
data_count=0
for f in "${DATA_FILES[@]}"; do
    if [ -f "$f" ]; then
        cp "$f" "$TARGET_DIR/data/"
        data_count=$((data_count + 1))
    fi
done
echo "copying data/       ... $data_count files"

# 2. Копирование секции context (Поиск в локальных и резервных путях лабы)
context_count=0
for f in "asset_inventory.json" "network_zones.json"; do
    if [ -f "context/$f" ]; then
        cp "context/$f" "$TARGET_DIR/context/$f"
        context_count=$((context_count + 1))
    elif [ -f "evidence_pack_primary/context/$f" ]; then
        cp "evidence_pack_primary/context/$f" "$TARGET_DIR/context/$f"
        context_count=$((context_count + 1))
    elif [ -f "${HOME}/evidence_pack_primary/context/$f" ]; then
        cp "${HOME}/evidence_pack_primary/context/$f" "$TARGET_DIR/context/$f"
        context_count=$((context_count + 1))
    fi
done
echo "copying context/    ... $context_count files"

# 3. Копирование секции reports
reports_count=0
for f in "${REPORT_FILES[@]}"; do
    if [ -f "$f" ]; then
        cp "$f" "$TARGET_DIR/reports/"
        reports_count=$((reports_count + 1))
    fi
done
echo "copying reports/    ... $reports_count files"

# 4. Копирование секции schema
schema_count=0
for f in "${SCHEMA_FILES[@]}"; do
    if [ -f "$f" ]; then
        cp "$f" "$TARGET_DIR/schema/"
        schema_count=$((schema_count + 1))
    fi
done
echo "copying schema/     ... $schema_count file"

# 5. Копирование секции pipeline
pipeline_count=0
for f in "${PIPELINE_FILES[@]}"; do
    if [ -f "$f" ]; then
        cp "$f" "$TARGET_DIR/pipeline/"
        pipeline_count=$((pipeline_count + 1))
    fi
done
echo "copying pipeline/   ... $pipeline_count files"

# 6. Копирование спецификации pipeline_spec.md
spec_count=0
if [ -f "pipeline_spec.md" ]; then
    cp "pipeline_spec.md" "$TARGET_DIR/"
    spec_count=1
fi
echo "copying spec        ... $spec_count file"

# Экспорт переменной пути для обработки движком Python
export TARGET_DIR

# Генерация валидного MANIFEST.json (Используется glob без кортежей и запятых)
python3 - << 'EOF'
import os
import hashlib
import json
from glob import glob

target_dir = os.environ['TARGET_DIR']
manifest = {}

# Рекурсивный поиск файлов через безопасный паттерн glob
for abs_path in glob(os.path.join(target_dir, '**', '*'), recursive=True):
    if not os.path.isfile(abs_path):
        continue
    file_name = os.path.basename(abs_path)
    if file_name == "MANIFEST.json":
        continue
        
    rel_path = os.path.relpath(abs_path, target_dir)
    sha256_hash = hashlib.sha256()
    with open(abs_path, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
            
    manifest[rel_path] = {
        "path": rel_path,
        "size_bytes": os.path.getsize(abs_path),
        "sha256": sha256_hash.hexdigest()
    }

with open(os.path.join(target_dir, "MANIFEST.json"), "w", encoding="utf-8") as mf:
    json.dump(manifest, mf, indent=2)

print(f"MANIFEST.json       : {len(manifest)} entries")
EOF

# 7. Финальный Sanity Check с использованием стандартного find на уровне Bash
actual_count=$(find "$TARGET_DIR" -type f ! -name "MANIFEST.json" | wc -l)
empty_count=$(find "$TARGET_DIR" -type f ! -name "MANIFEST.json" -empty | wc -l)
expected_total=26

if [ "$actual_count" -eq "$expected_total" ] && [ "$empty_count" -eq 0 ]; then
    echo "handoff sanity check: ok"
    echo "evidence_handoff/ ready"
    exit 0
else
    echo "handoff sanity check: failed (Expected 26 non-empty files, found $actual_count. Empty: $empty_count)" >&2
    exit 1
fi
