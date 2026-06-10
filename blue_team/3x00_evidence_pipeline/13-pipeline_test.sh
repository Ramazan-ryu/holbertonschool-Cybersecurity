#!/bin/bash
# 13-pipeline_test.sh - Pipeline Generalization Test
# Targeted for Ubuntu 22.04 LTS. Compliant with shellcheck.

set -euo pipefail
IFS=$'\n\t'

# Целевой тестовый пакет данных (разрешаем тильду, если передано строкой)
TARGET_PACK="${HOME}/evidence_pack_secondary"
OUTPUT_REPORT="pipeline_test_report.json"
RUN_LOG="pipeline_run.log"

echo "running pipeline against ~/evidence_pack_secondary"

# Фиксация времени старта
START_TIME=$(date +%s)

# Запуск конвейера с перенаправлением потоков в лог-файл
# Позволяем оркестратору завершаться естественным образом, не падая по set -e
set +e
./evidence_pipeline.sh "$TARGET_PACK" > "$RUN_LOG" 2>&1
PIPELINE_EXIT_CODE=$?
set -e

# Фиксация времени окончания и расчет дельты
END_TIME=$(date +%s)
RUNTIME=$((END_TIME - START_TIME))

# Экспорт переменных для инлайнового движка Python
export RUN_LOG
export OUTPUT_REPORT
export TARGET_PACK
export PIPELINE_EXIT_CODE
export RUNTIME

# Запуск встроенного Python-скрипта для точного парсинга логов и генерации валидного JSON
python3 - << 'EOF'
import os
import sys
import json
import re

run_log = os.environ['RUN_LOG']
output_report = os.environ['OUTPUT_REPORT']
target_pack = os.environ['TARGET_PACK']
pipeline_exit_code = int(os.environ['PIPELINE_EXIT_CODE'])
runtime = int(os.environ['RUNTIME'])

stages = {}
all_stages_passed = True

# Регулярное выражение для поиска статусов стадий в выводе оркестратора
# Пример: [00:25:11] stage 2 windows_parse      ... ok (2s)
stage_regex = re.compile(r'stage\s+(\d+)\s+([a-zA-Z0-9_-]+)\s+\.\.\.\s+([a-zA-Z0-9_!]+)')

if os.path.exists(run_log):
    with open(run_log, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            match = stage_regex.search(line)
            if match:
                stage_num = match.group(1)
                stage_name = match.group(2)
                status = match.group(3).lower()
                
                # Приводим к единому формату pass/fail
                verdict = "pass" if "ok" in status else "fail"
                if verdict == "fail":
                    all_stages_passed = False
                    
                stages[f"stage_{stage_num}_{stage_name}"] = verdict

# Если оркестратор упал глобально или стадия завершилась неудачей
if pipeline_exit_code != 0:
    all_stages_passed = False

# Валидация выходных артефактов
enriched_file = "enriched_events.json"
timeline_file = "timeline_index.json"

enriched_count = 0
artifacts_valid = True

if os.path.exists(enriched_file) and os.path.getsize(enriched_file) > 0:
    try:
        with open(enriched_file, 'r', encoding='utf-8') as ef:
            # Считаем количество записей (поддерживаем как массив, так и NDJSON)
            content = ef.read().strip()
            if content.startswith('['):
                enriched_count = len(json.loads(content))
            else:
                enriched_count = len([line for line in content.splitlines() if line.strip()])
    except Exception:
        artifacts_valid = False
else:
    artifacts_valid = False

if not os.path.exists(timeline_file) or os.path.getsize(timeline_file) == 0:
    artifacts_valid = False

# Итоговый вердикт генерализации
final_verdict = "pass" if (all_stages_passed and artifacts_valid) else "fail"

# Сборка финальной структуры JSON-отчета
report_data = {
    "evidence_pack_path": target_pack,
    "runtime_seconds": runtime,
    "stages_result": stages,
    "final_event_count": enriched_count,
    "verdict": final_verdict
}

with open(output_report, 'w', encoding='utf-8') as rf:
    json.dump(report_data, rf, indent=2)

# Вывод в stdout строго по спецификации задания
if final_verdict == "pass":
    print("all 11 stages passed")
    print(f"enriched events: {enriched_count}")
    print(f"runtime: {runtime}s")
    print("verdict: pass")
    print("pipeline_test_report.json written")
    sys.exit(0)
else:
    print("[-] Generalization test failed. Check logs and generated artifacts.")
    print(f"verdict: fail")
    sys.exit(1)
EOF

# Захватываем код возврата Python-скрипта и транслируем наружу
exit $?
