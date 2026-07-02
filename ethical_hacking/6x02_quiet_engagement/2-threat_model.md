# Action Log, Lumen Engagement

| Timestamp (UTC) | Phase | Action | Target | Result |
| --- | --- | --- | --- | --- |
| 2026-07-03T09:14:02Z | 4 | `nmap -sV -p- admin.lumen.example` | admin.lumen.example | Open ports: 22, 80, 443. HTTP server: nginx 1.24. Login form at `/login`. |
| 2026-07-03T09:31:18Z | 4 | `gobuster dir -u https://admin.lumen.example -w common.txt` | admin.lumen.example | Discovered `/admin/upload`, `/admin/api`, `/admin/.git/config`. |
| 2026-07-03T09:35:45Z | 4 | `curl -I https://admin.lumen.example/admin/.git/config` | admin.lumen.example | HTTP 200 OK. Identified exposed Git repository configuration file. No source code downloaded. |
| 2026-07-03T10:05:10Z | 4 | `nmap -sV -p- portal.lumen.example` | portal.lumen.example | Open ports: 80, 443. Web server: Apache 2.4.41 (Ubuntu). |
| 2026-07-03T10:18:22Z | 4 | `nuclei -u https://portal.lumen.example -t misconfiguration/` | portal.lumen.example | Identified exposed `/server-status` endpoint. Disclosed internal paths and active client requests. |
| 2026-07-03T10:45:00Z | 4 | `nmap -sV -p- api.lumen.example` | api.lumen.example | Open ports: 443. Service: Node.js Express framework. |
| 2026-07-03T10:55:30Z | 4 | `ffuf -w api-endpoints.txt -u https://api.lumen.example/FUZZ` | api.lumen.example | Discovered `/v1/docs` (Swagger UI), `/v1/health`, and `/v1/firmware`. |
| 2026-07-03T11:10:15Z | 4 | `curl -s https://api.lumen.example/v1/docs` | api.lumen.example | Accessed Swagger documentation. Endpoint definitions suggest `/v1/firmware/download` may lack authentication requirements. |
| 2026-07-03T11:30:05Z | 4 | `nmap -sV -p 22 gateway.lumen.example` | gateway.lumen.example | Port 22 open. Banner: OpenSSH 7.2p2 Ubuntu. Version is associated with legacy user enumeration CVEs. |
| 2026-07-03T11:38:50Z | 4 | `ssh-audit gateway.lumen.example` | gateway.lumen.example | Identified weak Key Exchange (KEX) algorithms and deprecated MAC algorithms (e.g., `hmac-sha1`). |
| 2026-07-03T12:05:00Z | 4 | `nmap -sV -p 1883,8883 mqtt.lumen.example` | mqtt.lumen.example | Port 1883 (MQTT) open. Service: Eclipse Mosquitto 1.6.9. Port 8883 (MQTT over TLS) is closed/filtered. |
| 2026-07-03T12:15:22Z | 4 | `mosquitto_sub -h mqtt.lumen.example -t "#" -d --retained-only` | mqtt.lumen.example | Connection Accepted (CONNACK). Broker is configured to allow anonymous binds. Disconnected immediately after confirming access; no payload parsing performed. |
