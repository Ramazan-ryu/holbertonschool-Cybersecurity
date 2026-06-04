#!/usr/bin/env bash
# 3-setup_loghost.sh

# Сохраняем резервную копию
cp /etc/rsyslog.conf /etc/rsyslog.conf.bak

# Создаём новый конфиг с раскомментированными строками для UDP и TCP
grep -v '^#\$ModLoad imudp' /etc/rsyslog.conf > /tmp/rsyslog.tmp
grep -v '^#\$UDPServerRun 514' /tmp/rsyslog.tmp > /tmp/rsyslog.tmp2
grep -v '^#\$ModLoad imtcp' /tmp/rsyslog.tmp2 > /tmp/rsyslog.tmp3
grep -v '^#\$InputTCPServerRun 514' /tmp/rsyslog.tmp3 > /tmp/rsyslog.new

# Добавляем нужные строки (раскомментированные)
echo '$ModLoad imudp' >> /tmp/rsyslog.new
echo '$UDPServerRun 514' >> /tmp/rsyslog.new
echo '$ModLoad imtcp' >> /tmp/rsyslog.new
echo '$InputTCPServerRun 514' >> /tmp/rsyslog.new

# Перезаписываем основной конфиг
cat /tmp/rsyslog.new > /etc/rsyslog.conf

# Применяем изменения
systemctl restart rsyslog
