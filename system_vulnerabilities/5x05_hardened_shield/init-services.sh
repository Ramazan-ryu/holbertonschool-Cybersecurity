#!/bin/bash
# init-services.sh
# Start and verify required services: Apache2 and SSHD
# Idempotent and exits with proper exit codes

# Start Apache2
systemctl start apache2 2>/dev/null
systemctl enable apache2 2>/dev/null

# Start SSHD
systemctl start ssh 2>/dev/null
systemctl enable ssh 2>/dev/null

# Verify services are active
systemctl is-active --quiet apache2
APACHE_STATUS=$?

systemctl is-active --quiet ssh
SSH_STATUS=$?

# Simple health check: curl localhost for Apache
curl -sf http://localhost/ >/dev/null
HTTP_STATUS=$?

# Exit code logic: 0 if all services running and health check passes, else 1
exit $((APACHE_STATUS + SSH_STATUS + HTTP_STATUS > 0))
