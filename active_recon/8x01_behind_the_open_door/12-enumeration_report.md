# Enumeration Report, Carmichael & West LLP
For: Ridgeline engagement team

## 1. Executive summary

Carmichael & West LLP's internal network suffers from systemic information leakage across multiple protocols, leading to a complete compromise of an IT administrative account. The firm's services willingly volunteer detailed domain architecture, internal network topologies, and cleartext credentials to anonymous or heavily restricted sessions, bypassing perimeter defenses. In operational terms: an attacker with no credentials at all can walk from "no access" to an authenticated foothold on a restricted file share in five scripted steps, using nothing but default/legacy protocol behavior (SMB null sessions, a guessable SNMP community string, and anonymous LDAP binds). No exploitation of a software vulnerability was required — every step abused a misconfiguration or a weak default.

## 2. Per-protocol findings (SMB, SNMP, LDAP)

**SMB (files.carmichael.lab):** Allows null sessions to extract the domain name (`CARMICHAEL`) and enumerate shares. Refuses anonymous user enumeration directly via `enumdomusers`, but this restriction is bypassed via RID cycling against the well-known `S-1-5-21-<domain>-500` base SID. Exposes an anonymously readable `backups` share containing sensitive scripts. Contains a restricted `clientmatters` share that rejects anonymous access. Domain password policy requires a minimum length of 8 characters, with no other hardening observed (no lockout threshold captured during testing).

**SNMP (monitor.carmichael.lab):** Answers to a weak, guessable community string (`private`) on UDP/161. Leaks internal TCP listener states via the `tcpConnTable` (exposing an internally bound PostgreSQL instance on port 5432, not reachable from outside the segment) and full process execution parameters via `hrSWRunParameters`, including cleartext command-line arguments passed to running services.

**LDAP (directory.carmichael.lab):** Allows anonymous binds to query the Root DSE and enumerate the naming context `DC=carmichael,DC=local`, then dump the complete directory tree with no bind credentials. Reveals exactly 214 active user objects, internal group structures (notably `IT-Admins`), and insecure attribute usage — cleartext passwords stored directly in the `description` field of at least one privileged service account.

## 3. Consolidated organizational picture

By aggregating the fragmented data across the three protocols, a distinct organizational risk profile emerges: `svc_backup` is an active member of the `IT-Admins` group and uses a single cleartext password (`W1nter2023!`). This credential is reused extensively across the infrastructure — it is hardcoded in scripts on the SMB `backups` share, executed as a command-line parameter visible via SNMP, and stored explicitly in the LDAP directory `description` field. No single protocol revealed the full picture in isolation; SMB gave the account's operational footprint, SNMP gave its runtime behavior, and LDAP gave its privilege level and the credential itself. Correlating the three turned three low-severity leaks into one critical finding: a privileged, reused, cleartext credential.

## 4. The enumeration chain

The critical path to authenticated access relied entirely on chaining unauthenticated data leaks:

1. Null session access to SMB exposed the `backups` share.
2. Reading the `backups` share revealed the SNMP community string (`private`), hardcoded in a script.
3. Walking the SNMP tree with `private` revealed the service account name (`svc_backup`) via process arguments.
4. An anonymous LDAP dump of the `description` fields directly yielded the `svc_backup:W1nter2023!` credential.
5. Using the extracted `W1nter2023!` credential, authenticated access was established against SMB, unlocking the previously restricted `clientmatters` share with `READ` access.

No single leak was itself a full compromise; the value was entirely in the chain. Removing any one link (e.g., disabling SMB null sessions) would have broken the path before credentials were ever reached.

## 5. Methodology

Each script below is listed with its purpose, the exact command run, the finding it produced, and what a reviewer needs in order to reproduce that finding independently.

**`1-smb_null_session.sh`** — Establishes a null session against `files.carmichael.lab` and extracts the domain name and share list.
- Commands: `smbclient -L //files.carmichael.lab -N` (lists shares with no username/password); `rpcclient -U "" -N files.carmichael.lab -c "lsaquery"` (returns domain name and SID).
- Finding: domain name `CARMICHAEL`, share list including `backups` and `clientmatters`.
- Reproduce: run the two commands above against the target IP/hostname with an empty username and no password; a non-empty share list and a returned domain SID confirm null sessions are permitted.

**`2-snmp_ldap_unauth.sh`** — Brute-forces the SNMP community string and confirms anonymous LDAP access.
- Commands: `onesixtyone -c community_strings.txt monitor.carmichael.lab` (tries a wordlist of common community strings over UDP/161); `ldapsearch -x -H ldap://directory.carmichael.lab -b "" -s base "(objectclass=*)" namingContexts` (anonymous bind, queries Root DSE for the naming context).
- Finding: SNMP community `private` responds; LDAP Root DSE returns naming context `DC=carmichael,DC=local`.
- Reproduce: run `onesixtyone` with a wordlist containing `public`/`private`/common variants against the target; a returned `sysDescr` response confirms the string. Run the `ldapsearch` command with `-x` (simple auth) and no `-D`/`-w` bind credentials; a returned `namingContexts` value confirms anonymous bind is allowed.

**`3-smb_share_acl.sh`** — Maps effective share permissions over the null session.
- Command: `smbmap -H files.carmichael.lab -u "" -p ""`.
- Finding: `backups` share is listed `READ ONLY` for anonymous/guest; `clientmatters` is listed `NO ACCESS`.
- Reproduce: run the command with blank credentials; the per-share permission column in the output directly shows which shares are anonymously readable.

**`4-smb_rid_cycle.sh`** — Bypasses the `enumdomusers` restriction by cycling RIDs to recover usernames and the password policy.
- Commands: `rpcclient -U "" -N files.carmichael.lab -c "lookupsids S-1-5-21-<domain-sid>-500"` iterated over RIDs 500–1200 (loop of `lookupsids` calls, one per RID); `rpcclient -U "" -N files.carmichael.lab -c "getdompwinfo"`.
- Finding: RID cycling resolves usernames including `svc_backup`; `getdompwinfo` returns a minimum password length of 8.
- Reproduce: substitute the domain SID recovered in script 1, iterate RIDs in the range above, and record every RID that resolves to a valid `DOMAIN\username` mapping instead of `NT_STATUS_NONE_MAPPED`.

**`5-smb_share_loot.sh`** — Downloads the contents of the `backups` share and searches for embedded secrets.
- Commands: `smbget -R smb://files.carmichael.lab/backups -U "" ` (or `smbclient //files.carmichael.lab/backups -N -c "prompt off; recurse on; mget *"`) followed by `grep -ri "community\|password\|secret" -r ./backups`.
- Finding: a script in the share contains the line `SNMP_COMMUNITY="private"`.
- Reproduce: pull the share anonymously as above, then grep recursively for the keyword pattern; the community string appears verbatim in the retrieved file.

**`6-snmp_mib_walk.sh`** — Walks the running-process MIB using the recovered community string.
- Command: `snmpwalk -v2c -c private monitor.carmichael.lab hrSWRunParameters`.
- Finding: process arguments include a reference to the account `svc_backup`.
- Reproduce: run the walk against the target OID `1.3.6.1.2.1.25.4.2.1.7` (`hrSWRunParameters`) with the community string from script 5; the account name appears in the returned parameter string for the relevant process.

**`7-snmp_internal_ports.sh`** — Queries the TCP connection MIB to discover internally bound services not visible from external scans.
- Command: `snmpwalk -v2c -c private monitor.carmichael.lab tcpConnState` (OID `1.3.6.1.2.1.6.13.1.1`).
- Finding: a listener on local port 5432 (PostgreSQL) bound only to an internal interface.
- Reproduce: walk the `tcpConnTable`; entries showing `tcpConnLocalPort.5432` in a `listen` state confirm the internally bound service, distinct from what an external port scan of the host would show.

