# Containment Execution Record: IR-2026-0420-01

## Execution Log Entries

### Step 1: Perimeter Firewall Egress Policy
* UTC: 2026-04-20T22:30:00Z
* actor: Network Security Team
* action: Deploy a hard drop outbound egress rule on the firewall for traffic mapping to the malicious Cobalt Strike C2 domain endpoints.
* expected outcome: Establish an immediate perimeter block on outbound traffic to malicious endpoints.
* observed outcome: Firewall blocks deployed successfully. Outbound traffic attempts are systematically blocked.
* deviation notes: None.

### Step 2: Isolation Sequence for Affected Workstations
* UTC: 2026-04-20T22:45:00Z
* actor: Incident Response Engineer
* action: Enforce host isolation sequences on compromised endpoints WS-101, WS-104, WS-107, and WS-112 to prevent any internal lateral movement.
* expected outcome: Stop malware propagation and block internal script staging execution vectors.
* observed outcome: Host isolation rules loaded across WS-101, WS-104, WS-107, and WS-112.
* deviation notes: None.

### Step 3: Hardening Access Boundaries on File Server
* UTC: 2026-04-20T23:00:00Z
* actor: Infrastructure Administrator
* action: Implement explicit network access control lists surrounding FILE-SVR-01 to isolate it from infected network segments.
* expected outcome: Restrict inbound connections to authorized medical subnets while excluding infected hosts from accessing the file share.
* observed outcome: Boundaries confirmed on FILE-SVR-01; clinical data reads remain functional.
* deviation notes: None.

### Step 4: Credential Revocation Operations
* UTC: 2026-04-20T23:15:00Z
* actor: Active Directory Domain Administrator
* action: Execute a full credential revocation sequence for compromised accounts active during the 72-hour dwell period.
* expected outcome: Invalidate all compromised active tickets, tokens, sessions, and force global password resets.
* observed outcome: Global credential revocation completed; password updates forced across all targets to invalidate hijacked tokens and sessions.
* deviation notes: None.

### Step 5: Verification of Containment and Severed State
* UTC: 2026-04-20T23:30:00Z
* actor: Incident Response Analyst
* action: Analyze endpoint network sockets and perimeter firewalls to gather conclusive proof that malicious channels are non-functional.
* expected outcome: Validation that every active malicious beacon connection is permanently disabled.
* observed outcome: Verified connection drop logs; all communication channels display a severed beacon status with non-functional sockets.
* deviation notes: None.
