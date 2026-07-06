# NSE Assessment Report, Talvi Systems
For: Ridgeline engagement team

## 1. Executive summary
Our custom Nmap Scripting Engine (NSE) suite uncovered significant vulnerabilities within the Talvi estate that standard built-in Nmap scans entirely missed. The built-in libraries failed to interact with the custom, line-oriented protocol on port 9700. By building bespoke tooling, we successfully mapped the management footprint, fingerprinted a proprietary service, confirmed an unauthenticated command interface, and audited valid credentials without causing account lockouts. This report hands over the tooling and findings to the next phase of the engagement.

## 2. The scripts
The bespoke suite uses standard Nmap libraries (`shortport`, `http`, `nmap` sockets, `vulns`, `brute`, `creds`) and passes data through `nmap.registry`.
* **1-modify_detect.nse**: Modifies standard HTTP behavior to parse HTTP headers/body for the Talvi build tag. (`nmap -sT -Pn --script ./1-modify_detect.nse -p 8080 <target>`)
* **2-svc_discovery.nse**: Uses raw sockets to connect to port 9700 and extract the bespoke service banner. (`nmap -sT -Pn --script ./2-svc_discovery.nse -p 9700 <target>`)
* **3-talvi_version.nse**: Speaks the custom protocol to request the version and hardmatches the Nmap port state to `talvi-mgmt`. (`nmap -sT -Pn --script ./3-talvi_version.nse -p 9700 <target>`)
* **4-talvi_vuln.nse**: Uses the `vulns` library to send an `ADMIN` command, confirming an unauthenticated command interface via behavior. (`nmap -sT -Pn --script ./4-talvi_vuln.nse -p 9700 <target>`)
* **5-vuln_state.nse**: Demonstrates false-positive discipline on port 8443 by clearing a backported HTTPS service when behavioral probes fail. (`nmap -sT -Pn --script ./5-vuln_state.nse -p 8443 <target>`)
* **6-brute_driver.nse / 7-brute_lockout.nse**: Implements the `brute` Driver contract to audit credentials against the bespoke service, successfully throttling at 5 attempts to avoid lockout. (`nmap -sT -Pn --script ./7-brute_lockout.nse -p 9700 <target>`)
* **8-consolidate.nse**: A `postrule` script that reviews `nmap.registry` to combine the version, vulnerability, and valid account into a single high-impact finding. (`nmap -sT -Pn --script "./*.nse" -p 9700 <target>`)

## 3. Findings
* **Port 8080 (Management Console)**: Web service detected with build tag (TALVI-MGMT).
* **Port 8443 (Backport Gateway)**: Appears vulnerable based on version, but cleared by behavioral testing (patched via backport).
* **Port 9700 (Bespoke Management)**: Identified as Talvi Management Service v2.1.7. Contains a confirmed unauthenticated command interface. Auditing yielded valid credentials (`svc-monitor`, `backup-admin`). The consolidated result proves a full management access path.

## 4. Vulnerability states (VULN vs LIKELY_VULN)
Maintaining an honest state is critical. Clients spend resources investigating the word VULNERABLE.
* **LIKELY_VULN**: Assigned to the HTTPS gateway (port 8443). The service's version matched a published advisory, but it lacked the vulnerable behavior. This indicates suspicion without proof, effectively clearing patched/backported services from definitive accusation.
* **VULN**: Assigned strictly when a behavioral probe confirmed the flaw (port 9700). We triggered the privileged response using the `ADMIN` command. This proves presence definitively.

## 5. Methodology and limitations
We applied active reconnaissance using Nmap sockets and NSE libraries, confirming presence without exploitation. The `EXPLOIT` state was intentionally omitted to adhere strictly to the Rules of Engagement. Credential auditing was dynamically throttled to respect the environment's integrity and avoid locking out the client's accounts.
**Limitations**: We confirmed the presence of the unauthenticated interface but did not weaponize it to extract underlying data or pivot. Further undocumented commands in the bespoke protocol may still be hidden, requiring deeper manual interaction during the next phase.
