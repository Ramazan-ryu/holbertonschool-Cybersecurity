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

# Функция адаптивного поиска файлов контекста
find_context_file() {
    local filename="$1"
    if [[ -f "context/$filename" ]]; then
        echo "context/$filename"
    elif [[ -f "evidence_pack_primary/context/$filename" ]]; then
        echo "evidence_pack_primary/context/$filename"
    elif [[ -f "${HOME}/evidence_pack_primary/context/$filename" ]]; then
        echo "${HOME}/evidence_pack_primary/context/$filename"
    else
        echo ""
    fi
}

# Подготовка дерева каталогов
mkdir -p "$TARGET_DIR/data"
mkdir -p "$TARGET_DIR/context"
mkdir -p "$TARGET_DIR/reports"
mkdir -p "$TARGET_DIR/schema"
mkdir -p "$TARGET_DIR/pipeline"

# 1. Копирование секции data
data_count=0
for f in "${DATA_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        cp "$f" "$TARGET_DIR/data/" && ((data_count++))
    fi
done
echo "copying data/       ... $data_count files"

# 2. Копирование секции context (извлекаем динамически)
context_count=0
for f in "asset_inventory.json" "network_zones.json"; do
    ctx_src=$(find_context_file "$f")
    if [[ -n "$ctx_src" && -f "$ctx_src" ]]; then
        cp "$ctx_src" "$TARGET_DIR/context/$f" && ((context_count++))
    fi
done
echo "copying context/    ... $context_count files"

# 3. Копирование секции reports
reports_count=0
for f in "${REPORT_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        cp "$f" "$TARGET_DIR/reports/" && ((reports_count++))
    fi
done
echo "copying reports/    ... $reports_count files"

# 4. Копирование секции schema
schema_count=0
for f in "${SCHEMA_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        cp "$f" "$TARGET_DIR/schema/" && ((schema_count++))
    fi
done
echo "copying schema/     ... $schema_count file"

# 5. Копирование секции pipeline
pipeline_count=0
for f in "${PIPELINE_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        cp "$f" "$TARGET_DIR/pipeline/" && ((pipeline_count++))
    fi
done
echo "copying pipeline/   ... $pipeline_count files"

# 6. Копирование спецификации pipeline_spec.md
spec_count=0
if [[ -f "pipeline_spec.md" ]]; then
    cp "pipeline_spec.md" "$TARGET_DIR/" && spec_count=1
fi
echo "copying spec        ... $spec_count file"

# Экспорт переменной пути для обработки движком Python
export TARGET_DIR

# Генерация валидного MANIFEST.json через встроенный Python
python3 - << 'EOF'
import os
import hashlib
import json

target_dir = os.environ['TARGET_DIR']
manifest = {}

# Рекурсивный обход сформированного дерева каталогов handoff
for root, _, files in os.walk(target_dir):
    for file in files:
        if file == "MANIFEST.json":
            continue
        abs_path = os.path.join(root, file)
        # Получаем относительный путь для чистоты манифеста
        rel_path = os.path.relpath(abs_path, target_dir)
        
        # Вычисление SHA-256
        sha256_hash = hashlib.sha256()
        with open(abs_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
                
        manifest[rel_path] = {
            "path": rel_path,
            "size_bytes": os.path.getsize(abs_path),
            "sha256": sha256_hash.hexdigest()
        }

# Запись MANIFEST.json внутрь пакета
with open(os.path.join(target_dir, "MANIFEST.json"), "w", encoding="utf-8") as mf:
    json.dump(manifest, mf, indent=2)

print(f"MANIFEST.json       : {len(manifest)} entries")
EOF

# 7. Запуск финальной проверки (Sanity Check) на целостность структуры
sanity_ok=true
expected_total=26 # Сумма всех файлов + pipeline_spec.md
actual_count=0

for root, _, files in os.walk("$TARGET_DIR"):
    for file in files:
        if file == "MANIFEST.json":
            continue
        abs_path = os.path.join(root, file)
        # Если файл пустой, проверка провалена
        if [[ ! -s "$abs_path" ]]; then
            sanity_ok=false
        fi
        ((actual_count++))
done

if [[ "$actual_count" -ne "$expected_total" ]]; then
    sanity_ok=false
fi

if [ "$sanity_ok" = true ]; then
    echo "handoff sanity check: ok"
    echo "evidence_handoff/ ready"
    exit 0
else
    echo "handoff sanity check: failed (missing or empty files detected)" >&2
    exit 1
fi
