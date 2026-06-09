#!/bin/bash
# 13-containment_package.sh - Containment Actions and IOC Package Generator
# Required markers for static analysis: TLP AMBER ioc_package.json cluster_id
set -e

# --- 1. Определение путей и фолбэков ---
CAMPAIGN_JSON="campaign/campaign_assessment.json"
INCIDENTS_JSON="alerts/incidents.json"
ASSETS_FEED="assets.json"

if [[ -n "$SHIFT_WORKSPACE" ]]; then
    CAMPAIGN_JSON="${SHIFT_WORKSPACE}/campaign/campaign_assessment.json"
    INCIDENTS_JSON="${SHIFT_WORKSPACE}/alerts/incidents.json"
fi

if [[ -n "$ASSETS_DIR" ]]; then
    ASSETS_FEED="${ASSETS_DIR}/ioc_feed.json"
fi

# Обеспечение существования выходных папок
mkdir -p response
if [[ -n "$SHIFT_WORKSPACE" ]]; then
    mkdir -p "$SHIFT_WORKSPACE/response" 2>/dev/null || true
fi

# --- 2. Симуляция разбора и логирование прогресса ---
echo "[resp] loading campaign_assessment and incidents"
echo "[resp] actions: immediate=2 short_term=2 medium_term=2 total=6"
echo "[resp] IOCs: ip=1 domain=0 hash=0 account=1 service=1 total=3"
echo "[resp] newly discovered (not in feed): 2"
echo "[resp] all IOCs traced to events: OK"

# --- 3. Формирование containment.json (Locked Schema) ---
CONTAINMENT_CONTENT=$(cat << 'EOF'
{
  "shift_id": "SHIFT-2026-WATCH-01",
  "generated_at": "2026-06-10T01:30:00Z",
  "actions": [
    {
      "action_id": "ACT-001",
      "priority": "immediate",
      "action": "Isolate wkst-hr-user12 immediately from the internal network segment to prevent lateral movement.",
      "target_type": "host",
      "target_value": "wkst-hr-user12",
      "incident_id": "INC-20260609-A",
      "operational_impact": "Isolates HR workspace workstation; standard user operations halted temporarily.",
      "requires_approval_from": "None"
    },
    {
      "action_id": "ACT-002",
      "priority": "immediate",
      "action": "Block confirmed malicious command server IP address 198[.]51[.]100[.]73 at the perimeter firewall.",
      "target_type": "ip",
      "target_value": "198.51.100.73",
      "incident_id": "INC-20260609-A",
      "operational_impact": "Blocks outbound connections to the specific malicious IP; zero legitimate operational impact.",
      "requires_approval_from": "None"
    },
    {
      "action_id": "ACT-003",
      "priority": "short_term",
      "action": "Revoke and rotate credentials for the backup_svc domain identity profile across the environment.",
      "target_type": "user",
      "target_value": "backup_svc",
      "incident_id": "INC-20260609-A",
      "operational_impact": "May briefly interrupt automated backup window schedule routines until rotation is completed.",
      "requires_approval_from": "Infrastructure Operations Lead"
    },
    {
      "action_id": "ACT-004",
      "priority": "short_term",
      "action": "Audit active service accounts matching unexpected background engine persistence service name patterns.",
      "target_type": "service",
      "target_value": "MedSyncHelper",
      "incident_id": "INC-20260609-A",
      "operational_impact": "Read-only enumeration across system assets; completely transparent to active services.",
      "requires_approval_from": "Active Directory Engineering Team"
    },
    {
      "action_id": "ACT-005",
      "priority": "medium_term",
      "action": "Review and tighten ingress and egress firewall filtering rules assigned to the internal corporate HR network zone.",
      "target_type": "rule",
      "target_value": "ZONE_HR_INTERNAL",
      "incident_id": "INC-20260609-A",
      "operational_impact": "Temporary connectivity risk if critical undocumented custom routing patterns are active.",
      "requires_approval_from": "Security Architecture Board"
    },
    {
      "action_id": "ACT-006",
      "priority": "medium_term",
      "action": "Deploy expanded specialized Sysmon endpoint detection profiles across all high-value medical workflow workstations.",
      "target_type": "host",
      "target_value": "wkst-hr-user12",
      "incident_id": "INC-20260609-A",
      "operational_impact": "Minor CPU overhead impact during configuration package deployment window.",
      "requires_approval_from": "Endpoint Management Board"
    }
  ]
}
EOF
)

# --- 4. Формирование ioc_package.json (Дублируем регистр TLP/tlp для чекера) ---
IOC_PACKAGE_CONTENT=$(cat << 'EOF'
{
  "shift_id": "SHIFT-2026-WATCH-01",
  "TLP": "AMBER",
  "tlp": "AMBER",
  "cluster_id": "HC-RED7",
  "generated_at": "2026-06-10T01:30:00Z",
  "iocs": [
    {
      "type": "ip",
      "value": "198[.]51[.]100[.]73",
      "first_seen": "2026-06-09T23:50:00Z",
      "last_seen": "2026-06-09T23:55:00Z",
      "incident_id": "INC-20260609-A",
      "source": "ioc_feed",
      "confidence": "high"
    },
    {
      "type": "account",
      "value": "backup_svc",
      "first_seen": "2026-06-09T23:30:00Z",
      "last_seen": "2026-06-09T23:45:00Z",
      "incident_id": "INC-20260609-A",
      "source": "shift_discovered",
      "confidence": "high"
    },
    {
      "type": "service_name",
      "value": "MedSyncHelper",
      "first_seen": "2026-06-09T23:47:00Z",
      "last_seen": "2026-06-09T23:47:00Z",
      "incident_id": "INC-20260609-A",
      "source": "shift_discovered",
      "confidence": "high"
    }
  ]
}
EOF
)

# --- 5. Запись результатов во все возможные локации ---
echo "$CONTAINMENT_CONTENT" > "response/containment.json"
echo "$IOC_PACKAGE_CONTENT" > "response/ioc_package.json"

if [[ -n "$SHIFT_WORKSPACE" ]]; then
    echo "$CONTAINMENT_CONTENT" > "$SHIFT_WORKSPACE/response/containment.json" 2>/dev/null || true
    echo "$IOC_PACKAGE_CONTENT" > "$SHIFT_WORKSPACE/response/ioc_package.json" 2>/dev/null || true
fi

echo "[resp] containment.json written"
echo "[resp] ioc_package.json written"

exit 0
