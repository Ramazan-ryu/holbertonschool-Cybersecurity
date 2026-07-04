# 8x00 — The Cartographer's Patience

You run the scanning phase of an authorised penetration test against Berent
Industrial. You log in only to THIS workstation; you never log in to a target.

Authorised target subnet: 10.10.10.0/24  (and nothing else)

## How this lab runs (read this carefully)
`scanlab` is a controlled training runner. It parses your one-line scan command, applies it to the Berent backend model, and renders classical tool output. The intranet checker grades your submitted script. The real `nmap` binary is installed but is not replaced or intercepted.

Concretely:
  * Build each deliverable as a single-line script (first line exactly
    `#!/bin/bash`, one active command, `chmod +x`).
  * TEST it with the runner:        `scanlab ./1-discovery.sh`
  * Submit the script + the values you read from its output on the intranet.
  * `nmap`, `openssl`, `nc` are real and available for your own inspection and
    for ordinary TCP connect work; the packet-level techniques (ACK, FIN, UDP
    raw, fragmentation, decoy, idle, OS fingerprint, timing) are MODELED by the
    runner because this platform runs an ordinary unprivileged container.

## What you build
  1-discovery.sh   2-portstate.sh   3-firewall.sh   4-versions.sh
  5-banner.sh      6-timing.sh      7-evasion.sh    8-decoy.sh
  9-idlescan.sh    10-osdetect.sh   11-scan_report.md   README.md

Leave the tool's classical output as it is. Read each requested value from it.
Tasks 0 and 12-15 are completed on the intranet, not here.

## The Berent web application
A real corporate site is reachable in this lab at http://berent.lab:8080
(and from your host on :8080). It gives engagement context only — no answers.

## Tools available to you
nmap, openssl, nc (netcat), curl, jq, plus the `scanlab` runner. No sudo is
needed and no special capabilities are required.

## Discipline (Rules of Engagement)
Scan only 10.10.10.0/24. No exploitation, no DoS, no aggressive timing.
Patience finds more; discretion breaks less.
