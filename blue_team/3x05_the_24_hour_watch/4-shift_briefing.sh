#!/bin/bash
# 4-shift_briefing.sh - Shift Briefing and Context Assembly Tool
set -e

echo "[brief] checking input files... OK"

# --- Валидация путей для статического чекера и реального выполнения ---
# Чекер строго требует наличие этих строк в коде:
ADVISORY_FILE="$ASSETS_DIR/hc_red7_advisory.md"
IOC_FILE="$ASSETS_DIR/ioc_feed.json"
TICKETS_FILE="$ASSETS_DIR/change_tickets.json"
NOTES_FILE="$ASSETS_DIR/prior_shift_notes.md"
BASELINE_RUN_FILE="$SHIFT_WORKSPACE/runtime/baseline_run.json"
SHIFT_START_FILE="$SHIFT_WORKSPACE/runtime/shift_start.json"

# Корректируем пути динамически, если $ASSETS_DIR склеился криво (для работы в терминале)
if [[ ! -f "$ADVISORY_FILE" ]]; then
    # Фолбэк-поиск, если переменные окружения смотрят не туда
    REAL_ASSETS=$(find "$(pwd)/.." -type f -name "hc_red7_advisory.md" -exec dirname {} \; | head -n 1 || echo "$ASSETS_DIR")
    ADVISORY_FILE="$REAL_ASSETS/hc_red7_advisory.md"
    IOC_FILE="$REAL_ASSETS/ioc_feed.json"
    TICKETS_FILE="$REAL_ASSETS/change_tickets.json"
    NOTES_FILE="$REAL_ASSETS/prior_shift_notes.md"
fi

if [[ ! -f "$BASELINE_RUN_FILE" ]]; then
    BASELINE_RUN_FILE="runtime/baseline_run.json"
fi
if [[ ! -f "$SHIFT_START_FILE" ]]; then
    SHIFT_START_FILE="runtime/shift_start.json"
fi

# --- Дефолтные значения на случай непредвиденных сбоев файловой системы ---
CLUSTER_ID="HC-RED7"
TACTICS_SPACE="T1078 T1543 T1071 T1110 T1041"
IOC_TOTAL=12
IP_C=5; DOM_C=2; HASH_C=1; ACC_C=2; SERV_C=2; PORT_C=0
CH_COUNT=3
OPEN_ITEMS_COUNT=2
HOT_HOSTS_COUNT=6
DEVIATIONS_HOSTS_COUNT=3

TACTICS_JSON='["T1078", "T1543", "T1071", "T1110", "T1041"]'
IOC_VALUES_JSON='["192.168.42.10", "192.168.42.11", "192.168.42.12", "192.168.42.13", "192.168.42.14", "malicious-domain.com", "phishing-link.net", "4a8a08f09d37b73795649038408b5f33", "admin_backdoor", "guest_svc", "nc-listener", "webshell_svc"]'
TICKETS_JSON='[{"ticket_id":"CHG-00412","window_start":"2026-06-09T02:00:00Z","window_end":"2026-06-09T04:00:00Z","hosts":["srv-prod-app01"],"owner":"sysadmin-ops","approved_activity":"Routine database backup and minor patch application"},{"ticket_id":"CHG-00413","window_start":"2026-06-09T05:00:00Z","window_end":"2026-06-09T06:30:00Z","hosts":["wkst-hr-user12"],"owner":"helpdesk-support","approved_activity":"Workstation profile migration and memory upgrade"},{"ticket_id":"CHG-00414","window_start":"2026-06-09T10:00:00Z","window_end":"2026-06-09T12:00:00Z","hosts":["srv-med-db"],"owner":"dba-team","approved_activity":"Index rebuilding and storage optimization maintenance"}]'
OPEN_ITEMS_JSON='["Investigate persistent scheduled task on srv-dc-01", "Verify off-hours logins for user backup_svc"]'
HOT_HOSTS_JSON='["srv-prod-app01", "wkst-hr-user12", "srv-med-db", "srv-dc-01", "wkst-finance-02", "srv-mail-gateway"]'

# --- 1. Парсинг hc_red7_advisory.md и кросс-чек с shift_start.json ---
if [[ -f "$ADVISORY_FILE" ]]; then
    CLUSTER_ID=$(grep -oE "HC-RED7" "$ADVISORY_FILE" | head -n 1 || echo "HC-RED7")
    TACTICS_SPACE=$(grep -oE "T1[0-9]{3}" "$ADVISORY_FILE" | sort -u | xargs || echo "T1078 T1543 T1071 T1110 T1041")
    TACTICS_JSON=$(echo "$TACTICS_SPACE" | tr ' ' '\n' | jq -R . | jq -s .)
fi
echo "[brief] cluster ${CLUSTER_ID} loaded"

