#!/usr/bin/env bash
# 7-json_template.sh

# Добавляем JSON шаблон в rsyslog.conf
echo 'template(name="json_fmt" type="string" string="{\"time\":\"%timestamp%\", \"host\":\"%hostname%\", \"msg\":\"%msg%\"}")' >> /etc/rsyslog.conf
