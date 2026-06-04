# Containment Decision: IR-2026-0420-01

### Strategy A — Full Network Isolation
* action: Isolate all five hosts immediately via localized network access controls. Block all internal and external network traffic.
* effect on the attacker: Immediate loss of Cobalt Strike C2 access. Stops lateral movement and ransomware staging scripts.
* effect on patient care: Severe disruption to clinical systems, completely dropping access to crucial patient care documentation.
* evidence preserved: Full volatile memory states can be preserved if captured before isolation.
* evidence destroyed: Live network connection streams and real-time attacker session tracking.
* time to execute: 5–10 minutes.
* reversibility: Medium.

### Strategy B — Staged Micro-Segmentation (SELECTED STRATEGY)
* action: Deploy explicit outbound egress filtering at the perimeter firewall layer to block malicious domains while micro-segmenting targets.
* effect on the attacker: Severely disrupts active Cobalt Strike beacons and prevents execution of ransomware staging routines.
* effect on patient care: Moderate disruption. Critical clinical networks remain functional, and patient care systems maintain secure paths.
* evidence preserved: Volatile memory dumps, historical logging, and active process tree structures.
* evidence destroyed: Direct interactive attacker command shells.
* time to execute: 15–25 minutes.
* reversibility: High.

### Strategy C — Enhanced Monitoring and Delayed Action
* action: Allow all systems to remain operational with active packet capture and sinkholing without immediate system containment.
* effect on the attacker: Full operational freedom for the adversary, providing maximum threat intelligence collection options.
* effect on patient care: Minimal initial disruption, but carries an extreme threat of sudden enterprise-wide ransomware deployment.
* evidence preserved: Complete log of adversary behavior, methodologies, and raw interaction details.
* evidence destroyed: Massive risk of catastrophic encryption of all files across systems.
* time to execute: 5 minutes.
* reversibility: Low.

---

### Selection Summary and Trade-Off Rationale
The chosen strategy is Strategy B. This selection balances the intense clinical and forensic constraints of the operational environment. While full network isolation minimizes external communication instantly, it simultaneously drops medical data pathways, threatening real-time patient care. Strategy B cuts off the Cobalt Strike command channel and prevents automated ransomware execution while offering clean environments to secure forensic images without causing medical operational blackouts.

* chosen strategy: Strategy B — Staged Micro-Segmentation
* authorizing role: Incident Commander / Lead On-Call
* rollback trigger: High failure rates on medical database queries or immediate threat to patient care safety thresholds.
