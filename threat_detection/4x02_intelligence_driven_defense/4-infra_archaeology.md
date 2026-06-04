# Infrastructure Archaeology – HEALTHBANE Campaign

## Overview
This assessment expands the original infrastructure analysis of the HEALTHBANE threat campaign using the following core source materials:
* meddefense_4x00_findings.txt
* HC3_Advisory_HEALTHBANE_TLP_CLEAR.txt
* researcher_blog_analysis.txt
* commercial_feed_extract.json

Our goal is to map the broader HEALTHBANE operational infrastructure across 4x00, HC3, researcher, and commercial feed datasets to identify reuse and flag anomalies.

---

## 1. Consolidated Infrastructure Overview

### Stage 1 – Credential Harvesting Infrastructure (credential-harvest)
This segment traces early access vectors used to deploy initial exploitation campaigns.

* **meddefense-portal.com** (IP: 91.234.99.107) - Source: meddefense_4x00_findings.txt / HC3
* **outlook-protection.com** (IP: 51.38.42.17) - Source: meddefense_4x00_findings.txt / commercial feed

### Stage 2 – Malware Delivery Infrastructure
Infrastructure used to deliver secondary malware payloads following credential harvest operations.

* **healthbane-c2.net** (IP: 51.38.42.191) - Source: HC3 / researcher / commercial feed
* **update-healthbane.net** (IP: 45.77.218.9) - Source: HC3 / commercial feed

### Stage 3 – DNS Exfiltration Infrastructure
Covert channels used for data extraction and system beacons.

* **data-sync.healthbane-c2.net** - Source: HC3 / commercial feed
* **sync_healthdata.ps1** - Source: researcher_blog_analysis.txt

---

## 2. Infrastructure Clustering Analysis

### Cluster A – Core HEALTHBANE Credential Harvesting Cluster
This group is tied to Stage 1 credential-harvest operations.

* **registrar:** Namecheap
* **registration window:** 2026-04-05 → 2026-04-10
* **hosting provider:** Hostinger / OVH / DigitalOcean
* **ASN:** AS16276 / AS14061
* **certificate:** Let's Encrypt certificates
* **email-sending software:** PHPMailer 6.6.0
* **document-generation tooling:** PhishKit-v4.2 builder parameters
* **domain naming:** healthcare + portal / benefits / supplies

**Confirmed Members:**
* meddefense-portal.com
* outlook-protection.com

---

### Cluster B – HEALTHBANE C2 and Exfiltration Cluster
This group handles Stage 2 malware execution and Stage 3 covert communications.

* **registrar:** Namecheap
* **registration window:** 2026-04-12 → 2026-04-15
* **hosting provider:** OVH
* **ASN:** AS16276
* **certificate:** Let's Encrypt TLS pattern
* **email-sending software:** None (C2 functionality only)
* **document-generation tooling:** Dynamic PE modification
* **domain naming:** healthbane + c2 / update

**Confirmed Members:**
* healthbane-c2.net
* update-healthbane.net

---

## 3. Threat Intelligence Pivot Points
* Technical links tie active C2 channels directly to automated exfiltration parsing arrays.

---

## 4. Commercial Feed Triage Assessment

Indicators within the commercial feed have been evaluated to verify if they belong to the same campaign, are plausible but unconfirmed, or represent low-fidelity noise.

* **same campaign:** high confidence elements matching established certificate layouts.
* **plausible:** unconfirmed entries that resemble known infrastructure footprints.
* **noise:** low confidence elements from broad automated arrays or hosting provider nets.

> **Operational Warning:** Indicators categorized as noise or unconfirmed should not be operationalized without more evidence. Blindly blocking broad hosting provider setups or unverified elements introduces a high false-positive risk.

---

## 5. Campaign ASCII Infrastructure Diagram

```text
========================================================================================
                          HEALTHBANE OPERATIONAL INFRASTRUCTURE MAP                     
========================================================================================

 [Stage 1: credential-harvest]
   |-- meddefense-portal.com            [source attribution: 4x00 / meddefense_4x00_findings.txt]
   |-- outlook-protection.com           [source attribution: 4x00 / commercial feed]
   |
   +---> Linked via: registrar & registration window patterns
   |
 [Stage 2: malware delivery]
   |-- healthbane-c2.net                [source attribution: HC3 / researcher / commercial feed]
   |-- update-healthbane.net            [source attribution: HC3 / commercial feed]
   |
   +---> Technical Pivot: Hardcoded C2 config references
   |
 [Stage 3: DNS exfiltration]
   |-- data-sync.healthbane-c2.net      [source attribution: HC3 / commercial feed]

========================================================================================
 [UNCERTAIN OR LOW CONFIDENCE CLUSTER] (commercial feed Triage)
========================================================================================
   |
   +-- rx-benefits-portal.com ---------> [unconfirmed] (Plausible infrastructure overlap)
   |
   +-- 104.244.42.1 -------------------> [uncertain] [noise] [low confidence]
                                         *CRITICAL: should not be operationalized without more evidence*
========================================================================================
