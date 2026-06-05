# Containment Execution Record: IR-2026-0420-01

## Execution Log Entries

### Step 1: Perimeter Firewall Egress Policy
* UTC: 2026-04-20T22:30:00Z
* actor: Network Security Team
* action: Deploy an explicit outbound firewall egress rule to block all traffic targeting the malicious endpoints and C2 domain infrastructure.
* expected outcome: Establish an immediate perimeter block on outbound traffic to malicious endpoints, cutting off the command channel.
* observed outcome: Firewall blocks deployed successfully. Outbound traffic attempts are systematically dropped.
* deviation notes: None.

### Step 2: Host Isolation Sequence for Affected Workstations
* UTC: 2026-04-20T22:45:00Z
* actor: Incident Response Engineer
* action: Execute the host isolation sequence rules on compromised endpoints WS-101, WS-104, WS-107, and WS-112 to prevent any internal lateral movement.
* expected outcome: Stop malware propagation and block internal script staging execution vectors.
* observed outcome: Host isolation profiles successfully loaded across WS-101, WS-104, WS-107, and WS-112. Systems isolated from local network access.
* deviation notes: None.

### Step 3: Hardening Access Boundaries on File Server
* UTC: 2026-04-20T23:00:00Z
* actor: Infrastructure Administrator
* action: Implement explicit network access control lists surrounding FILE-SVR-01 to isolate it from compromised zones.
* expected outcome: Restrict inbound connections to authorized medical subnets while excluding infected hosts from accessing the file share.
* observed outcome: Boundaries confirmed on FILE-SVR-01; clinical data reads remain functional for authorized zones.
* deviation notes: None.

### Step 4: Account Mitigation and Credential Revocation
* UTC: 2026-04-20T23:15:00Z
* actor: Active Directory Domain Administrator
* action: Initiate a comprehensive credential revocation process for every user and administrative account accessed during the 72-hour dwell period.
* expected outcome: Invalidate all compromised active Kerberos tickets, auth tokens, active sessions, and force an administrative password reset.
* observed outcome: Global credential revocation completed; password changes forced across all target accounts, wiping active sessions, tokens, and tickets.
* deviation notes: None.

### Step 5: Verification of Containment and Severed State
* UTC: 2026-04-20T23:30:00Z
* actor: Incident Response Analyst
* action: Analyze endpoint network sockets, netstat outputs, and perimeter firewall drop counters to verify the C2 beacon is severed.
* expected outcome: Hard proof and validation that every active malicious beacon connection is permanently disabled.
* observed outcome: Verified connection drop logs; all communication channels display a severed beacon status. No outbound egress detected.
* deviation notes: None.
