#!/usr/bin/env bash
# 4-forward_logs.sh

# Создаём/дописываем конфиг для пересылки логов
echo '*.* @127.0.0.1' >> /etc/rsyslog.d/50-default.conf

# Перезапускаем rsyslog, чтобы применить изменения
systemctl restart rsyslog

# Генерируем тестовое сообщение
logger "Test Log Forwarding"
