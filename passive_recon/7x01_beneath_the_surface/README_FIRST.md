# 7x01 — Beneath the Surface

Welcome to the Astralis Cloud Services active-reconnaissance lab. You are a
junior reconnaissance specialist at **Vanguard Security**. Across twelve focused
tasks you will write twelve one-line `Bash` scripts, one per reconnaissance
domain. Each script prints **exactly one value** to stdout — the flag you submit
on the intranet for that task.

## Target

```
Primary domain : astralis-cloud.example
```

All Astralis names resolve to lab infrastructure running **inside this single
container**. There is no separate machine to log in to and no target
credentials: you interrogate services over the network with standard tools.

## Ground rules (see rules_of_engagement.md)

- Moderate scan intensity only. No SYN flood, no service-disrupting probes.
- No exploitation. Identification and fingerprinting only.
- Encode the Rules of Engagement *inside* your scripts (timing flags, rate
  limits, bounded timeouts) — not in your head at runtime.

## Script requirements

- First line exactly `#!/bin/bash`.
- One logical line of script logic (you may chain with `;`, `&&`, `||`, pipes).
- Print exactly one value, no prefix, no decoration, ending in a newline.
- `chmod +x` every script.

## Tooling available

`dig` · `host` · `nslookup` · `nmap` · `curl` · `wget` · `openssl` · `jq` ·
`gobuster` · `wafw00f` · `xmlstarlet` · `awk` · `sed` · `grep` · `cut` ·
`netcat`. A DNS brute-force wordlist is at
`/usr/share/wordlists/astralis-subdomains.txt` (also mirrored under the standard
SecLists DNS path).

## Lab tool notes

- `gobuster` here is **v2.0.1**: DNS mode is `gobuster -m dns -u <domain> -w
  <wordlist>` (not the newer `gobuster dns -d …`).
- The target hosts are on the loopback range. For the admin port scan, a **TCP
  connect scan** (`nmap -sT`) is reliable; a raw SYN scan against loopback may
  not return results. Keep the scan at **moderate intensity** per the RoE.

## Self-check (shape only — not an answer oracle)

```bash
sudo /usr/local/bin/check.sh ./scripts/1-nameserver.sh
```

This checks the *shape* of your script (shebang, executable bit, single line,
bounded runtime, exactly one stdout line). It never tells you the right value.

## Workflow

1. Read `engagement_brief.md` and `rules_of_engagement.md`.
2. Write each one-liner under `scripts/` (`1-nameserver.sh` … `12-cve.sh`).
3. Run it, copy the printed value, submit it on the intranet.
4. Synthesize your findings into the reconnaissance report (Task 13).
