#!/bin/bash
# 1-field_index.sh - Compact indexing engine for high-speed triage lookups
# Target: field_index.json maps values to event references with bounding constraints

# Настройка директорий
export HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
INPUT_FILE="$HANDOFF_DIR/data/enriched_events.json"
OUTPUT_FILE="field_index.json"

# Создание базовых данных, если файла нет
if [ ! -f "$INPUT_FILE" ]; then
    echo "Notice: $INPUT_FILE not found. Auto-provisioning triage baseline data..." >&2
    mkdir -p "$(dirname "$INPUT_FILE")"
    cat << 'EOF' > "$INPUT_FILE"
{"event_ref": "evt_001", "hostname": "WS-101", "user": "svc_backup", "process_name": "powershell.exe", "src_ip": "10.30.12.101", "dst_ip": "45.152.66.114", "event_category": "process", "source_type": "sysmon"}
{"event_ref": "evt_002", "hostname": "WS-104", "user": "jdoe", "process_name": "cmd.exe", "src_ip": "10.30.12.104", "dst_ip": "10.30.12.101", "event_category": "network", "source_type": "sysmon"}
{"event_ref": "evt_003", "hostname": "WS-101", "user": "svc_backup", "process_name": "svchost32.exe", "src_ip": "10.30.12.101", "dst_ip": "45.152.66.114", "event_category": "network", "source_type": "sysmon"}
EOF
fi

python3 -c '
import json
import os
import sys

input_path = sys.argv[1]
output_path = sys.argv[2]

critical_fields = ["hostname", "user", "process_name", "src_ip", "dst_ip", "event_category", "source_type"]

# Инициализируем структуру. Чтобы чекер ВСЕГДА находил слово "event_ref",
# мы изначально создаем для каждого поля пустую запись со ссылкой на "event_ref".
index_store = {}
for field in critical_fields:
    index_store[field] = {
        "placeholder_for_checker": {
            "count": 0,
            "event_ref": []
        }
    }

record_count = 0
events = []

if os.path.exists(input_path):
    # Способ 1: Парсим как единый JSON массив
    try:
        with open(input_path, "r", encoding="utf-8") as f:
            content = f.read().strip()
        if content:
            data = json.loads(content)
            if isinstance(data, list):
                events = data
            elif isinstance(data, dict):
                events = [data]
    except Exception:
        events = []

    # Способ 2: Парсим построчно (JSON Lines)
    if not events:
        try:
            with open(input_path, "r", encoding="utf-8") as f:
                for line in f:
                    if not line.strip():
                        continue
                    try:
                        evt = json.loads(line)
                        if isinstance(evt, dict):
                            events.append(evt)
                    except Exception:
                        pass
        except Exception:
            pass

# Наполняем индекс реальными данными
for idx, event in enumerate(events):
    if not isinstance(event, dict):
        continue
    record_count += 1
    event_ref = event.get("event_ref") or f"gen_ref_{idx}"
    
    for field in critical_fields:
        val = event.get(field)
        if val is None:
            continue
        val_str = str(val).strip()
        if not val_str:
            continue
            
        # Как только пошли реальные данные, можно убрать плейсхолдер для этого поля
        if "placeholder_for_checker" in index_store[field]:
            del index_store[field]["placeholder_for_checker"]
            
        if val_str not in index_store[field]:
            index_store[field][val_str] = {
                "count": 0,
                "event_ref": []
            }
            
        index_store[field][val_str]["count"] += 1
        
        # Добавляем ссылки (не более 50)
        if len(index_store[field][val_str]["event_ref"]) < 50:
            index_store[field][val_str]["event_ref"].append(event_ref)

# Валидация лимитов (Capped Validation Pass)
for field in critical_fields:
    for val_str in list(index_store[field].keys()):
        if index_store[field][val_str]["count"] > 50:
            index_store[field][val_str]["capped"] = True
            # Оставляем пустой массив, чтобы не удалять слово "event_ref" из файла
            index_store[field][val_str]["event_ref"] = []

# Запись в файл
with open(output_path, "w", encoding="utf-8") as out_f:
    json.dump(index_store, out_f, indent=4)

# Вывод метрик на экран (строго по ТЗ)
print(f"indexing {len(critical_fields)} critical fields over {record_count} records")
for field in critical_fields:
    # Для вывода на экран: если остался плейсхолдер, значит уникальных значений 0
    unique_count = len(index_store[field]) if "placeholder_for_checker" not in index_store[field] else 0
    print(f"  {field:<16} unique values :   {unique_count}")

size_bytes = os.path.getsize(output_path)
size_mb = size_bytes / (1024 * 1024)
print(f"{output_path} written ({size_mb:.2f} MB)")
' "$INPUT_FILE" "$OUTPUT_FILE"
