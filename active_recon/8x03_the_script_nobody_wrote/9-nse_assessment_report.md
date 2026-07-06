# NSE Assessment Report, Talvi Systems
For: Ridgeline engagement team

## 1. Executive summary
Our custom Nmap Scripting Engine (NSE) suite uncovered significant vulnerabilities within the Talvi estate that standard built-in Nmap scans entirely missed. By building bespoke tooling, we successfully mapped the management footprint, fingerprinted a proprietary service, confirmed an unauthenticated command interface, and audited valid credentials without causing account lockouts. This report hands over the tooling and findings to the next phase of the engagement.

## 2. The scripts
Each script in the bespoke suite is designed with specific Nmap rules and libraries to target the custom services.

* **1-modify_detect.nse**
  * **Rule:** `portrule` (using `shortport.http`).
  * **Library/Pattern:** Uses the `http` library to parse HTTP headers and bodies.
  * **Re-run:** `nmap -sT -Pn --script ./1-modify_detect.nse -p 8080 <target>`
* **2-svc_discovery.nse**
  * **Rule:** `portrule` (using `shortport.portnumber`).
  * **Library/Pattern:** Uses the `nmap` raw sockets API to extract the bespoke service banner.
  * **Re-run:** `nmap -sT -Pn --script ./2-svc_discovery.nse -p 9700 <target>`
* **3-talvi_version.nse**
  * **Rule:** `portrule` (using `shortport.portnumber`).
  * **Library/Pattern:** Uses `nmap` sockets to speak the custom protocol and `nmap.set_port_version` to update the Nmap version registry.
  * **Re-run:** `nmap -sT -Pn --script ./3-talvi_version.nse -p 9700 <target>`
* **4-talvi_vuln.nse**
  * **Rule:** `portrule` (using `shortport.portnumber`).
  * **Library/Pattern:** Uses the `vulns` library to structure the report and raw sockets for behavioral confirmation.
  * **Re-run:** `nmap -sT -Pn --script ./4-talvi_vuln.nse -p 9700 <target>`
* **5-vuln_state.nse**
  * **Rule:** `portrule` (using `shortport.portnumber`).
  * **Library/Pattern:** Uses `vulns` and `nmap` sockets with SSL to implement false-positive discipline via state management.
  * **Re-run:** `nmap -sT -Pn --script ./5-vuln_state.nse -p 8443 <target>`
* **6-brute_driver.nse**
  * **Rule:** `portrule` (using `shortport.portnumber`).
  * **Library/Pattern:** Implements the `brute` library Driver contract alongside `creds` and `unpwdb` to perform safe authentication loops.
  * **Re-run:** `nmap -sT -Pn --script ./6-brute_driver.nse --script-args unpwdb.users=wordlists/task6-users.txt,unpwdb.passwords=wordlists/task6-passwords.txt -p 9700 <target>`
* **7-brute_lockout.nse**
  * **Rule:** `portrule` (using `shortport.portnumber`).
  * **Library/Pattern:** Extends the `brute` Driver contract with internal attempt tracking and `stdnse.sleep` for throttling.
  * **Re-run:** `nmap -sT -Pn --script ./7-brute_lockout.nse --script-args unpwdb.users=wordlists/task7-users.txt,unpwdb.passwords=wordlists/task7-passwords.txt -p 9700 <target>`
* **8-consolidate.nse**
  * **Rule:** `postrule`.
  * **Library/Pattern:** Uses the `nmap.registry` pattern to aggregate and evaluate data left behind by prior scripts.
  * **Re-run:** `nmap -sT -Pn --script "./*.nse" --script-args unpwdb.users=wordlists/task7-users.txt,unpwdb.passwords=wordlists/task7-passwords.txt -p 9700 <target>`

## 3. Findings
* **Service Details:** Port 8080 hosts a Management Console web service with the specific build tag `TALVI-MGMT`.
* **Version Fingerprint:** The proprietary protocol on port 9700 was positively identified as `Talvi Management Service 2.1.7`.
* **Behaviorally Confirmed Vulnerability:** Port 9700 contains an unauthenticated command interface, verified by sending a privileged probe.
* **Credential-Audit Findings & Lockout Handling:** Auditing yielded valid credentials (`svc-monitor`, `backup-admin`). The Driver successfully handled lockout mechanisms by throttling at 5 attempts, preventing any account lockouts.
* **Consolidated Registry-Based Access Path:** By combining the version fingerprint, the confirmed vulnerability, and the valid credentials via the registry, we surfaced a single consolidated finding: a full management access path is exposed on port 9700.

## 4. Vulnerability states (VULN vs LIKELY_VULN)
We rigorously separate suspicion from proof to ensure the client focuses resources accurately.
* **LIKELY_VULN:** Assigned to the HTTPS Backport Gateway (port 8443). While the service's banner matched a published version vulnerability, our behavioral probe was negative. This strongly indicates the service was patched via a backport. We use LIKELY_VULN to communicate the version match honestly while clearing the backported service of a definitive accusation.
* **VULN:** Assigned strictly to the bespoke service (port 9700). We only assigned this state because a behavioral probe actively confirmed the flaw by triggering a privileged response.

## 5. Methodology and limitations
Our methodology strictly separated confirmation from exploitation. We confirmed the vulnerability's presence but deliberately left exploitation outside our scope; we did not claim the EXPLOIT state, nor did we attempt the execution of the confirmed flaw to extract data or pivot.

**Limitations:** We do not claim complete coverage of the estate. The custom scripts may still miss untested behaviors or additional protocol variants hidden within the line-oriented service. Our credential coverage is strictly limited to the provided wordlists, and dynamic changes in lockout uncertainty (e.g., if the client alters the threshold) could impact the brute scripts. Finally, our consolidated findings have strict registry dependencies; executing `8-consolidate.nse` in isolation without the prerequisite scripts will yield no results.
