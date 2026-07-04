# Enumeration Report, Carmichael & West LLP
For: Ridgeline engagement team

## 1. Executive summary
Carmichael & West LLP's internal network suffers from systemic information leakage across multiple protocols, leading to a complete compromise of an IT administrative account. The firm's services willingly volunteer detailed domain architecture, internal network topologies, and cleartext credentials to anonymous or heavily restricted sessions, bypassing perimeter defenses.

## 2. Per-protocol findings (SMB, SNMP, LDAP)
* **SMB (files.carmichael.lab):** Allows null sessions to extract domain names (CARMICHAEL) and enumerate shares. Refuses anonymous user enumeration directly via `enumdomusers` but allows RID cycling via SID extraction. Exposes an anonymously readable `backups` share containing sensitive scripts. Contains a restricted `clientmatters` share. Password policy requires a minimum length of 8.
* **SNMP (monitor.carmichael.lab):** Answers to a weak, guessable community string (`private`). Leaks internal TCP listener states (exposing internal PostgreSQL on 5432) and full process execution parameters, including cleartext arguments.
* **LDAP (directory.carmichael.lab):** Allows anonymous binds to query the Root DSE (`DC=carmichael,DC=local`) and dump the complete directory tree. Reveals exactly 214 active user objects, internal group structures (`IT-Admins`), and insecure attribute usage (cleartext passwords stored in the `description` field).

## 3. Consolidated organizational picture
By aggregating the fragmented data across the three protocols, a distinct organizational risk profile emerges: `svc_backup` is an active member of the `IT-Admins` group and uses a single cleartext password (`W1nter2023!`). This credential is reused extensively across the infrastructure—it is hardcoded in scripts on the SMB `backups` share, executed as a command-line parameter visible via SNMP, and stored explicitly in the LDAP directory `description` field.

## 4. The enumeration chain
The critical path to authenticated access relied entirely on chaining unauthenticated data leaks:
1. Null session access to SMB exposed the `backups` share.
2. Reading the `backups` share revealed the SNMP community string (`private`).
3. Walking the SNMP tree with `private` revealed the service account name (`svc_backup`).
4. An anonymous LDAP dump of the `description` fields directly yielded the `svc_backup:W1nter2023!` credential.
5. Using the extracted `W1nter2023!` credential, authenticated access was established against SMB, unlocking the previously restricted `clientmatters` share with `READ` access.

## 5. Methodology
* `1-smb_null_session.sh`: Extracts the non-standard share and domain over a null session using `smbclient` and `rpcclient`.
* `2-snmp_ldap_unauth.sh`: Brute-forces the SNMP community using `onesixtyone` and extracts the LDAP base DN via anonymous `ldapsearch`.
* `3-smb_share_acl.sh`: Maps share permissions via null session using `smbmap` to find anonymously readable shares.
* `4-smb_rid_cycle.sh`: Bypasses `enumdomusers` restrictions by cycling RIDs with `rpcclient` to identify `svc_backup` and the domain password policy.
* `5-smb_share_loot.sh`: Downloads files from the `backups` share and greps for secrets (`SNMP_COMMUNITY="private"`).
* `6-snmp_mib_walk.sh`: Walks `hrSWRunParameters` using the `private` community to extract command-line arguments.
* `7-snmp_internal_ports.sh`: Queries the TCP MIBs to discover internally bound services (PostgreSQL/5432) hidden from external scans.
* `8-ldap_dump.sh`: Counts user objects and identifies the active privileged group (`IT-Admins`) by parsing `adminCount` and `userAccountControl`.
* `9-ldap_description_hunt.sh`: Scrapes the `description` attribute across all users to find the `svc_backup:W1nter2023!` cleartext credential.
* `10-correlate.py`: Programmatically deduplicates and correlates the protocol findings into a unified threat narrative.
* `11-auth_pivot.sh`: Applies the extracted credentials via `smbmap` to confirm `READ` access on the `clientmatters` share.

## 6. Limitations
The enumeration actively mapped shares (like `ADMIN$`, `C$`, `IPC$`) and directory objects (like Disabled admin accounts) but did not attempt to access or modify them. We listed the `clientmatters` share during the anonymous phase but did not verify its internal contents, only confirming `READ` access once authenticated. Furthermore, no attempts were made to access the internally identified PostgreSQL database, nor was the network swept for further targets outside the four in-scope hosts. This leaves the full depth of the `clientmatters` data and the backend database contents as unverified risks for the next phase.
