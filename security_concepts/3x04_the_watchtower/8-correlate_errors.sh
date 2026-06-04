#!/usr/bin/env bash
# 8-correlate_errors.sh

# Берём все 4xx ошибки из лога
grep ' 4' "$1" > /tmp/errors.log

# Берём IP адреса
cut -d' ' -f1 /tmp/errors.log > /tmp/errors_ip.log

# Считаем количество ошибок на каждый IP
sort /tmp/errors_ip.log | uniq -c > /tmp/errors_count.log

# Выводим только те IP, у которых больше 5 ошибок
grep -E '^[[:space:]]*[6-9]|^[[:space:]]*[1-9][0-9]+' /tmp/errors_count.log
