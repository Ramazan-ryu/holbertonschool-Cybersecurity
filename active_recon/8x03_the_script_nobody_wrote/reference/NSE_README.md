# NSE quick reference (neutral, no answers)

An NSE script has three parts:
  * head: `description`, `author`, `license`, `categories` (NSEDoc @usage/@output/@args).
  * rule: `portrule`/`hostrule`/`prerule`/`postrule`. Use the `shortport` library
    (e.g. `shortport.port_or_service(PORT, "name")`) to gate on the right port.
  * action: the work; emit results with `stdnse.format_output`/`stdnse.output_table`
    or `vulns.Report` — never `print()`.
Useful libraries: shortport, stdnse, http, nmap (sockets), comm, vulns, brute,
creds, unpwdb. Pass data between scripts in one scan via `nmap.registry`.
Inspect real examples under /usr/share/nmap/scripts and /usr/share/nmap/nselib.
