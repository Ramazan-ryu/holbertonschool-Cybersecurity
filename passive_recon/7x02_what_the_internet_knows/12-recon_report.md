# Competitive Footprinting Report, Synchrohouse Limited
For: Synchrohouse CISO and Business Leadership

## 1. Executive summary
This report provides a comparative footprinting and passive reconnaissance assessment of three competitor estates: Cerebra, Yume, and Verdant. The objective is to evaluate their external attack surfaces, identify their operational security maturity, and provide actionable intelligence for Synchrohouse's own defensive strategy. 

The assessment reveals a stark contrast in security postures. Cerebra represents a catastrophic security failure, with active Command and Control (C2) callbacks indicating a severe, ongoing infrastructure compromise. Yume demonstrates transitional maturity; while they are actively adopting modern security practices (e.g., secret managers), historical negligence has left critical API keys exposed in public repositories. Verdant maintains the most resilient posture, though minor configuration flaws allow for the discovery of internal administrative portals. Synchrohouse must leverage these findings to harden external perimeters, enforce strict repository sanitization, and deploy aggressive outbound traffic monitoring.

## 2. Per-estate profile

### Cerebra
* **Exposure Surface:** Highly porous and actively compromised. Cerebra's perimeter lacks basic access controls, exposing critical source code and internal naming conventions.
* **Notable Findings:** * Exposed `.git` directories leading to the mapping of employee email structures (`firstname.lastname@cerebra.lab`).
  * Personnel credentials discovered in recent public dumps (CloudLeak 2023).
  * **Critical:** IP address `127.22.0.10` has a threat reputation score of 9, with active C2 callbacks observed.
* **Apparent Maturity:** Extremely low. The presence of active malware beacons on their primary infrastructure indicates a complete failure of both preventative controls and continuous monitoring.

### Yume
* **Exposure Surface:** Moderate, characterized by historical technical debt. 
* **Notable Findings:**
  * Exposed repository history reveals sensitive infrastructure configurations.
  * Identification of the IT Lead (Kenji Tanaka) via Git commit history.
  * A hardcoded production secret (`YBS_API_KEY=0fee859d835814a2a2da8ec62d348a34`) was committed, then improperly deleted, leaving it accessible in the Git log (`deploy.env`).
* **Apparent Maturity:** Developing. Commit logs indicate a recent migration to centralized secret managers. However, their failure to rotate keys or rewrite Git history shows a lack of deep incident response understanding.

### Verdant
* **Exposure Surface:** Minimal and controlled. 
* **Notable Findings:**
  * Powered by VerdantCMS/3.4.1.
  * Predictable directory structures and JavaScript variables (e.g., `var API_BASE = "/api/v1";`) leaked internal portal paths and build tokens (`ad03e090d9748f1ddac337bff23c9494`).
* **Apparent Maturity:** High. While minor information disclosure exists, Verdant successfully obfuscates its most critical assets and does not leak high-impact secrets or show signs of active compromise.

## 3. Comparative analysis
Using an "External Attack Surface Risk Score" metric (weighing repository leaks, credential breaches, and infrastructure health), the estates rank as follows:

1. **Verdant (Low Risk):** Demonstrates strong perimeter hygiene. Their primary weakness is "security through obscurity" regarding administrative portals.
2. **Yume (Medium Risk):** Their current infrastructure may be secure, but their exposed historical supply-chain secrets provide threat actors with easy pivot points into their environments.
3. **Cerebra (Critical Risk):** The presence of C2 traffic means Cerebra is no longer just exposed; it is actively breached. 

**Differentiation:** Verdant is the only competitor practicing effective defense-in-depth. Cerebra is failing at the network level, while Yume is failing at the DevOps/Application level.

## 4. Recommendations for Synchrohouse
* **Who to Fear:** Verdant. Their strong operational security implies a highly competent IT and development team that likely translates to resilient business operations.
* **Who to Emulate:** Emulate Yume's initiative to adopt Secret Managers, but execute it correctly. If Synchrohouse discovers hardcoded secrets, the policy must dictate immediate cryptographic revocation, not just file deletion.
* **What to Harden:** * **Egress Monitoring:** Cerebra's downfall is active C2 callbacks. Synchrohouse must implement strict outbound firewall rules and DNS monitoring to detect malware beaconing.
  * **Git Hygiene:** Implement pre-commit hooks (like TruffleHog or GitLeaks) to ensure API keys and credentials are never pushed to public-facing or easily exposed repositories.
  * **Web Configuration:** Ensure `robots.txt` and `sitemap.xml` are not inadvertently advertising internal staging or administrative endpoints, as seen in Verdant.

## 5. Methodology
The following passive reconnaissance techniques were utilized to gather intelligence without generating actionable alerts on the target infrastructure:
* **Infrastructure Fingerprinting:** `whatweb` and `curl -I` were used to parse HTTP headers and identify CMS versions (VerdantCMS).
* **Content Discovery:** `gobuster dir` was utilized alongside targeted wordlists to map unlinked application paths (`/portal-internal/`, `/api/v1/`).
* **Source Code Analysis:** `git-dumper` was used to clone exposed `.git` directories. `git log -p` was utilized to track author metadata and extract deleted API keys.
* **Threat Correlation:** Bash utilities (`grep`, `cat`) were used to cross-reference discovered assets (emails, IPs) against locally provided threat intelligence and breach corpora (`breaches.txt`, `reputation.csv`).

## 6. Limitations and uncertainty
* **Passive Restrictions:** Because this assessment relied purely on passive and semi-passive footprinting, we cannot confirm if the exposed Yume `YBS_API_KEY` is still cryptographically valid. Active authentication attempts would cross the boundary into active exploitation.
* **Depth of Compromise:** We can infer that Cerebra is compromised due to C2 traffic on `127.22.0.10`, but passive recon cannot determine if the threat actor has achieved lateral movement or data exfiltration.
* **Inferences vs. Facts:** It is a confirmed fact that Marie Dubois was in the CloudLeak 2023 breach. It is an inference that Cerebra's current password policies are weak; we assume risk based on the breach, but cannot confirm internal Active Directory policies.
