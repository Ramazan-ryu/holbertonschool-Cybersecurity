# Containment Execution Record: IR-2026-0420-01

## Execution Log Entries

### Step 1: Perimeter Firewall Egress Policy
* UTC timestamp: 2026-04-20T22:30:00Z
* Actor: Network Security Team
* Action: Deploy a hard drop outbound egress rule on the perimeter firewall for traffic mapping to the malicious Cobalt Strike C2 domains and infrastructure.
* Expected outcome: Establish an immediate perimeter block on outbound traffic to malicious endpoints, cutting off the command channel.
* Observed outcome: Firewall blocks deployed successfully. Outbound traffic attempts are systematically dropped.
* Deviation notes: None.

### Step 2: Host Isolation Sequence for Affected Workstations
* UTC timestamp: 2026-04-20T22:45:00Z
* Actor: Incident Response Engineer
* Action: Enforce network host isolation profiles on compromised endpoints WS-101, WS-104, WS-107, and WS-112 to prevent any internal lateral movement.
* Expected outcome: Stop malware propagation and block internal script staging execution vectors.
* Observed outcome: Host isolation profiles successfully loaded across WS-101, WS-104, WS-107, and WS-112. Systems isolated from local network access.
* Deviation notes: None.

### Step 3: Hardening Access Boundaries on File Server
* UTC timestamp: 2026-04-20T23:00:00Z
* Actor: Infrastructure Administrator
* Action: Implement explicit network access control lists surrounding FILE-SVR-01 to isolate it from compromised zones.
* Expected outcome: Restrict inbound connections to authorized medical subnets while excluding infected hosts from accessing the file share.
* Observed outcome: Boundaries confirmed on FILE-SVR-01; clinical data reads remain functional for authorized zones.
* Deviation notes: None.

### Step 4: Credential Revocation Operations
* UTC timestamp: 2026-04-20T23:15:00Z
* Actor: Active Directory Domain Administrator
* Action: Execute a comprehensive credential revocation for accounts accessed during the 72-hour dwell period.
* Expected outcome: Invalidate all compromised active Kerberos tickets, OAuth tokens, and active administrative sessions to ensure the attacker cannot leverage stolen credentials.
* Observed outcome: Global credential revocation completed successfully; forced a global password reset across all target accounts.
* Deviation notes: None.

### Step 5: Verification of Containment and Severed State
* UTC timestamp: 2026-04-20T23:30:00Z
* Actor: Incident Response Analyst
* Action: Analyze endpoint network sockets, netstat outputs, and perimeter firewall drop counters to verify the C2 beacon is severed.
* Expected outcome: Hard proof and validation that every active malicious beacon connection is permanently disabled.
* Observed outcome: Verified connection drop logs; all communication channels display a severed beacon status. No outbound egress detected.
* Deviation notes: None.
