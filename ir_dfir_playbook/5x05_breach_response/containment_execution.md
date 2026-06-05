# Containment Execution Record: IR-2026-0420-01

## Execution Log Entries

### Step 1: Perimeter Firewall Egress Policy
* UTC: 2026-04-20T22:30:00Z
* actor: Network Security Team
* action: Deploy a firewall egress rule to drop traffic targeting the C2 domain, malicious endpoints, and domains.
* expected outcome: Establish an immediate perimeter block on outbound traffic to malicious endpoints.
* observed outcome: Firewall blocks deployed successfully. Outbound traffic attempts are systematically blocked.
* deviation notes: None.

### Step 2: Isolation Sequence for Workstations
* UTC: 2026-04-20T22:45:00Z
* actor: Incident Response Engineer
* action: Execute host isolation sequence and host isolation profiles to isolate compromised endpoints WS-101, WS-104, WS-107, and WS-112.
* expected outcome: Stop malware propagation and ensure host isolation from the local network.
* observed outcome: Confirmed host isolation sequence completed for WS-101, WS-104, WS-107, and WS-112.
* deviation notes: None.

### Step 3: Hardening Access Boundaries on File Server
* UTC: 2026-04-20T23:00:00Z
* actor: Infrastructure Administrator
* action: Implement explicit network access control lists surrounding FILE-SVR-01 to isolate it from malicious zones.
* expected outcome: Restrict inbound connections to protect FILE-SVR-01.
* observed outcome: Boundaries confirmed on FILE-SVR-01; clinical data reads remain functional.
* deviation notes: None.

### Step 4: Credential Revocation Operations
* UTC: 2026-04-20T23:15:00Z
* actor: Active Directory Domain Administrator
* action: Execute credential revocation sequence for all accounts accessed during the 72-hour dwell period.
* expected outcome: Perform credential revocation to invalidate compromised tokens, tickets, sessions, and require a new password.
* observed outcome: Global credential revocation completed; password changes forced, clearing all active tokens, tickets, and sessions during the 72-hour dwell window.
* deviation notes: None.

### Step 5: Verification of Containment and Severed State
* UTC: 2026-04-20T23:30:00Z
* actor: Incident Response Analyst
* action: Analyze network sockets to ensure the C2 beacon is permanently severed.
* expected outcome: Provide clear proof that the beacon is severed and connections are non-functional.
* observed outcome: Verified connection drop logs; all channels are non-functional, showing a blocked and dropped status. The malicious beacon is fully severed.
* deviation notes: None.
