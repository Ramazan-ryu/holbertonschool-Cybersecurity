# Email Authentication Analysis

This document reviews SPF, DKIM, and DMARC authentication results for the eight analyzed emails and explains what the results indicate about sender legitimacy and possible phishing activity.

## Email 1 — healthcare-education-weekly.com

- SPF: Pass
- DKIM: Pass
- DMARC: Pass
- Authentication verdict: Authentication checks succeeded for the sending domain.
- Investigation meaning: SPF, DKIM, and DMARC alignment are consistent with legitimate email delivery for this domain.

## Email 2 — meddefense-portal.com

- SPF: Fail
- DKIM: None
- DMARC: Fail
- Authentication verdict: The email fails SPF and DMARC authentication checks and does not contain a DKIM signature.
- Investigation meaning: SPF failure shows the sending IP is not authorized for the domain. Missing DKIM means message integrity cannot be verified. DMARC failure shows identity misalignment. These authentication failures are consistent with phishing or spoofed email activity.

## Email 3 — outlook-protection.com

- SPF: Pass
- DKIM: Pass
- DMARC: Pass
- Authentication verdict: SPF, DKIM, and DMARC pass for outlook-protection.com.
- Investigation meaning: The authentication checks only verify that the sender is authorized to use outlook-protection.com. However, outlook-protection.com is not microsoft.com and is not outlook.com. Because of this, the authentication results do not prove the message is a legitimate Microsoft email. This demonstrates that phishing emails can still pass SPF, DKIM, and DMARC when attackers control their own lookalike domain.

## Email 4 — meddefense.com

- SPF: Pass
- DKIM: Pass
- DMARC: Pass
- Authentication verdict: Authentication checks succeeded for the sending domain.
- Investigation meaning: SPF, DKIM, and DMARC alignment are consistent with legitimate internal email activity.

## Email 5 — medequip-supplies.net

- SPF: Softfail
- DKIM: None
- DMARC: Fail
- Authentication verdict: The email shows weak authentication results.
- Investigation meaning: SPF softfail indicates the sending source is not fully authorized for the domain. Missing DKIM means message integrity cannot be verified. DMARC failure shows identity misalignment. Weak authentication results like these are commonly associated with phishing or fraudulent email activity.

## Email 6 — canadian-pharma-discount.org

- SPF: Softfail
- DKIM: None
- DMARC: Fail
- Authentication verdict: The email shows weak authentication results.
- Investigation meaning: SPF softfail indicates the sending source is not fully authorized. Missing DKIM prevents integrity verification. DMARC failure and quarantine policy indicate that messages failing authentication should be treated as suspicious or spam.

## Email 7 — meddefense-benefits.org

- SPF: Fail
- DKIM: None
- DMARC: Fail
- Authentication verdict: The email fails authentication validation checks.
- Investigation meaning: SPF failure shows the sending source is unauthorized for the domain. Missing DKIM removes integrity verification, and DMARC failure confirms identity mismatch. These authentication failures are consistent with phishing or spoofed email activity.

## Email 8 — hhs.gov

- SPF: Pass
- DKIM: Pass
- DMARC: Pass
- Authentication verdict: Authentication checks succeeded for the sending domain.
- Investigation meaning: SPF, DKIM, and DMARC alignment are consistent with legitimate government email infrastructure.
