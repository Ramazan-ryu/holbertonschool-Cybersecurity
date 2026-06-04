# Detection Recommendations

This document defines vendor-neutral detection opportunities based on the MedDefense phishing investigation.
These detections are designed for future implementation in email, DNS, endpoint, and threat intelligence systems.

---

## Detection 1 — Lookalike Domain Email Detection (Email Gateway)

**Detection Name**
Inbound Email From Lookalike MedDefense Domains

**Data Source**
- Email headers
- Sender domain
- Threat intelligence feeds

**Logic**
IF sender_domain CONTAINS "meddefense"
AND sender_domain != "meddefense.com"
THEN alert

**Expected Match**
Email 2, Email 7

**Severity**
High

**False Positives**
Legitimate subdomains or partner domains using MedDefense branding

**Response**
Quarantine email and block domain

---

## Detection 2 — SPF/DKIM/DMARC Failure Detection (Email Gateway)

**Data Source**
Email authentication logs

**Logic**
IF SPF == fail OR DKIM == none OR DMARC == fail
THEN flag email

**Expected Match**
Email 2, Email 5, Email 6, Email 7

**Severity**
High

**False Positives**
Misconfigured legitimate mailing systems

**Response**
Quarantine + investigate sender

---

## Detection 3 — DNS Query to Phishing Domains (DNS/Web Filtering)

**Data Source**
DNS logs / proxy logs

**Logic**
IF domain IN [meddefense-portal.com, medequip-supplies.net, meddefense-benefits.org]
THEN alert

**Expected Match**
Email 2 click event (Diane Marsh WS-NURSE-04)

**Severity**
Critical

**False Positives**
None if domains are confirmed malicious

**Response**
Block DNS resolution immediately

---

## Detection 4 — Suspicious Browser Activity After Email Click (Endpoint)

**Data Source**
Endpoint telemetry / browser logs

**Logic**
IF user clicks email link AND domain is unknown OR newly observed
THEN flag session

**Expected Match**
Email 2 click (Diane Marsh)

**Severity**
Critical

**False Positives**
First-time access to legitimate SaaS services

**Response**
Isolate endpoint if credential form detected

---

## Detection 5 — IOC / Threat Intelligence Match (Threat Intel)

**Data Source**
IOC feeds, internal blacklist

**Logic**
IF domain OR URL matches known phishing IOC list
THEN block + alert

**Expected Match**
Email 2, 5, 7 domains

**Severity**
High

**False Positives**
Low if IOC is validated

**Response**
Block domain across email + DNS + proxy

---

## Email 2 Click Protection Analysis (Diane Marsh)

The Email 2 click could have been prevented or detected by:

- DNS filtering blocking meddefense-portal.com
- Email gateway blocking SPF fail + lookalike domain
- IOC matching detecting known phishing domain
- Endpoint browser detection of credential harvesting page

This would have reduced risk before credential submission.

---

## Detection Categories Coverage

- Email Gateway → SPF/DKIM/DMARC + lookalike domain detection
- DNS/Web → phishing domain resolution blocking
- Endpoint → browser click + credential form detection
- Threat Intel → IOC-based blocking

---

## Detection Type Classification

**Preventive**
- DNS blocking of phishing domains
- Email gateway SPF/DKIM rejection
- IOC blocking

**Detective**
- Endpoint browser monitoring
- Email log anomaly detection

**Responsive**
- Endpoint isolation
- Domain takedown response
- Account password reset triggers
