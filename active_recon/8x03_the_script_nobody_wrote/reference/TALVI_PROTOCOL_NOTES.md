# Talvi management protocol (9700) — shape only, no findings

A line-oriented TCP protocol (NOT HTTP). On connect the server sends a one-line
banner. It accepts these safe, read-only commands (one per line, CRLF):

  HELLO          handshake
  VERSION        product + version lines
  CAPABILITIES   advertised capabilities
  VULN-CHECK     a SAFE privileged-interface probe (executes nothing)
  LOCKOUT        the account-lockout policy (threshold + window)
  AUTH <user> <password>   authenticate (AUTH-OK / AUTH-FAIL / AUTH-LOCKED)
  QUIT           close

The exact banner text, version value, vulnerability verdict, valid credentials
and lockout numbers are NOT documented here — read them from the live responses
in your scripts. No command changes server state.
