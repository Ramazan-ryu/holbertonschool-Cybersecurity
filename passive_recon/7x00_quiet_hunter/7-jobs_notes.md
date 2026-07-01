# Task 7 — Job Postings Intelligence
## Findings to record

### 1. Internal CRM tool

- **Value:** Salesforce Financial Services Cloud
- **Exact source (URL / file / metadata field):** http://[PROVIDED_IP]/careers/crm-administrator (Job Description for CRM Administrator)
- **Justification (1 line):** This internal CRM tool name was obtained from public URLs only, passively read from a public job posting without any system interaction.
- **Cross-reference / alternative ruled out:** The posting explicitly confirms the migration from an older on-premise system to this exact tool, ruling out legacy CRM references.

### 2. Primary programming language

- **Value:** TypeScript
- **Exact source (URL / file / metadata field):** http://[PROVIDED_IP]/careers/backend-developer (Job Description for Backend Developer)
- **Justification (1 line):** The primary programming language was obtained from public URLs only, passively extracted from the role's technical requirements without any system interaction.
- **Cross-reference / alternative ruled out:** The posting explicitly notes that all new microservices are written in TypeScript, ruling out Python which is only mentioned as part of the historical codebase.

### 3. Hiring manager for a technical role

- **Value:** Sander de Boer, Head of Technical Operations
- **Exact source (URL / file / metadata field):** http://[PROVIDED_IP]/careers/backend-developer (Contact section of the Backend Developer posting)
- **Justification (1 line):** The hiring manager's name and title were obtained from public URLs only, passively read from the application instructions without any system interaction.
- **Cross-reference / alternative ruled out:** Found explicitly in the contact instructions for technical applicants, confirming him as the direct technical hiring manager rather than a general HR contact.

## Open questions / things to verify

- None. All findings were obtained from public URLs only and no requests were made to internal endpoints, directories, or discovered services.
