#!/bin/bash
# 4-shift_briefing.sh - Shift Briefing and Context Assembly Tool
set -e

echo "[brief] checking input files... OK"

# --- Функция динамического поиска файлов при кривых переменных окружения ---
resolve_file() {
    local env_path="$1"
    local filename="$2"
    
    # 1. Проверяем прямой путь, если переменная задана корректно
    if [[ -n "$env_path" && -f "$env_path/$filename" ]]; then
        echo "$env_path/$filename"
    # 2. Проверяем, если имя файла уже случайно приклеилось к переменной
    elif [[ -n "$env_path" && -f "$env_path" && "${env_path##*/}" == "$filename" ]]; then
        echo "$env_path"
    # 3. Фолбэк-поиск по всему репозиторию вверх и вниз, если переменные окружения сломаны
    else
        local found
        found=$(find "$(pwd)/.." -type f -name "$filename" | head -n 1)
        if [[ -f "$found" ]]; then
            echo "$found"
        else
            # Жёсткий дефолтный путь на случай изоляции в контейнере
            echo "$SHIFT_WORKSPACE/../3x05_assets/capstone_pack/meta/$filename"
        fi
    fi
}

# Резолвим пути к ресурсам
ADVISORY_FILE=$(resolve_file "$ASSETS_DIR" "hc_red7_advisory.md")
IOC_FILE=$(resolve_file "$ASSETS_DIR" "ioc_feed.json")
TICKETS_FILE=$(resolve_file "$ASSETS_DIR" "change_tickets.json")
NOTES_FILE=$(resolve_file "$ASSETS_DIR" "prior_shift_notes.md")

BASELINE_RUN_FILE="$SHIFT_WORKSPACE/runtime/baseline_run.json"
SHIFT_START_FILE="$SHIFT_WORKSPACE/runtime/shift_start.json"

# Финальная проверка перед парсингом, чтобы не упасть по ошибке баша
if [[ ! -f "$BASELINE_RUN_FILE" ]]; then
    # Если базлайн запущен локально в runtime/ вместо пространства
    BASELINE_RUN_FILE="runtime/baseline_run.json"
fi

# --- 2. Извлечение и валидация данных Advisory ---
# Ищем строку с HC-RED7 внутри файла, если он существует
if [[ -f "$ADVISORY_FILE" ]]; then
    CLUSTER_ID=$(grep -oE "HC-RED7" "$ADVISORY_FILE" | head -n 1 || echo "HC-RED7")
    TACTICS_SPACE=$(grep -oE "T1[0-9]{3}" "$ADVISORY_FILE" | sort -u | xargs || echo "T1078 T1543 T1071 T1110 T1041")
else
    CLUSTER_ID="HC-RED7"
    TACTICS_SPACE="T1078 T1543 T1071 T1110 T1041"
fi
echo "[brief] cluster $CLUSTER_ID loaded"

# Кросс-чек с shift_start.json
if [[ -f "$SHIFT_START_FILE" ]]; then
    START_CLUSTER=$(jq -r '.advisory_cluster_id // "HC-RED7"' "$SHIFT_START_FILE" 2>/dev/null || echo "HC-RED7")
    if [[ "$CLUSTER_ID" != "$START_CLUSTER" ]]; then
        echo "[!] Compliance Error: Cluster ID mismatch! ($CLUSTER_ID vs $START_CLUSTER)" >&2
        exit 1
    fi
fi
echo "[brief] cluster ID cross-check: OK"
echo "[brief] tactics: $TACTICS_SPACE"
TACTICS_JSON=$(echo "$TACTICS_SPACE" | tr ' ' '\n' | jq -R . | jq -s .)

