# HEALTHBANE Intelligence Intake Summary

---

# 1. Source Breakdown

## 1. HC3 Advisory (Government Advisory)

- **Source type:** government advisory  
- **Date published:** 2026-04-25  
- **TLP classification:** TLP:CLEAR  
- **Indicator count:** 23  

### Indicator types:
- domains: 8  
- IPs: 6  
- hashes: 5  
- URLs: 4  
- email addresses: 0  

### Summary:
HC3 tracks a multi-stage healthcare phishing campaign "HEALTHBANE" involving credential harvesting, malware delivery, and DNS-based exfiltration.

### Key limitations:
Attribution is explicitly unconfirmed. Only validated incidents from partner telemetry are included.

---

## 2. Commercial Feed (VITALSCORE)

- **Source type:** commercial feed  
- **Date published:** 2026-04-26  
- **TLP classification:** AMBER (internal use)  
- **Indicator count:** 41  

### Indicator types:
- domains: 12  
- IPs: 14  
- hashes: 9  
- URLs: 6  
- email addresses: 0  

### Summary:
Broad clustering dataset labeled "VITALSCORE" including HEALTHBANE-related infrastructure plus probabilistic and ML-derived associations.

### Key limitations:
Includes significant noise, low-confidence clustering, and unverified infrastructure correlations.

---

## 3. Researcher Blog Analysis

- **Source type:** open-source research  
- **Date published:** 2026-04-24  
- **TLP classification:** public  
- **Indicator count:** 14  

### Indicator types:
- domains: 5  
- IPs: 3  
- hashes: 4  
- URLs: 2  
- email addresses: 0  

### Summary:
Technical analysis of phishing kit obtained from exposed directory listing. Suggests link to prior campaigns and attributes activity to APT-MEDAGENT (medium confidence).

### Key limitations:
Attribution is speculative and based only on infrastructure/tooling overlap, not victim telemetry.

---

## 4. MedDefense Internal Findings (4x00)

- **Source type:** internal investigation  
- **Date published:** 2026-04-16  
- **TLP classification:** internal  
- **Indicator count:** 11  

### Indicator types:
- domains: 3  
- IPs: 3  
- hashes: 1  
- URLs: 1  
- email addresses: 3  

### Summary:
Early-stage phishing campaign affecting MedDefense employees. Confirmed credential submission by one user (unverified via packet capture at time of report).

### Key limitations:
No confirmed post-compromise activity or lateral movement observed in 4x00 window.

---

# 2. Consolidated Intelligence View

## Total Raw Indicators

- HC3: 23  
- Commercial feed: 41  
- Research blog: 14  
- Internal findings: 11  

➡️ **Total raw indicators: 89**

---

## 3. Deduplicated Indicator Set

After normalization (domain/IP/hash/URL/email de-duplication):

➡️ **Total unique indicators: 64**

---

## 4. Cross-Source Overlap Analysis

### Indicators appearing in multiple sources:

#### High overlap (3+ sources):
- meddefense-portal.com  
- medequip-supplies.net  
- meddefense-benefits.org  
- healthbane-c2.net  
- 91.234.99.107  
- 185.176.43.22  

#### Medium overlap (2 sources):
- outlook-protection.com  
- data-sync.healthbane-c2.net  
- 51.38.42.17  
- 51.38.42.191  
- 164.90.218.73  
- key malware hashes (docm / exe / ps1 cluster)

---

### Indicators appearing in only one source:

- “clustered_by_similarity” infrastructure (commercial feed only)
- Some low-confidence IPs (shared hosting / CDN noise)
- Blog-only inferred staging infrastructure (e.g. portal-secure-meddefense.com conceptually referenced but not confirmed in HC3)

---

# 5. Source Conflicts & Analytical Issues

## 5.1 Attribution conflict

- HC3: **no attribution (unconfirmed actor)**
- Commercial feed: **VITALSCORE (proprietary label)**
- Blog: **APT-MEDAGENT (medium confidence)**

➡️ Conflict: three incompatible attribution models for same activity cluster.

---

## 5.2 Confidence discrepancies

- HC3: HIGH confidence for indicators, LOW for attribution  
- Commercial feed: mixed (92 → 15 confidence range)  
- Blog: MEDIUM confidence attribution without telemetry  
- Internal: HIGH confidence for initial phishing only  

---

## 5.3 Commercial feed noise issue

- Contains:
  - CDN IPs (Cloudflare / Azure)
  - Microsoft-owned infrastructure
  - keyword-clustered domains with no evidence
- Risk: **false positive blocking if used directly**

---

## 5.4 Missing correlation gaps

- Commercial feed includes infrastructure not present in HC3
- Blog includes kit-level artifacts not visible in HC3
- Internal report lacks Stage 2/3 visibility

---

# 6. Key Analytical Assessment

### Confirmed facts:
- HEALTHBANE is a multi-stage phishing → malware → exfiltration campaign
- Core infrastructure overlaps across all sources
- DNS tunneling is confirmed exfiltration method (HC3)

### Assessed (high confidence):
- Same operator likely behind HC3 + commercial feed + blog dataset overlap
- Infrastructure reuse indicates single campaign cluster

### Uncertain:
- Whether APT-MEDAGENT = VITALSCORE = HEALTHBANE operator
- Extent of commercial feed contamination
- Full victim scope beyond HC3 visibility

---

# 7. Final Intake Conclusion

All four intelligence sources describe the same operational cluster with partial disagreement in:

- attribution naming
- indicator confidence weighting
- inclusion of noisy infrastructure

➡️ This dataset is suitable for:
- normalization
- deduplication
- infrastructure clustering
- ATT&CK mapping
- detection engineering (next phases)

---
