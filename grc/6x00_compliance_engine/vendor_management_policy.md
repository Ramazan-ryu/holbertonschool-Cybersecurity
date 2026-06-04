# Vendor Management Policy

Policy number: MD-VMP-001  
Policy title: Vendor Management Policy  
Effective date: 2026-06-01  
Review date: 2027-06-01  
Owner: IT Security and Procurement (joint ownership)  
Approved by: CISO  
Classification: Internal Use  
Applies to: All third-party vendors, suppliers, service providers, subcontractors, SaaS providers, managed service providers, cloud infrastructure providers, medical device vendors with network-connected systems, and staffing agencies with any system or network access.

---

## Purpose and scope

This policy defines mandatory security, privacy, and risk management requirements for all third parties that interact with MedDefense systems or data.

This policy applies to SaaS providers, managed service providers, cloud infrastructure providers, medical device vendors with network-connected systems, staffing agencies with system or network access, and any subcontractors acting on their behalf.

This policy ensures vendors are assessed, approved, continuously monitored, and securely offboarded to protect MedDefense systems, clinical operations, and electronic protected health information (ePHI).

---

## Vendor risk tiers

### Tier A (Critical)

Vendors that access, store, transmit, or process ePHI or clinical systems.

Examples:
- CloudVault Medical (backup archives and disaster recovery storage containing Epic EHR exports)
- Epic integration and support vendors
- Laboratory Information System backup and support providers
- PACS/RIS imaging vendors
- Pharmacy dispensing system vendors
- Any vendor handling backup archives containing patient identifiers or clinical datasets

---

### Tier B (Standard)

Vendors with access to MedDefense internal systems or networks but no direct access to ePHI.

Examples:
- Endpoint monitoring providers
- Internal collaboration SaaS platforms
- IT service management tools
- Security telemetry and logging providers

---

### Tier C (Low)

Vendors with no logical access to MedDefense systems or data.

Examples:
- Facilities contractors
- Office supply vendors
- Physical maintenance services
- Non-IT service providers

---

## Pre-engagement requirements by tier

### Tier A requirements

No Tier A vendor may be onboarded unless ALL requirements are met:

- Executed Business Associate Agreement (BAA) signed by both parties (mandatory, no exceptions)
- SOC 2 Type II report or HITRUST CSF certification within the last 12 months
- Completed vendor security questionnaire approved by IT Security
- penetration test results (penetration test conducted within the last 12 months) including remediation status of critical findings
- Full sub-processor inventory including:
  - Name of each sub-processor
  - Jurisdiction of each sub-processor
  - Data types processed
- Sub-processor risk review approval by IT Security and Legal
- Explicit CISO approval prior to production access

no Tier A vendor onboards without an executed BAA

---

### Tier B requirements

- Completed security questionnaire
- IT Security access approval
- Data flow documentation for all systems accessed
- Contract security clauses approved by Procurement and IT Security

---

### Tier C requirements

- Procurement registration only
- Confirmation of no system or data access
- Basic confidentiality obligations where applicable

---

## BAA requirements

A Business Associate Agreement is required for:
- All Tier A vendors
- Any vendor that may access, store, transmit, or indirectly expose ePHI

Minimum BAA requirements:
- Permitted uses and disclosures of ePHI
- HIPAA Security Rule safeguard obligations
- Subcontractor flow-down obligations
- Mandatory breach notification within 24 hours of confirmed or suspected incident affecting MedDefense data
- Data return or certified destruction upon termination
- Right for MedDefense to audit compliance

---

## Ongoing monitoring

- Tier A vendors reviewed annually
- Tier B vendors reviewed every 24 months
- Tier C vendors reviewed upon renewal or change in access

Immediate out-of-cycle review required for:
- New sub-processors or jurisdiction changes
- Ownership changes
- Security incidents or suspected compromise
- Changes in data flows involving MedDefense systems or backups (including CloudVault Medical)

---

## Vendor offboarding

- All vendor access revoked within 24 hours of termination
- All credentials, API keys, and system access disabled immediately
- All MedDefense data returned or securely destroyed within 30 days
- Vendor must provide written certification of destruction or return
- Records retained for six years per HIPAA requirements

---

## Incident notification obligations

- Vendors must notify MedDefense within 24 hours of any confirmed or suspected security incident involving MedDefense data
- Initial report must include scope, affected systems, and containment actions
- Vendors must cooperate fully with MedDefense investigation activities

MedDefense reserves the right to perform independent investigations regardless of vendor findings.

---

## Enforcement

Failure to comply with this policy may result in:
- Immediate suspension of access
- Contract termination
- Legal or regulatory action

---

## Review cycle

This policy is reviewed annually by IT Security and Procurement and approved by CISO.

It is also reviewed after any vendor-related security incident, supply chain compromise, or audit finding.

---

## Acknowledgment

I acknowledge that I have read, understood, and agree to comply with this policy.

Employee name:

Signature:

Date:
