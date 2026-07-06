# 8x03 — The Script Nobody Wrote

You write genuine Nmap Scripting Engine (NSE) scripts in Lua against Talvi
Systems. You log in only to THIS workstation. You confirm presence; you never
exploit.

## Target
  talvi.example     web console  http://talvi.example:8080
                    HTTPS gateway https://talvi.example:8443
                    bespoke mgmt  talvi.example:9700  (custom line protocol)

Run your scripts with the real engine, e.g.:
  nmap -sT -Pn --script ./1-modify_detect.nse -p 8080 talvi.example

## What you build (genuine .nse scripts you author yourself)
  1-modify_detect.nse  2-svc_discovery.nse  3-talvi_version.nse
  4-talvi_vuln.nse     5-vuln_state.nse     6-brute_driver.nse
  7-brute_lockout.nse  8-consolidate.nse    9-nse_assessment_report.md
  README.md

Every deliverable is a real NSE script: head fields (description/author/license/
categories), a correct rule (portrule/postrule, shortport where it fits), an
action, and structured output via stdnse/vulns — never a raw print(). Vuln
scripts use the `vulns` library and HONEST states (LIKELY_VULN for version-only,
VULN only on behavioural confirmation, EXPLOIT never). Credential scripts
implement the `brute` Driver contract and respect account lockout. Inter-script
data passes through the Nmap registry. Tasks 0 and 10-13 are intranet-only.

## Resources in this workspace
  reference/  NSE_README.md  BUILTIN_EXAMPLES.md  TALVI_PROTOCOL_NOTES.md
  wordlists/  task6-users.txt task6-passwords.txt task7-users.txt task7-passwords.txt
Built-in scripts/libraries to study: /usr/share/nmap/scripts/ and /usr/share/nmap/nselib/
