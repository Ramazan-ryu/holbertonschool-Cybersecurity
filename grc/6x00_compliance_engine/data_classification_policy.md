# Data Classification Policy

Policy number: MD-DCP-001
Policy title: Data Classification Policy
Effective date: 2026-06-01
Review date: 2027-06-01
Owner: IT Security
Approved by: CISO
Classification: Internal Use
Applies to: All MedDefense employees, contractors, vendors, temporary clinical staff, consultants, and third parties that create, store, transmit, process, or manage MedDefense data.

---

## Purpose and scope

This policy establishes mandatory requirements for classifying and handling MedDefense information based on sensitivity, regulatory requirements, and business impact.

This policy applies to all data created, stored, transmitted, received, processed, maintained, or disposed of by or on behalf of MedDefense.

The requirements in this policy apply regardless of whether information exists in electronic form, paper records, backup archives, cloud services, vendor-managed systems, or other storage media.

---

## Classification tiers

### Tier 1: Public

#### Definition

Information approved for release to the general public. Unauthorized disclosure is not expected to cause harm to MedDefense, patients, workforce members, or business partners.

#### Examples

* Approved press releases
* Public website content
* Public job postings
* Public recruiting materials
* Public health awareness campaigns

#### Handling requirements

* May be published externally after management approval.
* May be stored on public-facing systems.
* Integrity must be maintained through approved publication processes.
* Changes require approval from the information owner.

---

### Tier 2: Internal

#### Definition

Information intended for MedDefense employees and authorized contractors only. Unauthorized exposure causes operational inconvenience, not regulatory or patient harm.

#### Examples

* Internal operating procedures
* Internal meeting agendas
* Workforce directories
* Department schedules
* Internal training materials

#### Handling requirements

* Access limited to MedDefense personnel and authorized contractors.
* Stored on approved MedDefense systems.
* Shared internally only for legitimate business purposes.
* External distribution requires management approval.

---

### Tier 3: Confidential

#### Definition

Information whose unauthorized disclosure could cause financial, legal, operational, or reputational harm to MedDefense.

#### Examples

* Employee records
* Financial data
* Contracts
* Strategic plans
* Security configurations
* Network architecture documentation
* Incident investigation records
* Vendor assessment documentation
* CloudVault contract documentation
* Security monitoring configurations

#### Handling requirements

* Access restricted to authorized personnel with a documented business need.
* Stored only on approved managed systems with access controls.
* Encryption required on portable devices and removable media.
* External sharing requires documented authorization from the data owner.

---

### Tier 4: Restricted / ePHI

#### Definition

Information subject to the HIPAA Security Rule and Breach Notification Rule. Any unauthorized access triggers the four-factor breach risk assessment process.

#### Examples

* ePHI
* Patient records
* Lab results
* Clinical documentation
* Epic EHR database exports
* Laboratory Information System backups
* PACS/RIS metadata exports
* Pharmacy dispensing system backups
* Backup archives containing patient information
* Operational recovery logs containing patient identifiers
* Vendor data flows containing patient information

#### Handling requirements

* Access limited to authorized personnel under HIPAA minimum necessary requirements.
* Storage permitted only on approved systems with audit logging and access controls.
* External disclosure requires documented authorization and applicable legal or contractual authority.
* Business Associate Agreement requirements apply when information is handled by third parties.

---

## Handling matrix

| Tier                     | Storage                                                                                                                     | Transmission                                                                                                                                          | Internal sharing                                        | External sharing                                                                                      | Disposal                                                                                                                                       |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Tier 1 Public            | Public website, approved content repositories, approved collaboration platforms                                             | HTTPS using TLS 1.2 or higher with server certificate verification                                                                                    | Available to all workforce members                      | Permitted after approval by content owner                                                             | Standard deletion for electronic records; normal recycling or disposal for paper                                                               |
| Tier 2 Internal          | MedDefense-managed file shares, SharePoint repositories, approved collaboration systems                                     | HTTPS using TLS 1.2 or higher with server certificate verification, SFTP, or corporate email protected by TLS                                         | Employees and authorized contractors with business need | Management approval required before external release                                                  | Electronic deletion from approved systems; paper records shredded                                                                              |
| Tier 3 Confidential      | Managed servers, encrypted laptops, encrypted file repositories, approved document management systems                       | TLS 1.2 or higher with server certificate verification, SFTP, SSH, IPSec VPN, or secure email gateway with enforced TLS                               | Need-to-know basis approved by information owner        | Written authorization required; contractual protections required where applicable                     | Electronic media sanitized according to NIST SP 800-88 or equivalent; paper records destroyed using secure cross-cut shred methods             |
| Tier 4 Restricted / ePHI | Approved ePHI systems, encrypted databases, encrypted backup repositories, controlled cloud environments with audit logging | TLS 1.2 or higher with server certificate verification, SFTP, IPSec VPN, secure healthcare interfaces using TLS, or approved encrypted email services | Minimum necessary access only                           | Business Associate Agreement required when applicable; disclosure must comply with HIPAA requirements | Electronic media sanitized using NIST SP 800-88 media sanitization or equivalent; paper records destroyed using secure cross-cut shred methods |

---

## Classification responsibility

The individual, department, application owner, or business owner creating or collecting information is responsible for assigning the initial classification.

When classification is unclear, information shall be classified as Tier 3 until reviewed.

Authority to reclassify information resides with the data owner in coordination with IT Security and, when applicable, the Compliance Office.

No reclassification may reduce legal, contractual, regulatory, or HIPAA protection requirements.

---

## Exceptions process

Exceptions to this policy must be documented in writing and submitted to IT Security.

Exceptions require approval from the CISO and must include business justification, risk assessment, compensating controls, and requested duration.

All approved exceptions shall be recorded in an exception register maintained by IT Security.

The maximum exception duration before re-review is twelve months.

---

## Review cycle

This policy shall be reviewed annually by IT Security and approved by the CISO.

This policy shall also be reviewed following any security incident, privacy incident, audit finding, or event that exposed data handling as a control gap, including incidents involving vendor risk, backup archives, ePHI handling, or security configuration management.

---

## Acknowledgment

I acknowledge that I have read, understood and agree to comply with this policy.

Employee name:

Signature:

Date:

