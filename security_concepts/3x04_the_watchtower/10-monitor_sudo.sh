#!/usr/bin/env bash
# 10-monitor_sudo.sh
# Простой мониторинг sudo-неудач в реальном времени

# Следим за /var/log/auth.log
tail -f /var/log/auth.log | while read line
do
    # Если в строке есть sudo + authentication failure
    echo "$line" | grep -q "sudo.*authentication failure"
    
    # Если grep нашёл совпадение
    if [ $? -eq 0 ]; then
        echo "ALERT: Sudo violation detected!"
    fi
done
