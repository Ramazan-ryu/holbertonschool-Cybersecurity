#!/bin/bash

# File to store alerts
ALERT_LOG="/var/log/security_alerts.log"
mkdir -p $(dirname $ALERT_LOG)
touch $ALERT_LOG
chmod 600 $ALERT_LOG

# Threshold for failed SSH attempts
SSH_FAIL_THRESHOLD=5
SSH_AUTH_LOG="/var/log/auth.log"

echo "[+] Monitoring script started..."

while true; do
    # 1️⃣ Detect successful root login
    ROOT_LOGIN=$(grep "session opened for user root" $SSH_AUTH_LOG | tail -n1)
    if [ -n "$ROOT_LOGIN" ]; then
        echo "$(date) [ALERT] Root login detected: $ROOT_LOGIN" >> $ALERT_LOG
    fi

    # 2️⃣ Detect repeated SSH failures
    FAIL_COUNT=$(grep "Failed password" $SSH_AUTH_LOG | tail -n 20 | wc -l)
    if [ "$FAIL_COUNT" -ge "$SSH_FAIL_THRESHOLD" ]; then
        echo "$(date) [ALERT] SSH failed login attempts exceeded threshold ($FAIL_COUNT)" >> $ALERT_LOG
    fi

    # 3️⃣ Detect firewall changes (nftables)
    FW_CHECKSUM=$(nft list ruleset | md5sum)
    FW_PREV_FILE="/tmp/fw_checksum.txt"
    FW_PREV=$(cat $FW_PREV_FILE 2>/dev/null || echo "")
    if [ "$FW_CHECKSUM" != "$FW_PREV" ]; then
        echo "$(date) [ALERT] Firewall rules changed" >> $ALERT_LOG
        echo $FW_CHECKSUM > $FW_PREV_FILE
    fi

    # 4️⃣ Detect new user creation
    LAST_USER=$(tail -n1 /etc/passwd)
    USER_PREV=$(cat /tmp/last_user.txt 2>/dev/null || echo "")
    if [ "$LAST_USER" != "$USER_PREV" ]; then
        echo "$(date) [ALERT] New user created: $LAST_USER" >> $ALERT_LOG
        echo "$LAST_USER" > /tmp/last_user.txt
    fi

    # Sleep 30 seconds before next check
    sleep 30
done
