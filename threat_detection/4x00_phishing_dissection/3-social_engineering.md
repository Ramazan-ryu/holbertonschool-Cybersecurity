## Email E2 — Portal re-verification lure

- Psychological lever: Authority + urgency + fear
- Pretext: “MedDefense IT Security” claims a mandatory portal re-verification due to a security policy update requiring action within 24 hours or access will be suspended.
- Requested action: Click (credential verification via login page)
- Targeting level: TARGETED
- Content red flags:
  - Lookalike domain (meddefense-portal.com instead of meddefense.com)
  - SPF fail and DMARC fail (spoofing indicators)
  - High-pressure deadline (24 hours)
  - Threat of operational disruption (EHR, scheduling, shift swaps)
  - Embedded login link with tracking token
- Attacker knowledge required:
  - User’s full name (Diane Marsh)
  - Employer (MedDefense)
  - Role context (clinical staff workflow access)
  - Internal systems (EHR, scheduling, shift management)
- Conclusion:
  Highly targeted credential harvesting attack using IT impersonation and operational fear.

---

## Email E3 — Microsoft account compromise alert

- Psychological lever: Fear + urgency + authority
- Pretext: Microsoft account security warning about unusual sign-in activity from an unrecognized device and location.
- Requested action: Click (account verification/login)
- Targeting level: SEMI-TARGETED
- Content red flags:
  - Lookalike domain (outlook-protection.com instead of microsoft.com)
  - Fake Microsoft branding misuse
  - 48-hour lockout threat
  - Fake geolocation alert (Nigeria login attempt)
  - Generic security template not tied to official Microsoft infrastructure
- Attacker knowledge required:
  - Victim email address (rmendez@meddefense.com)
  - Microsoft 365 usage context
- Conclusion:
  Credential harvesting attempt using fear of account compromise.

---

## Email E5 — Invoice lure

- Psychological lever: Financial pressure + authority + urgency
- Pretext: Supplier invoice requesting payment for medical supplies within 7 days with penalty threat.
- Requested action: Click (payment portal) + open attachment (PDF invoice)
- Targeting level: TARGETED
- Content red flags:
  - Lookalike vendor domain (medequip-supplies.net)
  - SPF softfail and DMARC fail
  - Embedded payment portal links
  - PDF attachment (potential malware vector)
  - High-value invoice to increase urgency
  - Threat of delivery suspension and late fees
- Attacker knowledge required:
  - Accounts payable identity (Angela Rivera)
  - Procurement/vendor relationship knowledge
  - Invoice processing workflow familiarity
- Conclusion:
  Business Email Compromise (BEC) style phishing aimed at financial fraud.

---

## Email E7 — HR benefits open enrollment lure

- Psychological lever: Scarcity + fear + urgency
- Pretext: HR notice claiming open enrollment is closing and failure to act will result in loss of benefits coverage.
- Requested action: Click (benefits enrollment portal login)
- Targeting level: TARGETED
- Content red flags:
  - Lookalike domain (meddefense-benefits.org instead of internal domain)
  - SPF fail and DMARC fail
  - “Final notice” urgency framing
  - Threat of losing health insurance coverage
  - Encouragement to verify even if already enrolled
- Attacker knowledge required:
  - Employee identity (Linda Patterson)
  - HR benefits process awareness
  - Enrollment cycle timing
- Conclusion:
  Highly targeted HR-themed phishing leveraging fear of benefits loss.

---

## Email E1 — Newsletter email

- Psychological lever: Engagement (non-malicious marketing)
- Pretext: Healthcare education newsletter subscription with articles and CME webinar content.
- Requested action: Click (read articles / unsubscribe)
- Targeting level: GENERIC
- Content red flags:
  - None (valid SPF, DKIM, DMARC pass)
  - Legitimate mailing infrastructure
  - Standard unsubscribe links
- Attacker knowledge required:
  - Email address only
- Conclusion:
  Legitimate newsletter used as baseline benign email.

---

## Email E6 — Pharmaceutical spam

- Psychological lever: Financial temptation + scarcity
- Pretext: Discount pharmacy advertising prescription drugs with no prescription required.
- Requested action: Click (purchase products)
- Targeting level: GENERIC
- Content red flags:
  - Spam score extremely high (9.8)
  - Illegal/unsafe pharmaceutical claims
  - HTTP link to IP address
  - Bulk email sender infrastructure
- Attacker knowledge required:
  - None (mass spam campaign)
- Conclusion:
  Generic spam campaign for illicit product sales or fraud.

---

## Email E4 — Internal IT announcement

- Psychological lever: Informational (no manipulation)
- Pretext: Internal reminder about scheduled password change window and proper portal usage.
- Requested action: No action or use internal portal
- Targeting level: GENERIC
- Content red flags:
  - None (internal Exchange signed email)
  - Explicit anti-phishing guidance
- Attacker knowledge required:
  - Internal IT process knowledge
- Conclusion:
  Legitimate internal communication reinforcing security behavior.