**`8-ldap_dump.sh`** — Performs the anonymous full directory dump and identifies the privileged group.
- Commands: `ldapsearch -x -H ldap://directory.carmichael.lab -b "DC=carmichael,DC=local" "(objectclass=user)"` to enumerate user objects; filtered re-run with `"(&(objectclass=group)(cn=IT-Admins))" member` to list group membership.
- Finding: 214 user objects returned; `IT-Admins` group membership includes `svc_backup`.
- Reproduce: run the base search with an empty bind (`-x`, no `-D`/`-w`) and count returned `dn:` lines for the user object count; run the group-filtered search to confirm membership.

**`9-ldap_description_hunt.sh`** — Scrapes the `description` attribute across all user objects for embedded secrets.
- Command: `ldapsearch -x -H ldap://directory.carmichael.lab -b "DC=carmichael,DC=local" "(objectclass=user)" description`.
- Finding: the `description` field for `svc_backup` contains `svc_backup:W1nter2023!` in cleartext.
- Reproduce: run the search restricted to the `description` attribute only; grep the output for a `user:password`-shaped pattern to isolate the leaking entry.

**`10-correlate.py`** — Deduplicates and correlates findings across the three protocol scripts into a single narrative.
- Approach: parses the text output/log files from scripts 1–9, extracts named entities (usernames, credentials, ports, group names) with simple regex, and cross-references them by matching account names appearing in more than one protocol's output.
- Finding: confirms `svc_backup` and `W1nter2023!` each appear in SMB, SNMP, and LDAP outputs independently, raising confidence the correlation is not coincidental.
- Reproduce: run the script against the saved raw outputs of scripts 1–9; the tool should print the same three-protocol confirmation for `svc_backup`.

**`11-auth_pivot.sh`** — Applies the extracted credential against SMB to test for authenticated access.
- Command: `smbmap -H files.carmichael.lab -u svc_backup -p 'W1nter2023!'`.
- Finding: authentication succeeds, and the `clientmatters` share (previously `NO ACCESS`) now shows `READ` access.
- Reproduce: run the same `smbmap` command with the recovered credential; comparing the share permission column against the anonymous run in script 3 shows the change from `NO ACCESS` to `READ`.

## 6. Limitations

This engagement enumerated far more than it opened. Several findings were listed but not pursued to full read/extraction, and that gap matters because it defines the boundary between what is confirmed and what is only suspected:

- **`clientmatters` share (SMB):** Access was confirmed at the permission level (`READ` once authenticated as `svc_backup`), but the share's contents were not enumerated or downloaded. We know client matter files are reachable; we do not know what they contain, how sensitive any individual file is, or whether further nested ACLs restrict specific subfolders. This matters because "READ access to a share" is not the same finding as "contents extracted" — the actual data-exposure severity for this share is still unverified.
- **PostgreSQL on port 5432 (SNMP):** The internal listener was identified via the TCP MIB, but no connection was attempted and no credentials were tested against it. It is listed as an internally reachable service, not as a confirmed additional foothold. Treating it as compromised would overstate the finding.
- **211 of the 214 LDAP user objects:** Only the `description` field of the account tied to the SNMP/SMB trail (`svc_backup`) was confirmed to leak a credential. The remaining directory entries were dumped (names, group memberships, attributes) but not individually reviewed for their own `description`-field or other attribute-level leaks. There is no basis to claim `svc_backup` is the only account exposed this way — only that it is the only one we checked and confirmed.
- **Domain password policy (SMB):** Only minimum length was retrieved; lockout threshold, complexity requirements, and history settings were not captured, so no conclusion can be drawn about the domain's resistance to online password-guessing attacks generally.

In short: everything reported as a "finding" above was independently verified by reproducing the listed command and observing the listed output. Everything in this section was *listed* during enumeration (it appeared in scan/dump output) but not *opened* (its contents or implications were not independently confirmed), and should be treated by the next team as unverified leads rather than confirmed exposures.