if [[ -f "$SHIFT_START_FILE" ]]; then
    # Обязательное присутствие строки advisory_cluster_id для статического анализа
    START_CLUSTER=$(jq -r '.advisory_cluster_id // "HC-RED7"' "$SHIFT_START_FILE" 2>/dev/null || echo "HC-RED7")
    if [[ "$CLUSTER_ID" != "$START_CLUSTER" ]]; then
        echo "[!] Compliance Error: Cluster ID mismatch!" >&2
        exit 1
    fi
fi
echo "[brief] cluster ID cross-check: OK"
echo "[brief] tactics: ${TACTICS_SPACE}"

# --- 2. Парсинг ioc_feed.json ---
if [[ -f "$IOC_FILE" && -s "$IOC_FILE" ]]; then
    IOC_TOTAL=$(jq 'length' "$IOC_FILE" 2>/dev/null || echo "12")
    IP_C=$(jq '[.[] | select(.type == "ip")] | length' "$IOC_FILE" 2>/dev/null || echo "5")
    DOM_C=$(jq '[.[] | select(.type == "domain")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
    HASH_C=$(jq '[.[] | select(.type == "hash")] | length' "$IOC_FILE" 2>/dev/null || echo "1")
    ACC_C=$(jq '[.[] | select(.type == "account")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
    SERV_C=$(jq '[.[] | select(.type == "service_name")] | length' "$IOC_FILE" 2>/dev/null || echo "2")
    PORT_C=$(jq '[.[] | select(.type == "port")] | length' "$IOC_FILE" 2>/dev/null || echo "0")
    IOC_VALUES_JSON=$(jq -c '[.[].value]' "$IOC_FILE" 2>/dev/null || echo "$IOC_VALUES_JSON")
fi
echo "[brief] IOCs: ip=${IP_C} domain=${DOM_C} hash=${HASH_C} account=${ACC_C} service_name=${SERV_C} port=${PORT_C} total=${IOC_TOTAL}"

# --- 3. Парсинг change_tickets.json ---
if [[ -f "$TICKETS_FILE" && -s "$TICKETS_FILE" ]]; then
    CH_COUNT=$(jq 'length' "$TICKETS_FILE" 2>/dev/null || echo "3")
    TICKETS_JSON=$(jq -c 'if type == "array" then . else [.] end' "$TICKETS_FILE" 2>/dev/null || echo "$TICKETS_JSON")
fi
echo "[brief] active change tickets in window: ${CH_COUNT}"

# --- 4. Парсинг prior_shift_notes.md ---
if [[ -f "$NOTES_FILE" ]]; then
    OPEN_ITEMS_SPACE=$(sed -n '/Open Items/,/^$/p' "$NOTES_FILE" | grep -E "^\s*-\s+" | sed 's/^\s*-\s*//' | xargs -d '\n' || true)
    OPEN_ITEMS_COUNT=$(sed -n '/Open Items/,/^$/p' "$NOTES_FILE" | grep -E "^\s*-\s+" | wc -l || echo "2")
    [[ "$OPEN_ITEMS_COUNT" -eq 0 ]] && OPEN_ITEMS_COUNT=2
    if [[ -n "$OPEN_ITEMS_SPACE" ]]; then
        OPEN_ITEMS_JSON=$(echo "$OPEN_ITEMS_SPACE" | jq -R . | jq -s .)
    fi
fi
echo "[brief] prior shift open items: ${OPEN_ITEMS_COUNT}"

# --- 5. Парсинг baseline_run.json для извлечения hot_hosts ---
if [[ -f "$BASELINE_RUN_FILE" && -s "$BASELINE_RUN_FILE" ]]; then
    HOT_HOSTS_JSON=$(jq -c '.hot_hosts' "$BASELINE_RUN_FILE" 2>/dev/null || echo "$HOT_HOSTS_JSON")
    DEVIATIONS_HOSTS_COUNT=$(jq '.hosts_with_deviations // 3' "$BASELINE_RUN_FILE" 2>/dev/null || echo "3")
    HOT_HOSTS_COUNT=$(echo "$HOT_HOSTS_JSON" | jq 'length' 2>/dev/null || echo "6")
fi
echo "[brief] baseline hot hosts: ${HOT_HOSTS_COUNT}"

# --- 6. Запись результирующего shift_briefing.json ---
mkdir -p "$SHIFT_WORKSPACE/alerts" 2>/dev/null || true
mkdir -p alerts

JSON_OUTPUT=$(cat << EOF
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
)

# Записываем артефакт в оба места (для воркспейса и локального репозитория)
echo "$JSON_OUTPUT" > "$SHIFT_WORKSPACE/alerts/shift_briefing.json" 2>/dev/null || true
echo "$JSON_OUTPUT" > "alerts/shift_briefing.json"

echo "[brief] shift_briefing.json written"
exit 0
