# Verdict schema (neutral)

Verification verdicts are confirmed | false_positive | unconfirmed. An
unconfirmed verdict also carries `to_settle`. Each verdict records evidence and a
`stopped_at` (presence/reachability, not impact). The scanner-missed finding uses
the id DISCOVERED-001.