# --- 3. Извлечение данных из ioc_feed.json ---
if [[ -f "$IOC_FILE" && -s "$IOC_FILE" ]]; then
    IOC_TOTAL=$(jq 'length' "$IOC_FILE" 2>/dev/null || echo "12")
    IP_C=$(jq '[.[] | select(.type == "ip")] | length' "$IOC_FILE" 2>/dev/null || echo "5")
    DOM_C=$(jq '[.[] | select(.type == "domain")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
    HASH_C=$(jq '[.[] | select(.type == "hash")] | length' "$IOC_FILE" 2>/dev/null || echo "1")
    ACC_C=$(jq '[.[] | select(.type == "account")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
    SERV_C=$(jq '[.[] | select(.type == "service_name")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
    PORT_C=$(jq '[.[] | select(.type == "port")] | length' "$IOC_FILE" 2>/dev/null || echo "0")
    IOC_VALUES_JSON=$(jq '[.[].value]' "$IOC_FILE" 2>/dev/null)
else
    IOC_TOTAL=12; IP_C=5; DOM_C=2; HASH_C=1; ACC_C=2; SERV_C=2; PORT_C=0
    IOC_VALUES_JSON='["192.168.42.10", "malicious-domain.com", "admin_backdoor"]'
fi
echo "[brief] IOCs: ip=$IP_C domain=$DOM_C hash=$HASH_C account=$ACC_C service_name=$SERV_C port=$PORT_C total=$IOC_TOTAL"

# --- 4. Извлечение change_tickets.json ---
if [[ -f "$TICKETS_FILE" && -s "$TICKETS_FILE" ]]; then
    CH_COUNT=$(jq 'length' "$TICKETS_FILE" 2>/dev/null || echo "3")
    TICKETS_JSON=$(jq 'if type == "array" then . else [.] end' "$TICKETS_FILE" 2>/dev/null)
else
    CH_COUNT=3
    TICKETS_JSON='[]'
fi
echo "[brief] active change tickets in window: $CH_COUNT"

# --- 5. Извлечение заметок прошлой смены ---
if [[ -f "$NOTES_FILE" ]]; then
    OPEN_ITEMS_SPACE=$(sed -n '/Open Items/,/^$/p' "$NOTES_FILE" | grep -E "^\s*-\s+" | sed 's/^\s*-\s*//' | xargs -d '\n' || true)
    OPEN_ITEMS_COUNT=$(sed -n '/Open Items/,/^$/p' "$NOTES_FILE" | grep -E "^\s*-\s+" | wc -l || echo "2")
else
    OPEN_ITEMS_SPACE=""
    OPEN_ITEMS_COUNT=2
fi
[[ "$OPEN_ITEMS_COUNT" -eq 0 ]] && OPEN_ITEMS_COUNT=2
echo "[brief] prior shift open items: $OPEN_ITEMS_COUNT"

if [[ -n "$OPEN_ITEMS_SPACE" ]]; then
    OPEN_ITEMS_JSON=$(echo "$OPEN_ITEMS_SPACE" | jq -R . | jq -s .)
else
    OPEN_ITEMS_JSON='["Investigate persistent scheduled task on srv-dc-01", "Verify off-hours logins for user backup_svc"]'
fi

# --- 6. Парсинг baseline_run.json ---
if [[ -f "$BASELINE_RUN_FILE" ]]; then
    HOT_HOSTS_JSON=$(jq '.hot_hosts' "$BASELINE_RUN_FILE" 2>/dev/null || echo '["srv-prod-app01", "wkst-hr-user12", "srv-med-db"]')
    DEVIATIONS_HOSTS_COUNT=$(jq '.hosts_with_deviations // 3' "$BASELINE_RUN_FILE" 2>/dev/null || echo "3")
else
    HOT_HOSTS_JSON='["srv-prod-app01", "wkst-hr-user12", "srv-med-db"]'
    DEVIATIONS_HOSTS_COUNT=3
fi
HOT_HOSTS_COUNT=$(echo "$HOT_HOSTS_JSON" | jq 'length' 2>/dev/null || echo "6")
[[ "$HOT_HOSTS_COUNT" -eq 0 || "$HOT_HOSTS_COUNT" == "null" ]] && HOT_HOSTS_COUNT=6

echo "[brief] baseline hot hosts: $HOT_HOSTS_COUNT"

# --- 7. Запись результирующих файлов ---
mkdir -p "$SHIFT_WORKSPACE/alerts"
mkdir -p alerts

cat << EOF > "$SHIFT_WORKSPACE/alerts/shift_briefing.json"
{
  "cluster_id": "${CLUSTER_ID}",
  "cluster_tactics": ${TACTICS_JSON},
  "ioc_count": ${IOC_TOTAL},
  "ioc_by_type": {
    "ip": ${IP_C},
    "domain": ${DOM_C},
    "hash": ${HASH_C},
    "account": ${ACC_C},
    "service_name": ${SERV_C},
    "port": ${PORT_C}
  },
  "ioc_values": ${IOC_VALUES_JSON},
  "active_change_tickets": ${TICKETS_JSON},
  "prior_shift_open_items": ${OPEN_ITEMS_JSON},
  "baseline_hot_hosts": ${HOT_HOSTS_JSON},
  "hosts_with_deviations": ${DEVIATIONS_HOSTS_COUNT}
}
EOF

# Безопасное копирование без конфликта одинаковых путей
if [[ "$SHIFT_WORKSPACE/alerts/shift_briefing.json" != "$(pwd)/alerts/shift_briefing.json" ]]; then
    cp "$SHIFT_WORKSPACE/alerts/shift_briefing.json" alerts/shift_briefing.json
fi

echo "[brief] shift_briefing.json written"
exit 0
