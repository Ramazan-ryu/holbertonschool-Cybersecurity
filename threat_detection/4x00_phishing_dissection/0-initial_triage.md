# Initial Email Triage

| Email | From | Subject | SPF | DKIM | DMARC | Class | Priority | Evidence |
|---|---|---|---|---|---|---|---|---|
| E1 | newsletter@healthcare-education-weekly.com | Your April newsletter: Medication reconciliation best practices | pass | pass | pass | LEGITIMATE | P4-LOW | Authentication checks passed. Sender matches newsletter domain. Bulk mailing indicators and unsubscribe headers present. |
| E2 | noreply@meddefense-portal.com | ACTION REQUIRED: Portal re-verification needed within 24 hours | fail | none | fail | SUSPICIOUS | P1-URGENT | Failed authentication results, lookalike sender domain, urgent language, suspicious link, and user clicked the link. |
| E3 | security@outlook-protection.com | Unusual sign-in activity detected on your Microsoft 365 account | pass | pass | pass | SUSPICIOUS | P2-HIGH | Sender domain imitates Microsoft branding. Credential-harvesting link and urgent security warning. |
| E4 | it-announcements@meddefense.com | Reminder: Quarterly password change window opens April 20 | pass | pass | pass | LEGITIMATE | P4-LOW | Authentication passed. Internal sender domain and references to internal resources. |
| E5 | invoices@medequip-supplies.net | Invoice INV-2026-04891 — Payment required within 7 days | softfail | none | fail | SUSPICIOUS | P2-HIGH | Failed authentication, external payment link, suspicious sender domain and payment pressure. |
| E6 | deals@canadian-pharma-discount.org | 90% OFF Viagra, Cialis, Xanax — No prescription needed!!! | softfail | none | fail | SPAM | P4-LOW | Bulk spam advertising, failed authentication, direct-link marketing and unsolicited sender. |
| E7 | hr-notifications@meddefense-benefits.org | Open Enrollment closes TOMORROW — action required | fail | none | fail | SUSPICIOUS | P2-HIGH | Failed authentication, lookalike sender domain and urgent enrollment message. |
| E8 | HC3@hhs.gov | [HC3 ALERT — TLP:CLEAR] Active phishing campaign targeting regional healthcare | pass | pass | pass | LEGITIMATE | P3-MEDIUM | Authentication passed. Trusted government sender domain and sector threat intelligence bulletin. |

## Triage Summary

- SPAM: 1
- SUSPICIOUS: 4
- LEGITIMATE: 3
- Highest priority: E2 because Diane Marsh clicked the phishing link and immediate response is required.
