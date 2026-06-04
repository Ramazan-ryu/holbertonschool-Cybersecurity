# Threat Intelligence Enrichment Plan — MedDefense Phishing Campaign

---

## 1. Objective

This document defines how extracted phishing IOCs from the MedDefense investigation should be operationalized across security controls, monitoring systems, and intelligence-sharing channels in an offline-capable security environment.

---

## 2. IOC Destination Mapping

### 2.1 Email Gateway (Block / Quarantine)

**IOC Types:**
- Phishing domains (meddefense-portal.com, medequip-supplies.net, meddefense-benefits.org)
- Sender domains failing SPF/DKIM/DMARC
- Lookalike healthcare domains

**Why:**
Primary defense layer against phishing delivery.

**Action on Match:**
- Quarantine or reject email
- Flag as high-risk phishing attempt

**False Positive Risk:**
Medium (legitimate third-party vendors may use similar naming)

**Owner:**
Email Security Team

---

### 2.2 DNS Filtering System

**IOC Types:**
- Phishing domains
- Newly observed malicious domains
- HC3-reported domains

**Why:**
Prevents user access to malicious infrastructure before connection.

**Action on Match:**
- Block DNS resolution
- Redirect to security warning page

**False Positive Risk:**
Low to Medium (domain overlap possible in healthcare suppliers)

**Owner:**
Network Security Team

---

### 2.3 Web Proxy / URL Filtering

**IOC Types:**
- URLs with login or credential harvesting paths
- Phishing landing pages
- Lookalike domains with HTTPS login forms

**Why:**
Stops credential submission even if email bypasses filters.

**Action on Match:**
- Block URL access
- Display security interstitial warning

**False Positive Risk:**
Medium (legitimate login portals may be misclassified)

**Owner:**
Network / Web Security Team

---

### 2.4 Endpoint / EDR Watchlist

**IOC Types:**
- Visited phishing URLs (browser telemetry)
- Credential entry events on suspicious domains
- Downloads from phishing infrastructure

**Why:**
Detects post-click compromise activity.

**Action on Match:**
- Alert SOC
- Isolate endpoint if credential entry detected

**False Positive Risk:**
Low (requires strong behavioral correlation)

**Owner:**
Endpoint Security Team

---

### 2.5 SIEM Threat Intelligence Integration

**IOC Types:**
- All domains, sender addresses, authentication failures
- Click events tied to phishing URLs
- Role-based targeting patterns

**Why:**
Central correlation of all campaign activity.

**Action on Match:**
- Generate correlated incident
- Trigger phishing campaign detection alert

**False Positive Risk:**
Medium (depends on tuning rules)

**Owner:**
SOC Team

---

### 2.6 HC3 / ISAC Submission

**IOC Types:**
- Confirmed phishing domains
- Campaign patterns (role-based targeting, healthcare impersonation)
- Email header anomalies

**Why:**
Supports broader healthcare sector defense collaboration.

**Action on Match:**
- Share sanitized intelligence report
- Update sector threat awareness feeds

**False Positive Risk:**
None (reporting layer only)

**Owner:**
Threat Intelligence Team

---

## 3. Prioritization Plan

### Immediate Enrichment (0–24 hours)
- meddefense-portal.com
- medequip-supplies.net
- meddefense-benefits.org
- SPF/DKIM/DMARC failure patterns

### Monitoring Only (7–30 days)
- outlook-protection.com (brand impersonation, not confirmed malicious)
- new similar-looking domains
- email header anomalies (PHPMailer patterns)

### Context-Only (Do Not Block Automatically)
- HC3 advisory references
- general healthcare phishing trends
- vendor infrastructure overlaps

---

## 4. Validation Plan

## 4. Validation Plan

### Offline validation approach

Validation can be performed using archived email samples, exported email headers, browser history artifacts, and previously collected investigation notes. Live SIEM, Wazuh, Sysmon, Suricata, or active phishing infrastructure deployment is not required.

### Controlled enrichment testing

- Import known phishing domains from Emails 2, 5, and 7 into a test IOC list
- Replay archived phishing emails through a non-production email filtering workflow
- Verify that:
  - meddefense-portal.com is quarantined
  - medequip-supplies.net is blocked by URL filtering
  - meddefense-benefits.org generates phishing alerts
- Attempt local DNS resolution requests against blocked domains in a lab environment
- Confirm that enrichment rules generate alert records from archived log samples

### Historical event validation

Review historical evidence associated with the campaign:

- Email 2 delivery logs from April 14
- Email 5 delivery logs from April 16
- Email 7 delivery logs from April 16
- Diane Marsh click event from WS-NURSE-04
- Authentication-failure evidence:
  - SPF failures
  - DKIM missing results
  - DMARC failures
- PHPMailer-related header indicators observed across phishing emails

Validation should confirm that these historical events would have triggered IOC matches or phishing alerts if enrichment rules had existed at the time.

### Success criteria

Validation is considered successful if:

- Known phishing domains are flagged or blocked during replay testing
- Archived phishing emails generate phishing classifications
- Authentication-failure indicators trigger enrichment matches
- Browser or click-history artifacts related to Email 2 produce watchlist alerts
- Role-based phishing patterns are detectable across clinical, finance, and HR targeting
- No legitimate emails from the evidence set are incorrectly quarantined

### False-positive review

- Review whether legitimate healthcare vendor emails are incorrectly flagged
- Confirm that outlook-protection.com remains monitoring-only until additional evidence exists
- Adjust IOC severity levels if enrichment produces excessive false positives


---

## 5. Feedback Loop

### Continuous IOC updates
- New phishing emails added to IOC list after validation
- HC3 alerts used to enrich domain patterns and techniques
- Role-based targeting patterns added to detection logic

### IOC aging / cleanup
- Remove domains older than 90 days with no activity
- Deprioritize low-confidence indicators (generic hosting domains)
- Revalidate HC3 indicators periodically

### Improvement cycle
- Incident reports feed back into IOC database
- SOC tuning reduces false positives over time
- New campaigns refine detection precision

---

## 6. Summary

This enrichment plan ensures that phishing indicators from the MedDefense campaign are operationalized across email, DNS, endpoint, and intelligence-sharing systems while maintaining control over false positives and ensuring continuous improvement through feedback and validation.
