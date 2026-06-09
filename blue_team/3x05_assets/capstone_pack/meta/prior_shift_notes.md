# Prior Shift Notes — MedDefense SOC

**Shift:** 2026-04-07 22:00Z to 2026-04-08 06:00Z
**Analyst:** J. Wong (Tier 1)

## Open Items for Next Shift

1. **rad-srv-02** — Unusual outbound HTTPS observed at 23:47Z to IP 198.51.100.73.
   Change ticket CHG-2026-0341 was active but the outbound traffic destination does not match
   the approved vendor update server. Left open — needs correlation with new shift data.

2. **bill-ws-09** — User bill_user_09 had 7 failed RDP auth attempts from 203.0.113.44
   between 01:15Z and 01:22Z. Blocked by firewall after 7 attempts. Password spray pattern.
   No successful auth confirmed but monitor closely in next window.

## Alerts Closed This Shift

- 34 routine authentication events: batch-closed as expected baseline
- 2 network scanner events from external IPs: closed as internet noise
- 1 off-hours admin logon on srv-dc-01: confirmed authorized (CHG-2026-0343 window)

## Notes

- HC-RED7 IOC feed updated at 04:15Z — new C2 IPs added (198.51.100.82)
- Medical IoT firewall rule lan_medical/permit_vendor_update flagged by security team for review — escalated to robert.kim
