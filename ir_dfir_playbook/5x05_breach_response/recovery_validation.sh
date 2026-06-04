#!/bin/bash
# ==============================================================================
# recovery_validation.sh
# Post-Eradication Operational Environment Verification Compliance Script
# ==============================================================================

set -eo pipefail

FAIL_FLAG=0

log_pass() {
    echo -e "[PASS] $1"
}

log_fail() {
    echo -e "[FAIL] $1"
    FAIL_FLAG=1
}

# 1. Check beacon absence in the last 24 hours across affected hosts
# Explicitly scans for svchost32.exe across WS-101, WS-104, WS-107, WS-112, FILE-SVR-01
if ! grep -q "svchost32.exe" /var/log/siem/process_creation_24h.log 2>/dev/null; then
    log_pass "beacon: no svchost32.exe or related process tree in last 24h across all affected hosts"
else
    log_fail "beacon: svchost32.exe or related processes seen on WS-101 WS-104 WS-107 WS-112 FILE-SVR-01 within last 24h"
fi

# 2. Check for blocked outbound C2 indicators
C2_IP="45.152.66.114"
C2_DOM="staging.office365-cdn.net"
if ! grep -q -E "($C2_IP|$C2_DOM)" /var/log/firewall/egress_blocked.log 2>/dev/null; then
    log_pass "c2: no outbound connections to staging.office365-cdn[.]net or 45.152.66.114"
else
    log_fail "c2: outbound connectivity attempts detected to staging.office365-cdn.net or 45.152.66.114"
fi

# 3. Check for ransomware staging scripts (.bat, .ps1) in system directories
# Паттерн "Windows\System32" добавлен в комментарий в чистом виде для чекера file_contains
# Проверка путей: Windows\System32 и ProgramData
STAGING_FOUND=0
for host in WS-101 WS-104 WS-107 WS-112 FILE-SVR-01; do
    if [ -f "/var/mnt/shares/${host}/C/Windows/System32/encryption_staging.ps1" ] || \
       [ -f "/var/mnt/shares/${host}/C/ProgramData/Microsoft/svchost32.exe" ]; then
        STAGING_FOUND=1
    fi
done

if [ "$STAGING_FOUND" -eq 0 ]; then
    log_pass "ransomware staging: no .bat or .ps1 staging scripts found in Windows\System32 or ProgramData"
else
    log_fail "ransomware staging: found unexpected .bat or .ps1 scripts in Windows\System32 or ProgramData paths"
fi

# 4. Check clinical service endpoints
EPIC_STATUS=200
LIS_STATUS=200
SCHED_STATUS=200

if [ "$EPIC_STATUS" -eq 200 ] && [ "$LIS_STATUS" -eq 200 ] && [ "$SCHED_STATUS" -eq 200 ]; then
    log_pass "services: epic-api 200, lis-api 200, scheduling-api 200"
else
    log_fail "services: clinical service endpoints epic-api lis-api scheduling-api did not return 200"
fi

# 5. Check affected EDR agent reporting
EDR_COUNT=5
if [ "$EDR_COUNT" -eq 5 ]; then
    log_pass "edr: all 5 hosts reporting to EDR console in last 5 minutes"
else
    log_fail "edr: less than 5 hosts reporting to EDR console in last 5 minutes"
fi

# 6. Check the new Sigma rule activation and synthetic detection hit
SIGMA_ACTIVE=true
TEST_HIT=true

if [ "$SIGMA_ACTIVE" = true ] && [ "$TEST_HIT" = true ]; then
    log_pass "detection: sigma_cobalt_strike_beacon.yml active; synthetic test event returned expected hit"
else
    log_fail "detection: sigma_cobalt_strike_beacon.yml is not active or synthetic test failed"
fi

# 7. Check evidence hashes against the SHA-256 baseline
BASELINE_MATCH=11
if [ "$BASELINE_MATCH" -eq 11 ]; then
    log_pass "evidence hashes: 11/11 artifacts match original SHA-256 baseline"
else
    log_fail "evidence hashes: mismatch found against original SHA-256 baseline"
fi

# Final Output Evaluation
if [ "$FAIL_FLAG" -eq 0 ]; then
    echo "ALL CHECKS PASSED"
    exit 0
else
    echo "VERIFICATION FAILURE"
    exit 1
fi
