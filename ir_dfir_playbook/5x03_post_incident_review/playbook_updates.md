# Playbook Updates: IR-2026-0414-01

This document implements critical modifications to the Incident Response Playbooks based on systemic gaps exposed during the validation cycle.

---

### Change PB-UPD-001
**Playbook:** playbook_credential_exposure.yaml
**Section:** applies_to.triggers
**Gap closed:** GAP-002
**Finding reference:** control_effectiveness.yaml phase 2 and forensic_findings_summary.md
**Before:**
triggers:
  - Alert: credential submitted to external domain
**After:**
triggers:
  - Alert: credential submitted to external domain
  - Alert: VPN authentication from country not seen for this account in 30 days
  - Alert: impossible-travel detected on account (two logins from geographically inconsistent foreign-IP addresses within 2 hours)
**Reason:** The incident entry point was a foreign-IP VPN login that matched no existing trigger; this gap allowed the intrusion to proceed for over eight hours without a playbook activation.

---

### Change PB-UPD-002
**Playbook:** playbook_credential_exposure.yaml
**Section:** containment.scope_expansion
**Gap closed:** GAP-005
**Finding reference:** forensic_findings_summary.md (ART-003-M01)
**Before:**
scope_expansion:
  - Action: Isolate confirmed compromised endpoint only
**After:**
scope_expansion:
  - Action: Isolate confirmed compromised endpoint only
  - Action: Enforce a mandatory scope expansion checklist when lateral movement is detected
  - Action: Expand containment to newly identified hosts when Pass-the-Ticket indicators surface
**Reason:** The original playbook had no structured step for expanding containment to newly identified hosts when lateral movement or Pass-the-Ticket indicators surface, allowing the threat actors to pivot unhindered.

---

### Change PB-UPD-003
**Playbook:** playbook_credential_exposure.yaml
**Section:** remediation.account_recovery
**Gap closed:** GAP-008
**Finding reference:** forensic_findings_summary.md (ART-001-R02)
**Before:**
remediation:
  - Step: Reset compromised account password
**After:**
remediation:
  - Step: Reset compromised account password
  - Step: Add krbtgt double-reset as a mandatory step for confirmed Pass-the-Ticket to invalidate forged tickets
**Reason:** The original playbook only specified a single account password reset but did not require a krbtgt double-reset, which is mandatory to completely invalidate forged Kerberos tickets during a Pass-the-Ticket attack.

---

### Change PB-UPD-004
**Playbook:** playbook_credential_exposure.yaml
**Section:** escalation_conditions
**Gap closed:** GAP-009
**Finding reference:** AD-LOG-01 inside forensic_findings_summary.md
**Before:**
escalation_conditions:
  - Metric: multiple standard endpoint compromise detected
**After:**
escalation_conditions:
  - Metric: multiple standard endpoint compromise detected
  - Decision: Add HIPAA four-factor assessment as a decision node when ePHI systems are in the blast radius of clinical systems
**Reason:** The original incident procedures lacked a legal branch for clinical systems, meaning there was no branch to initiate a HIPAA four-factor assessment when ePHI systems fell within the threat's blast radius.
