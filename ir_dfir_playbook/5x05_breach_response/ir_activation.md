# IR Activation: IR-2026-0420-01

incident_id: IR-2026-0420-01
declared_at: 2026-04-20T19:52Z
declared_by: Ramazan Mustafayev, On-Call Incident Response
initial_severity: SEV1 (Critical)

reasoning: Active multi-host enterprise compromise affecting clinical systems with confirmed credential access, lateral movement, C2 beaconing, unauthorized PHI access (1,847 records), and ransomware staging activity not yet executed. Immediate risk of encryption and confirmed evidence of data exfiltration require highest severity classification under healthcare breach criteria.

playbook_activated: Enterprise Ransomware and PHI Breach Response Playbook

reasoning_details:

* Multiple compromised clinical workstations (CS-WS-101, 104, 107, 112)
* File server compromise (FILE-SVR-01)
* Scheduling server compromise (SCHED-SVR-01)
* Cobalt Strike beaconing confirmed (45.152.66.114 / staging.office365-cdn.net)
* LSASS access and credential dumping behavior observed
* Unauthorized access to PHI (1,847 PDF clinical records)
* Likely exfiltration observed via large encrypted outbound transfer
* Ransomware staging scripts deployed but not executed

notifications:

* 2026-04-20T19:52Z — Mike Torres instructed to preserve and prepare isolation of affected systems
* 2026-04-20T19:54Z — SOC SEV1 bridge activated
* 2026-04-20T19:55Z — James Chen notified of multi-host compromise and PHI risk
* 2026-04-20T19:56Z — Dr. Morales notified of SEV1 clinical systems incident
* 2026-04-20T19:58Z — Infrastructure operations alerted for containment readiness
* 2026-04-20T20:01Z — Legal/compliance notified for potential HIPAA breach

first_communication: executive_status_update sent to Dr. Morales at 2026-04-20T20:05Z

verbatim_first_communication:
A SEV1 cybersecurity incident has been declared affecting multiple clinical systems at Site A. Initial investigation confirms malicious activity consistent with an active ransomware intrusion involving credential compromise, lateral movement, and unauthorized access to clinical file shares containing patient information. Ransomware staging artifacts have been identified but encryption activity has not yet been confirmed. Incident Response has initiated containment and forensic preservation procedures. At this time affected systems remain powered on for evidence preservation while network isolation actions are coordinated. Additional updates will follow as scope validation and containment progress.

