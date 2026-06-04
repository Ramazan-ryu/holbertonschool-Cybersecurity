#!/usr/bin/env bash
# 5-isolate_auth.sh

# Создаём конфиг для изоляции authpriv логов
echo 'authpriv.*    /var/log/secure_remote.log' > /etc/rsyslog.d/60-auth.conf

# Перезапускаем rsyslog, чтобы применить изменения
systemctl restart rsyslog
