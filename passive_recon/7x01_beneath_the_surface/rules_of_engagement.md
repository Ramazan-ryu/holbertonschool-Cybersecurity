# Rules of Engagement — Vanguard × Astralis

These rules are contractual. Encode them inside your scripts.

## Authorised

- Active reconnaissance against `astralis-cloud.example` and the infrastructure
  it resolves to.
- DNS queries (any record type), moderate-rate DNS brute force.
- Service/version fingerprinting over HTTP(S) and TLS.
- Port scanning at **moderate intensity** (e.g. `nmap -T2`, capped probe rate).
- Querying attribution / vulnerability APIs at a respectful rate.

## Prohibited

- SYN floods or any high-rate / service-disrupting scan (`-T5`, unbounded rate).
- Exploitation of any discovered vulnerability.
- Authentication attempts / credential brute force.
- Listing or exfiltrating object-storage contents (identification only).
- Any action against hosts outside the Astralis scope.

## Discipline

- Bound every script with a timeout (e.g. `curl --max-time`, `timeout`).
- Throttle brute force (`gobuster` thread/timeout caps).
- Calibrate `nmap` timing/rate to the moderate window, in the script itself.
- One script = one objective = one printed value.
