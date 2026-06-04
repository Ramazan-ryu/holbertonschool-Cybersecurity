#!/usr/bin/env bash
# 9-html_report.sh
# Генерация HTML отчёта по топ-атакующим IP

logfile="$1"
outfile="$2"

# Начало HTML
echo "<html>" > "$outfile"
echo "<head><title>Security Report</title></head>" >> "$outfile"
echo "<body>" >> "$outfile"
echo "<h1>Security Report</h1>" >> "$outfile"
echo "<table border=\"1\">" >> "$outfile"
echo "<tr><th>IP</th><th>Attempts</th></tr>" >> "$outfile"

# Получаем топ-5 атакующих IP и добавляем в таблицу
grep "Failed password" "$logfile" | cut -d' ' -f11 | sort | uniq -c | sort -nr | head -5 | while read count ip
do
    echo "<tr><td>$ip</td><td>$count</td></tr>" >> "$outfile"
done

# Конец HTML
echo "</table>" >> "$outfile"
echo "</body>" >> "$outfile"
echo "</html>" >> "$outfile"
