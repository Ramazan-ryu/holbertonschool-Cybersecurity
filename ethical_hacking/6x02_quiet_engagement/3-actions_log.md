# Action Log, Lumen Engagement

| Timestamp (UTC) | Phase | Action | Target | Result |
| --- | --- | --- | --- | --- |
| 2026-06-28T12:47:10Z | 4 | nmap -sV -p 80,443 | portal.lumen-industrial.com | Open ports: 80, 443. Server: Apache/2.4.41. Discovered customer login form. |
| 2026-06-28T12:52:30Z | 4 | Burp Suite spider & passive scan | portal.lumen-industrial.com | Identified missing HttpOnly flags on session cookies; potential reflected XSS identified on /search?q= parameter. |
| 2026-06-28T13:05:15Z | 4 | nmap -sV -p- | admin.lumen-industrial.com | Open ports: 80, 443. HTTP server: nginx/1.24.0. Admin login interface exposed at /login. |
| 2026-06-28T13:12:44Z | 4 | ffuf -w common.txt -u https://admin.lumen-industrial.com/FUZZ | admin.lumen-industrial.com | Discovered /admin/dashboard (401), /admin/docs (200), and /admin/.env (403). |
| 2026-06-28T13:25:02Z | 4 | curl -i -s -X OPTIONS | api.lumen-industrial.com | Allowed methods: GET, POST, PUT, DELETE, OPTIONS. No standard rate-limiting headers (X-RateLimit) observed on response. |
| 2026-06-28T13:40:19Z | 4 | curl -i https://api.lumen-industrial.com/v1/sensors/101 | api.lumen-industrial.com | Returned HTTP 200 with mock sensor telemetry. Sequential ID indicates potential BOLA/IDOR vulnerability for unauthenticated access. |
| 2026-06-28T13:55:08Z | 4 | nmap -sV -p 22,80 | gateway.demo.lumen-industrial.com | Open ports: 22 (OpenSSH 8.2p1), 80 (lighttpd/1.4.55). Edge gateway web diagnostic interface identified on port 80. |
| 2026-06-28T14:10:33Z | 4 | ssh -v -o PreferredAuthentications=none root@gateway.demo... | gateway.demo.lumen-industrial.com | Server accepts publickey, password. Banner confirms dropbear SSH. Identification only; no brute force attempted. |
| 2026-06-28T14:22:15Z | 4 | nmap -sV -p 1883,8883 | mqtt.lumen-industrial.com | Open port: 1883 (mosquitto version 2.0.11). Port 8883 closed/filtered. Indicates unencrypted MQTT protocol support. |
| 2026-06-28T14:30:50Z | 4 | mosquitto_sub -h mqtt.lumen-industrial.com -t "#" | mqtt.lumen-industrial.com | Connection accepted. Successfully subscribed without authentication. Identified topics: /lumen/qa/sensors/temp, /lumen/qa/telemetry. |
| 2026-06-28T14:35:22Z | 4 | Passive inspection of active MQTT telemetry broadcast stream | mqtt.lumen-industrial.com | Discovered routed IP links and topics for production customer-deployed edge warehouses (`/lumen/prod/customer-edge/`). |
| 2026-06-28T14:36:00Z | 4 | Scope discipline enforcement: halted all traffic to discovered endpoints | Third-party customer infrastructure | **STOPPED PROBING.** Identified customer-premises assets are outside Lumen's ownership authority. Documented hosts to escalate as an out-of-scope architectural finding in the final report without touching the devices. |
