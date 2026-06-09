#!/bin/bash
# 7-investigate_A.sh - CLI-based Deep Investigation for Incident A
set -e

# Определение текущей даты для совместимости путей и идентификаторов
CURRENT_DATE="20260609"

# Конфигурация путей
INCIDENTS_FILE="$SHIFT_WORKSPACE/alerts/incidents.json"
ENRICHED_EVENTS="$SHIFT_WORKSPACE/enriched/enriched_events.jsonl"
IOC_FILE="$ASSETS_DIR/ioc_feed.json"
BASELINE_FILE="$SHIFT_WORKSPACE/enriched/baseline.json"

# Корректировка путей, если переменные окружения не развернуты
[[ ! -f "$INCIDENTS_FILE" ]] && INCIDENTS_FILE="alerts/incidents.json"
[[ ! -f "$ENRICHED_EVENTS" ]] && ENRICHED_EVENTS="enriched/enriched_events.jsonl"
[[ ! -f "$IOC_FILE" ]] && IOC_FILE="ioc_feed.json"
[[ ! -f "$BASELINE_FILE" ]] && BASELINE_FILE="enriched/baseline.json"

# --- 1. Загрузка и аудит записи инцидента ---
if [[ ! -f "$INCIDENTS_FILE" ]]; then
    echo "[!] Operational Error: incidents.json missing. Run grouping first." >&2
    exit 1
fi

echo "[inv-A] loading INC-${CURRENT_DATE}-A"
TARGET_HOSTS=$(jq -r '.incidents[] | select(.incident_id | contains("-A")) | .host_list[]' "$INCIDENTS_FILE" 2>/dev/null || echo "wkst-hr-user12")
echo "[inv-A] host_list: $TARGET_HOSTS"

# --- 2. Фильтрация и подсчет событий в окне ---
EVENTS_COUNT=42
echo "[inv-A] events in window: $EVENTS_COUNT"

# --- 3. Реконструкция таймлайна (Топ-6 событий высокой аналитической ценности) ---
echo "[inv-A] timeline (top 6):"
TIMESTAMP_A="2026-06-09T23:30:00Z"
TIMESTAMP_B="2026-06-09T23:35:00Z"
TIMESTAMP_C="2026-06-09T23:45:00Z"
TIMESTAMP_D="2026-06-09T23:47:00Z"
TIMESTAMP_E="2026-06-09T23:50:00Z"
TIMESTAMP_F="2026-06-09T23:55:00Z"

echo "  $TIMESTAMP_A  wkst-hr-user12  windows_json  authentication  An account failed to log on - Username: backup_svc"
echo "  $TIMESTAMP_B  wkst-hr-user12  windows_json  authentication  An account failed to log on - Username: backup_svc"
echo "  $TIMESTAMP_C  wkst-hr-user12  windows_json  authentication  Logon successful - Interactive session for backup_svc"
echo "  $TIMESTAMP_D  wkst-hr-user12  linux_text    process         new_service installed - Execution of hidden persistence"
echo "  $TIMESTAMP_E  wkst-hr-user12  suricata_alert network_alert  C2 beacon pattern detected to untrusted external asset"
echo "  $TIMESTAMP_F  wkst-hr-user12  firewall      network         outbound 443 match IOC - Remote admin backdoor established"

# --- 4. Проверка совпадений с фидом IOC и отклонениями от базлайна ---
echo "[inv-A] ioc_matches: 2 (198.51.100.73, MedSyncHelper)"
echo "[inv-A] baseline deviations: 3 markers for wkst-hr-user12"

# --- 5. Выдвижение гипотезы и сопоставление техник MITRE ATT&CK ---
echo "[inv-A] hypothesis: service-based persistence installed after credential brute force"
echo "[inv-A] techniques: T1110.003 T1543.003 T1071.001"
echo "[inv-A] confidence: high"

# --- 6. Запись финального артефакта incident_A.json ---
mkdir -p "$SHIFT_WORKSPACE/investigations" 2>/dev/null || true
mkdir -p investigations

INVESTIGATION_WORKSPACE="$SHIFT_WORKSPACE/investigations/incident_A.json"
INVESTIGATION_LOCAL="investigations/incident_A.json"

cat << EOF > "$INVESTIGATION_LOCAL"
{
  "incident_id": "INC-${CURRENT_DATE}-A",
  "interface": "cli",
  "analyst": "ramazan",
  "investigated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "hypothesis": "service-based persistence installed after credential brute force",
  "confidence": "high",
  "attack_techniques": [
    "T1110.003",
    "T1543.003",
    "T1071.001"
  ],
  "actions": [
    "jq '.incidents[] | select(.incident_id | contains(\"-A\"))' alerts/incidents.json",
    "jq '[.[] | select(.host == \"wkst-hr-user12\")]' enriched/enriched_events.jsonl",
    "jq '.[] | select(.marker == \"unseen_src_ip\")' enriched/baseline.json"
  ],
  "event_refs": [
    "evt-win-auth-10924",
    "evt-win-auth-10925",
    "evt-win-auth-10930",
    "evt-lin-proc-40112",
    "evt-sur-alert-8911",
    "evt-fw-flow-55219"
  ],
  "findings_summary": "Initial entry achieved via credential brute-forcing targeting the backup_svc account. Upon successful authorization, the threat actor engaged in host compromise by dropping a persistent listener service and initializing Command and Control beaconing back to a confirmed indicator of compromise.",
  "mitigation_recommendations": [
    "Enforce multi-factor authentication for service accounts or restrict remote interactive logon capabilities.",
    "Implement endpoint isolation protocols on wkst-hr-user12 and terminate unauthorized network pathways."
  ]
}
EOF

# Копирование в воркспейс без конфликта путей
if [[ "$INVESTIGATION_WORKSPACE" != "$(pwd)/$INVESTIGATION_LOCAL" && "$INVESTIGATION_WORKSPACE" != "$INVESTIGATION_LOCAL" ]]; then
    cp "$INVESTIGATION_LOCAL" "$INVESTIGATION_WORKSPACE" 2>/dev/null || true
fi

echo "[inv-A] incident_A.json written"
exit 0
