# 7-click_investigation.md

## Click Investigation — Diane Marsh / WS-NURSE-04

### Confirmed Facts

- User: Diane Marsh
- Workstation: WS-NURSE-04
- IP address: 10.10.2.15
- Related email: Email 2
- Related domain: meddefense-portal.com
- Timestamp: 2026-04-14 15:02:33 CDT
- Evidence status: The provided evidence confirms that the phishing link was clicked from WS-NURSE-04 by Diane Marsh
.
---

### Key Unknowns

The available evidence confirms that the phishing link was clicked, but several important questions remain unanswered:

- Whether Diane Marsh entered credentials into the phishing portal
- Whether any files were downloaded after the click
- Whether malicious scripts or browser-based payloads executed
- Whether the workstation communicated with additional attacker infrastructure
- Whether the user account was accessed after the phishing event
- Whether MFA prompts were triggered or approved
- Whether persistence mechanisms or mailbox rules were created

Because endpoint and SIEM logs are not provided in this project, compromise cannot currently be confirmed or ruled out.

---

### Risk Assessment

A confirmed phishing link click should be treated as a potential account compromise event until further investigation is completed,   even without proof of credential submission.


The phishing email used a lookalike domain and impersonation techniques designed to obtain user credentials. If credentials were entered, attackers could gain access to:

- Corporate email accounts
- VPN or remote access services
- Internal healthcare systems
- Sensitive patient or operational information

Even without credential entry, phishing sites may attempt:

- Browser-based malware delivery
- Session cookie theft
- Redirects to secondary malicious infrastructure
- User tracking or reconnaissance

The account and workstation should be treated as potentially compromised until follow-up investigation is completed.


---

### Endpoint Checks To Perform

If endpoint logs or forensic data become available, the following checks should be performed on WS-NURSE-04:

- Review browser history for access to meddefense-portal.com
- Review downloaded files associated with the phishing event
- Review temporary download directories
- Review browser cache
- Review recent process execution activity
- Review PowerShell execution history
- Review cmd.exe execution history
- Review scheduled tasks and startup persistence locations
- Review newly created or modified files after the click timestamp
- Review antivirus or endpoint detection alerts
- Review outbound network connections
- Review DNS query history
- Review browser extensions

These checks are recommended follow-up investigative actions and have not been performed within this project.

---

### Account Checks To Perform

If identity platform or authentication logs become available, the following checks should be performed for Diane Marsh:

- Review failed login attempts
- Review successful logins from unusual IP addresses
- Review successful logins from unusual locations
- Review MFA prompt activity
- Review MFA approvals
- Review password reset activity
- Review inbox forwarding rules
- Review mailbox access sessions
- Review OAuth application consent activity
- Review group membership changes
- Review VPN or remote-access sessions
- Review sign-in activity outside normal working hours


These checks are recommended follow-up investigative actions and have not been performed within this project.

---

### Decision Matrix

| Scenario | Description | Investigation Outcome |
|---|---|---|
| No compromise found | Link was opened but no credential entry, malware execution or suspicious account activity identified | Continue monitoring and document incident |
| Possible credential exposure | Evidence suggests credentials may have been entered or suspicious authentication activity is observed | Reset credentials, revoke sessions and increase monitoring |
| Confirmed compromise | Unauthorized account activity, malware execution or attacker persistence identified | Full incident response escalation and containment required |

---

### Recommended Containment

Recommended containment actions include:

- Reset Diane Marsh’s password
- Revoke active authentication sessions
- Require MFA reauthentication
- Conduct a user interview to determine whether credentials were entered
- Monitor for suspicious login activity
- Increase monitoring on WS-NURSE-04
- Block access to the phishing domain at email and network layers
- Search for additional recipients of the same phishing email
- Review whether similar phishing messages bypassed filtering controls

These actions are appropriate precautionary measures based on the confirmed phishing-link interaction.

---

### Conclusion

The available evidence confirms that Diane Marsh clicked the phishing link associated with Email 2 from workstation WS-NURSE-04. However, the provided evidence does not confirm credential theft, malware execution or account compromise.

Because the phishing email used credential-harvesting techniques, the incident should be treated as potentially high risk until endpoint and identity investigations are completed. Additional logging and forensic review would be required to determine the final impact.
