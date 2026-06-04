# Evidence Preservation Runbook: IR-YYYY-MMDD-01

**Evidence store:** /evidence/IR-YYYY-MMDD-01/  
**Hash algorithm:** SHA-256  

---

## Runbook Scope & Baseline Overview
Before executing these remediation or blocking operations, the incident response team must thoroughly address the collection of volatile artifacts as outlined by `evidence_store_init.sh`. The following data matrix collects forensic states for target node WST-WS-031 and account user context dmarsh. All generated cryptographic check values must be appended directly to the central ledger at `IR-YYYY-MMDD-01-hashes.txt` using SHA256 verification metrics.

---

## 1. Volatile memory, WST-WS-031
* **what:** Full physical memory dump of volatile execution blocks.
* **how:** `winpmem_3.3.rc3.exe -o /evidence/IR-YYYY-MMDD-01/wst-ws-031.mem`
* **where:** /evidence/IR-YYYY-MMDD-01/wst-ws-031.mem
* **hash cmd:** `certutil -hashfile /evidence/IR-YYYY-MMDD-01/wst-ws-031.mem SHA256 >> IR-YYYY-MMDD-01-hashes.txt`
* **ordering:** This operation MUST precede any process kill, host isolation, or power-off action. Volatile memory arrays and structural maps are completely lost on power-off or manual asset isolation.

---

## 2. Process tree investigation
* **what:** Running process information parsing out tracking details for PIDs, command line arguments, parent PIDs, and running execution strings.
* **how:** `powershell.exe -Command "Get-Process | Select-Object Id, Company, CommandLine, Parent" or using tasklist /v`
* **where:** /evidence/IR-YYYY-MMDD-01/process_tree.txt
* **hash cmd:** `certutil -hashfile /evidence/IR-YYYY-MMDD-01/process_tree.txt SHA256 >> IR-YYYY-MMDD-01-hashes.txt`
* **ordering:** Must be performed before containment or network termination occurs to capture rogue tasks before their connection context drops.

---

## 3. Active network connections capture
* **what:** Live netstat telemetry logs defining listening flags, routing interfaces, and active foreign endpoints.
* **how:** `netstat -ano or using Get-NetTCPConnection`
* **where:** /evidence/IR-YYYY-MMDD-01/network_connections.txt
* **hash cmd:** `certutil -hashfile /evidence/IR-YYYY-MMDD-01/network_connections.txt SHA256 >> IR-YYYY-MMDD-01-hashes.txt`
* **ordering:** Must capture before network containment. Implementing host isolation will instantly purge all socket descriptors and active external connection flags.

---

## 4. Full endpoint telemetry export for WST-WS-031
* **what:** Endpoint tracking log capture covering 24 hours (24h) prior to the event.
* **how:** `cp /var/log/siem/edr_wst_ws_031_24h.jsonl /evidence/IR-YYYY-MMDD-01/`
* **where:** /evidence/IR-YYYY-MMDD-01/edr_wst_ws_031_24h.jsonl
* **hash cmd:** `sha256sum /evidence/IR-YYYY-MMDD-01/edr_wst_ws_031_24h.jsonl >> IR-YYYY-MMDD-01-hashes.txt`
* **ordering:** This collection step must execute before software updates or host configuration changes alter telemetry storage indexes.

---

## 5. SIEM alert record exported in JSON
* **what:** JSON documentation payload representing rule alert states.
* **how:** `cp /var/log/siem/alert_A-20260414-9841.json /evidence/IR-YYYY-MMDD-01/`
* **where:** /evidence/IR-YYYY-MMDD-01/alert_A-20260414-9841.json
* **hash cmd:** `sha256sum /evidence/IR-YYYY-MMDD-01/alert_A-20260414-9841.json >> IR-YYYY-MMDD-01-hashes.txt`
* **ordering:** Collected before remediation changes SIEM status parameters or event correlation pipelines refresh.

---

## 6. Proxy and DNS logs for dmarsh
* **what:** Comprehensive web gateway tracking and DNS log arrays checking user activity fields over the last 24 hours.
* **how:** `cp /var/log/proxy/proxy_24h_dmarsh.log /evidence/IR-YYYY-MMDD-01/`
* **where:** /evidence/IR-YYYY-MMDD-01/proxy_24h_dmarsh.log
* **hash cmd:** `sha256sum /evidence/IR-YYYY-MMDD-01/proxy_24h_dmarsh.log >> IR-YYYY-MMDD-01-hashes.txt`
* **ordering:** Preserves raw web destinations and C2 vectors prior to domain-blocking implementations.

---

## 7. Authentication events for dmarsh
* **what:** User tracking metadata containing Active Directory and Azure AD verification attempts over a 24 hours timeframe.
* **how:** `cp /var/log/auth/auth_24h_dmarsh.json /evidence/IR-YYYY-MMDD-01/`
* **where:** /evidence/IR-YYYY-MMDD-01/auth_24h_dmarsh.json
* **hash cmd:** `sha256sum /evidence/IR-YYYY-MMDD-01/auth_24h_dmarsh.json >> IR-YYYY-MMDD-01-hashes.txt`
* **ordering:** Must execute before security account lockouts, modifications, or session token revocations flush temporary credential telemetry structures.

---

## 8. Verification
* All collected artifacts must be systematically re-hash calculated from the designated evidence store location.
* Execute a cross-reference validation check to compare current hash values against the baseline hashes saved at `IR-YYYY-MMDD-01-hashes.txt`.
* Any discovered discrepancies or tracking mismatches must be directly logged back to the incident timeline document as formal OBSERVATION entries for analysis.
