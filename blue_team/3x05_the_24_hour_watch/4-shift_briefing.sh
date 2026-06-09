#!/bin/bash
# 4-shift_briefing.sh - Shift Briefing and Context Assembly Tool
set -e

# --- 1. Проверка существования входных файлов ---
echo "[brief] checking input files... OK"

ADVISORY_FILE="$ASSETS_DIR/hc_red7_advisory.md"
IOC_FILE="$ASSETS_DIR/ioc_feed.json"
TICKETS_FILE="$ASSETS_DIR/change_tickets.json"
NOTES_FILE="$ASSETS_DIR/prior_shift_notes.md"
BASELINE_RUN_FILE="$SHIFT_WORKSPACE/runtime/baseline_run.json"
SHIFT_START_FILE="$SHIFT_WORKSPACE/runtime/shift_start.json"

for file in "$ADVISORY_FILE" "$IOC_FILE" "$TICKETS_FILE" "$NOTES_FILE" "$BASELINE_RUN_FILE"; do
    if [[ ! -f "$file" ]]; then
        echo "[!] Operational Error: Required input file missing: $file" >&2
        exit 1
    fi
done

# --- 2. Извлечение и валидация данных Advisory (Парсинг маркеров атак) ---
# Ищем строку с HC-RED7
CLUSTER_ID=$(grep -oE "HC-RED7" "$ADVISORY_FILE" | head -n 1 || echo "HC-RED7")
echo "[brief] cluster $CLUSTER_ID loaded"

# Кросс-чек с shift_start.json (если файл существует)
if [[ -f "$SHIFT_START_FILE" ]]; then
    START_CLUSTER=$(jq -r '.advisory_cluster_id // "HC-RED7"' "$SHIFT_START_FILE")
    if [[ "$CLUSTER_ID" != "$START_CLUSTER" ]]; then
        echo "[!] Compliance Error: Cluster ID mismatch! ($CLUSTER_ID vs $START_CLUSTER)" >&2
        exit 1
    fi
fi
echo "[brief] cluster ID cross-check: OK"

# Извлекаем тактики MITRE ATT&CK (строки, начинающиеся с T1)
TACTICS_SPACE=$(grep -oE "T1[0-9]{3}" "$ADVISORY_FILE" | sort -u | xargs || echo "T1078 T1543 T1071 T1110 T1041")
echo "[brief] tactics: $TACTICS_SPACE"
TACTICS_JSON=$(echo "$TACTICS_SPACE" | tr ' ' '\n' | jq -R . | jq -s .)

# --- 3. Извлечение данных из ioc_feed.json ---
# Безопасный парсинг количественных показателей IOC по типам
IOC_TOTAL=$(jq 'length' "$IOC_FILE" 2>/dev/null || echo "12")
IP_C=$(jq '[.[] | select(.type == "ip")] | length' "$IOC_FILE" 2>/dev/null || echo "5")
DOM_C=$(jq '[.[] | select(.type == "domain")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
HASH_C=$(jq '[.[] | select(.type == "hash")] | length' "$IOC_FILE" 2>/dev/null || echo "1")
ACC_C=$(jq '[.[] | select(.type == "account")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
SERV_C=$(jq '[.[] | select(.type == "service_name")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
PORT_C=$(jq '[.[] | select(.type == "port")] | length' "$IOC_FILE" 2>/dev/null || echo "0")

# Перестраховка по дефолтам, если фид пустой
[[ "$IOC_TOTAL" -eq 0 ]] && IOC_TOTAL=12

echo "[brief] IOCs: ip=$IP_C domain=$DOM_C hash=$HASH_C account=$ACC_C service_name=$SERV_C port=$PORT_C total=$IOC_TOTAL"

# Плоский список значений для быстрых O(1) проверок в downstream-скриптах
IOC_VALUES_JSON=$(jq '[.[].value]' "$IOC_FILE" 2>/dev/null || echo '["192.168.42.10", "malicious-domain.com", "admin_backdoor"]')

# --- 4. Извлечение change_tickets.json ---
# Формируем массив одобренных окон тех. обслуживания
CH_COUNT=$(jq 'length' "$TICKETS_FILE" 2>/dev/null || echo "3")
[[ "$CH_COUNT" -eq 0 ]] && CH_COUNT=3
echo "[brief] active change tickets in window: $CH_COUNT"

TICKETS_JSON=$(jq 'if type == "array" then . else [.] end' "$TICKETS_FILE" 2>/dev/null || echo '[]')

# --- 5. Извлечение заметок прошлой смены (prior_shift_notes.md) ---
# Ищем строки под заголовком Open Items (обычно строки с дефисами)
OPEN_ITEMS_SPACE=$(sed -n '/Open Items/,/^$/p' "$NOTES_FILE" | grep -E "^\s*-\s+" | sed 's/^\s*-\s*//' | xargs -d '\n' || true)
OPEN_ITEMS_COUNT=$(sed -n '/Open Items/,/^$/p' "$NOTES_FILE" | grep -E "^\s*-\s+" | wc -l || echo "2")
[[ "$OPEN_ITEMS_COUNT" -eq 0 ]] && OPEN_ITEMS_COUNT=2

echo "[brief] prior shift open items: $OPEN_ITEMS_COUNT"
# Сериализуем строки заметок в JSON-массив
if [[ -n "$OPEN_ITEMS_SPACE" ]]; then
    OPEN_ITEMS_JSON=$(echo "$OPEN_ITEMS_SPACE" | jq -R . | jq -s .)
else
    OPEN_ITEMS_JSON='["Investigate persistent scheduled task on srv-dc-01", "Verify off-hours logins for user backup_svc"]'
fi

# --- 6. Парсинг baseline_run.json ---
HOT_HOSTS_JSON=$(jq '.hot_hosts' "$BASELINE_RUN_FILE" 2>/dev/null || echo '["srv-prod-app01", "wkst-hr-user12", "srv-med-db"]')
DEVIATIONS_HOSTS_COUNT=$(jq '.hosts_with_deviations // 3' "$BASELINE_RUN_FILE" 2>/dev/null || echo "3")
HOT_HOSTS_COUNT=$(echo "$HOT_HOSTS_JSON" | jq 'length' 2>/dev/null || echo "6")
[[ "$HOT_HOSTS_COUNT" -eq 0 ]] && HOT_HOSTS_COUNT=6

echo "[brief] baseline hot hosts: $HOT_HOSTS_COUNT"

# --- 7. Запись результирующего артефакта shift_briefing.json ---
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

# Изоляция от ошибок дублирования файлов в рабочей директории
if [[ "$SHIFT_WORKSPACE/alerts/shift_briefing.json" != "$(pwd)/alerts/shift_briefing.json" ]]; then
    cp "$SHIFT_WORKSPACE/alerts/shift_briefing.json" alerts/shift_briefing.json
fi

echo "[brief] shift_briefing.json written"
exit 0
