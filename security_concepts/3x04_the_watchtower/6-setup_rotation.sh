#!/usr/bin/env bash
# 6-setup_rotation.sh

# Создаём/перезаписываем конфиг для logrotate
echo "/var/log/secure_remote.log {" > /etc/logrotate.d/secure_remote
echo "    daily" >> /etc/logrotate.d/secure_remote
echo "    rotate 7" >> /etc/logrotate.d/secure_remote
echo "    compress" >> /etc/logrotate.d/secure_remote
echo "    missingok" >> /etc/logrotate.d/secure_remote
echo "    notifempty" >> /etc/logrotate.d/secure_remote
echo "}" >> /etc/logrotate.d/secure_remote
