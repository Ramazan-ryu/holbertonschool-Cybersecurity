# MedDefense Severity Matrix

## Purpose

Provides a unified severity classification system for all MedDefense incidents. Ensures consistent response actions from initial detection through incident closure.

## Severity Matrix

Level | Patient Safety Impact | Data Exposure | Service Availability | Max Response Time | Decision Authority
---|---|---|---|---|---
SEV1 | high | confirmed_broad | full_outage | 15 min | CISO
SEV2 | moderate | confirmed_limited | partial_outage | 30 min | IR Commander
SEV3 | low | suspected | degraded | 60 min | SOC Lead
SEV4 | none | none | none | 240 min | SOC Analyst

## Level Definitions

### SEV1
- Ransomware encrypting multiple clinical systems affecting patient care
- Confirmed large-scale exfiltration of patient health records (PHI)
- Core hospital systems unavailable during active treatment windows

### SEV2
- Confirmed compromise of privileged or clinical-access accounts
- Malware detected on systems connected to patient data environments
- Limited confirmed exposure of patient or operational data under investigation

### SEV3
- Phishing compromise of a single user with no confirmed data access
- Suspicious malware execution contained to a non-critical workstation
- Degraded performance in non-critical hospital IT services

### SEV4
- Suspicious activity with no confirmed compromise
- Blocked phishing attempts with no user interaction
- Minor service issues with no impact on clinical operations

## Escalation Rule

Severity is continuously reassessed during the incident lifecycle. It is increased immediately when new evidence impacts patient safety, expands data exposure, or worsens service availability. It is decreased only after containment is verified and approved by the IR Commander.
