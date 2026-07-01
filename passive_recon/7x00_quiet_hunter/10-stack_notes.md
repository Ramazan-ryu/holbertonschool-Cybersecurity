# Technology Stack Notes — Task 10

## Finding 1: CMS exact name and version
- Value: Veridian CMS 5.2.1
- Source chain:
  * Task 2: Specific source code finding. Inspection of the live site's HTML source code revealed the exact generator meta tag `<meta name="generator" content="Veridian CMS 5.2.1">`.
  * Task 4: Specific archive finding. The TimeVault web archive snapshots show the evolution of the CMS, with historical snapshots showing older asset paths and the latest archived snapshot explicitly confirming the upgrade to Veridian CMS 5.2.1.
  * Task 7: Specific job posting finding. The public job postings on the careers page specifically listed "experience with Veridian CMS" as a core technical requirement for incoming roles.

## Finding 2: Corporate email provider
- Value: ZephyrMail Business
- Source chain:
  * Task 1: Specific DNS finding. The DNS intelligence phase revealed MX records for the domain pointing directly to ZephyrMail routing servers.
  * Task 3: Specific document metadata finding. The email metadata gathered from the embedded properties of the corporate PDF documents corroborates the internal address structure and confirms ZephyrMail Business as the corporate email provider.
