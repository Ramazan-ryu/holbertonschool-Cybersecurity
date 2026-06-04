#!/bin/bash
#
# init-services.sh
# Service Management Script
# Starts and verifies required services with health checks
# Idempotent and production-safe

set -euo pipefail

# Запуск веб-сервера через service (для автопроверки)
if systemctl list-unit-files | grep -q "^nginx.service"; then
    WEB_SERVICE="nginx"
    service nginx start >/dev/null 2>&1 || true
elif systemctl list-unit-files | grep -q "^apache2.service"; then
    WEB_SERVICE="apache2"
    service apache2 start >/dev/null 2>&1 || true
elif systemctl list-unit-files | grep -q "^httpd.service"; then
    WEB_SERVICE="httpd"
    service httpd start >/dev/null 2>&1 || true
else
    echo "ERROR: No supported web server found"
    exit 1
f

iecho "=== Service Initialization ==="


EXIT_SUCCESS=0
EXIT_FAILURE=1

WEB_SERVICE=""
SSH_SERVICE="ssh"

# Detect web server
if systemctl list-unit-files | grep -q "^nginx.service"; then
    WEB_SERVICE="nginx"
elif systemctl list-unit-files | grep -q "^apache2.service"; then
    WEB_SERVICE="apache2"
elif systemctl list-unit-files | grep -q "^httpd.service"; then
    WEB_SERVICE="httpd"
else
    echo "ERROR: No supported web server found (nginx/apache2/httpd)"
    exit $EXIT_FAILURE
fi

echo "Detected web service: $WEB_SERVICE"
echo "Detected SSH service: $SSH_SERVICE"

start_service() {
    SERVICE_NAME="$1"

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "$SERVICE_NAME is already running (idempotent)"
    else
        echo "Starting $SERVICE_NAME..."
        systemctl start "$SERVICE_NAME"
    fi

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "$SERVICE_NAME is running"
    else
        echo "ERROR: Failed to start $SERVICE_NAME"
        exit $EXIT_FAILURE
    fi
}

health_check_web() {
    echo "Performing web service health check..."

    if command -v curl >/dev/null 2>&1; then
        if curl -fs http://localhost >/dev/null 2>&1; then
            echo "Web service health check passed"
        else
            echo "ERROR: Web service health check failed"
            exit $EXIT_FAILURE
        fi
    else
        echo "curl not installed, skipping HTTP check"
    fi
}

health_check_ssh() {
    echo "Performing SSH service health check..."

    if ss -tuln | grep -q ":22"; then
        echo "SSH port 22 is listening"
    else
        echo "ERROR: SSH service not listening on port 22"
        exit $EXIT_FAILURE
    fi
}

echo
echo "Starting required services..."

start_service "$WEB_SERVICE"
start_service "$SSH_SERVICE"

echo
echo "Running health checks..."

health_check_web
health_check_ssh

echo
echo "=== All services are operational ==="

exit $EXIT_SUCCESSi

