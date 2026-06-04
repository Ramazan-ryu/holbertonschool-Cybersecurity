
# Vendor Risk Assessment: CloudVault Medical

---

## Vendor overview

Vendor name: CloudVault Medical  
Service type: Encrypted clinical backup and disaster recovery archive service  
Proposed Tier classification: Tier A (Critical Vendor) under Vendor Management Policy  
ePHI handling: Yes — encrypted backup archives containing Epic EHR exports, Laboratory Information System backups, PACS/RIS metadata, pharmacy system backups, and operational recovery logs containing patient identifiers  

---

## Findings table

| Item number | Finding | Risk rating | Gap description | Required action |
|------------|--------|------------|----------------|------------------|
| 1 | SOC 2 Type II (11 months old) | Acceptable | Valid but near renewal threshold | Require updated SOC 2 within 12 months |
| 2 | No HITRUST certification | Concern | Missing healthcare-specific assurance framework | Require compensating controls or roadmap |
| 3 | AES-256 encryption at rest | Pass | No gap identified | No action required |
| 4 | TLS 1.2 in transit | Pass | Meets baseline requirement | Enforce TLS 1.2 or higher with certificate validation |
| 5 | Penetration test 22 months ago | Critical Concern | Exceeds 12-month requirement; no findings provided | Require penetration test within 12 months and remediation evidence |
| 6 | Two sub-processors (US CDN, EU analytics) | Concern | EU analytics introduces jurisdiction and ePHI exposure ambiguity | Require sub-processor risk approval and data flow mapping |
| 7 | DR site location not disclosed | Critical Concern | Cannot validate data residency for disaster recovery | Require DR location disclosure and jurisdiction validation |
| 8 | Incident notification SLA is 72 hours | Critical Concern | Exceeds required 24-hour notification window | Amend contract to 24-hour notification SLA |
| 9 | Data deletion within 90 days | Concern | Exceeds MedDefense 30-day requirement | Reduce deletion period to 30 days |
| 10 | No recurring background checks | Concern | Increases insider risk over time | Require periodic re-screening for privileged access |
| 11 | MFA enabled (TOTP) | Pass | Meets requirement | No action required |
| 12 | Monthly scanning, quarterly remediation | Acceptable | Remediation timing not aligned to critical urgency expectations | Require faster remediation for critical vulnerabilities |
| 13 | Right-to-audit with 60-day notice | Concern | Delay reduces incident response effectiveness | Require expedited audit rights during incidents |
| 14 | Business Associate Agreement not executed | Critical Concern | No legal authorization for ePHI processing | BAA must be executed before any ePHI access |
| 15 | Annual PHI training | Acceptable | No role-based verification evidence | Require role-based training attestation |

---

## Critical findings

### 1. Penetration test is outdated (22 months)

CloudVault has not conducted a penetration test within the required 12-month window. This leaves unknown vulnerabilities in systems processing encrypted backup archives containing Epic EHR exports and other clinical data.

Regulatory impact: Without current penetration test evidence, MedDefense cannot demonstrate adequate third-party risk assurance under HIPAA Security Rule requirements.

Required before approval:
- penetration test report within last 12 months  
- remediation status for critical findings  
- confirmation of closure or risk acceptance for unresolved issues  

---

### 2. Disaster recovery site location not disclosed

CloudVault has not disclosed the disaster recovery site location, preventing validation of data residency and jurisdictional compliance.

Regulatory impact: MedDefense cannot verify whether backup data containing ePHI may be stored or processed outside approved jurisdictions.

Required before approval:
- DR site location disclosure  
- jurisdiction confirmation for all storage regions  
- confirmation DR sites comply with MedDefense requirements  

---

## Recommendation

Approve

Approve with conditions

Do not approve

### Rationale

CloudVault Medical does not meet mandatory Tier A requirements under the Vendor Management Policy. The absence of an executed Business Associate Agreement alone blocks approval.

---

## Contract conditions

If approval is reconsidered under conditions, the following must be met before any ePHI access:

- Executed Business Associate Agreement (BAA) prior to onboarding
- penetration test report within the last 12 months with remediation of critical findings
- DR site location disclosure and approved jurisdiction validation
- Reduction of incident notification SLA to 24 hours
- Reduction of data deletion period to 30 days
- Approved sub-processor risk assessment and data flow documentation

No ePHI may be transferred until all conditions are satisfied.
