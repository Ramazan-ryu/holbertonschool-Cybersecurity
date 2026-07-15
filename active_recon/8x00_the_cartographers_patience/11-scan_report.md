# Scan Report, Berent Industrial
**Prepared by:** Junior Penetration Tester, Ridgeline Security  
**For:** Ridgeline Engagement Team  
**Date:** 2026-07-04  
**Document Classification:** CONFIDENTIAL  

---

## 1. Executive summary

### 1.1 Scope and Objective
This document outlines the findings of a comprehensive, stealth-focused active reconnaissance engagement conducted against the external attack surface of the Berent Industrial network. The primary objective of this phase was to map the network topography, identify exposed services, deduce the underlying perimeter defense logic, and provide a verified, high-confidence foundation for subsequent exploitation phases. All reconnaissance was conducted under strict operational security constraints, explicitly designed to avoid triggering reactive isolation from the target's active Intrusion Detection Systems (IDS).

### 1.2 High-Level Findings
The Berent perimeter is heavily guarded by a stateful firewall and an IDS configured with strict rate-limiting thresholds. Initial analysis suggested a hardened perimeter; however, critical misconfigurations in the firewall's stateless rule processing, coupled with predictable IP Identification (IPID) behaviors on adjacent internal hosts, permitted extensive mapping of the internal topography. 

Through carefully calibrated evasion techniques—including IP fragmentation, source-port manipulation, and precise timing delays—the engagement successfully mapped 8 live hosts on the target subnet. We uncovered heavily filtered, high-value services, including critical database endpoints and TLS-wrapped mail daemons that automated scanners failed to identify. 

### 1.3 Business Impact and Security Posture
The perimeter operates primarily on a **default-deny with allowlist** policy, which is industry standard. However, the firewall blindly trusts traffic originating from specific source ports (namely DNS/53). This structural flaw effectively neutralizes the firewall's protection against skilled adversaries, as malicious payloads can be routed through heavily filtered perimeter segments simply by manipulating the TCP source port and fragmenting the transmission. The intelligence gathered in this report provides a rigorously verified map of the network, highlighting critical exposures that the exploitation team can immediately leverage.

---

## 2. Host inventory

### 2.1 The Challenge of ICMP Filtering
Initial host discovery faced aggressive ICMP filtering at the perimeter. Relying on default ICMP Echo requests (ping) failed entirely to return an accurate picture of the network topography. Modern networks frequently drop ICMP to mask their presence, necessitating a protocol-agnostic approach. To overcome this, a blended discovery approach utilizing TCP SYN, TCP ACK, UDP probes, and alternative ICMP types (Timestamp and Address Mask requests) was deployed.

### 2.2 Live Host Identification and Evidence
Crucially, the following hosts were explicitly missed by default ICMP discovery and were only revealed through alternative protocol probing. These represent hidden assets that a standard automated sweep would completely overlook:

| IP Address | Discovery Status | Evidence & Technique Used |
| :--- | :--- | :--- |
| **10.10.10.1** | Hidden from default ICMP | Confirmed live via TCP ACK ping. The host responded to out-of-state packets, revealing its presence despite ICMP drops. |
| **10.10.10.12** | Hidden from default ICMP | Confirmed live via UDP ping targeting port 161. The host processed the UDP datagram and responded, bypassing TCP/ICMP filters. |
| **10.10.10.15** | Hidden from default ICMP | Confirmed live via TCP SYN ping. The host responded with a SYN/ACK to a specific port probe. |
| **10.10.10.20** | Hidden from default ICMP | Confirmed live via TCP ACK ping. Bypassed stateless blocks looking only for initial SYN packets. |
| **10.10.10.37** | Hidden from default ICMP | Confirmed live via TCP SYN ping. |

The following hosts were also confirmed live, resulting in a total of 8 identified assets on the 10.10.10.0/24 subnet:

| IP Address | Discovery Status | Evidence & Technique Used |
| :--- | :--- | :--- |
| **10.10.10.10** | Confirmed Live | Confirmed live via mixed TCP/ICMP discovery. |
| **10.10.10.30** | Confirmed Live | Confirmed live via mixed discovery probes. |
| **10.10.10.50** | Confirmed Live | Confirmed live via mixed discovery probes; later utilized as an idle-scan zombie host due to its incremental IPID allocation. |

---

## 3. Port and service inventory

No port state was accepted at face value from a single default scan. Distinguishing between confirmed open, closed, filtered, and ambiguous findings was paramount to ensuring the integrity of this intelligence. Every claim below has been rigorously verified through targeted corroborating techniques to eliminate false positives.

### 3.1 Detailed Service Mapping

**Target: 10.10.10.10 (Operating System: Linux 5.X)**
* **22/tcp (Confirmed Open):** `OpenSSH 8.2p1 Ubuntu 4ubuntu0.5`. Verified via refined, high-intensity version detection. This represents a potential administrative entry point if credentials can be sourced.
* **80/tcp (Confirmed Open):** `nginx 1.21.0`. Verified via refined version detection and corroborated via a completely blind Idle Scan to ensure the state was accurate without alerting the host directly.
* **3306/tcp (Confirmed Open):** `mysql`. Initially appeared filtered/ambiguous to standard scans. It was discovered hiding behind the firewall via IP fragmentation and source-port 53 spoofing. This is a critical high-value target for the data exfiltration team.
* **9999/tcp (Confirmed Closed):** Verified via OS detection fingerprinting requiring a closed port baseline.

**Target: 10.10.10.12**
* **161/udp (Confirmed Open):** `snmp`. Verified via application-specific UDP payload matching to distinguish from a silently filtered state. SNMP often leaks vast amounts of internal network routing data and should be queried in the next phase.

**Target: 10.10.10.15**
* **445/tcp (Confirmed Open):** `microsoft-ds`. Verified via decoy-obfuscated scanning to bypass source-based logging. The exposure of SMB to the external network is a critical misconfiguration.

**Target: 10.10.10.20**
* **8443/tcp (Confirmed Open):** `https-alt`. Verified via a heavily delayed, sub-threshold paced scan to bypass IDS rate limiting. 

**Target: Subnet Mail Host (Non-standard Port)**
* **Non-standard Port (Confirmed Open):** `Postfix 3.5.6`. Standard automated Nmap version detection returned an ambiguous `ssl/unknown` finding because the service expects a TLS handshake before presenting an application banner. The exact service version was verified via a TLS-aware manual banner grab using `openssl s_client` to negotiate the implicit TLS wrapper before passing CRLF line endings.

---

## 4. Firewall behaviour

### 4.1 Policy Deduction and Rule Mapping
Based on the evidence gathered via extensive ACK scanning, the perimeter firewall enforces a **default-deny-with-allowlist** policy for external traffic, augmented by poorly implemented stateless rules.

An ACK scan against 10.10.10.10 revealed that standard web and management ports (22, 80, 443) return TCP RST packets. According to TCP RFCs, a host receiving an out-of-state ACK will reply with an RST. Because we received these RSTs, this indicates the ports are `unfiltered` and the firewall explicitly allows this traffic to reach the host. 

Conversely, internal management ports like 445 (SMB) and 3389 (RDP) return no response whatsoever. This silent drop indicates they are strictly `filtered` by the perimeter device.

**Important Limitation of ACK Evidence:** It must be stated plainly that an ACK scan structurally cannot tell you whether a port is genuinely open or closed. Because it only evaluates firewall responses, it merely distinguishes *filtered* (dropped) from *unfiltered* (passed). The true state of the port must be corroborated by subsequent application-layer probes.

### 4.2 Exploitable Misconfigurations
Crucially, the firewall blindly trusts traffic appearing to originate from source port 53 (DNS). A fragmented packet payload spoofing source port 53 successfully bypassed the filter to reach port 3306/tcp. This implies the next phase of the engagement can route malicious payloads through heavily filtered perimeter segments simply by manipulating the TCP source port and fragmenting the transmission to defeat stateless inspection engines.

---

## 5. Scan methodology

### 5.1 The Two-Phase Scan Strategy
The engagement was strictly governed by a **Two-Phase Scan Strategy**: broad discovery followed by targeted deep scanning. 

1.  **Phase 1 (Broad Discovery):** We first mapped live hosts silently using lightweight, mixed-protocol sweeps to accurately map assets without triggering alarms or crashing fragile IoT devices.
2.  **Phase 2 (Targeted Deep Scanning):** We only pointed heavy, intrusive probes (like OS detection and version intensity) at *confirmed open ports* on *confirmed live hosts*.

This phased approach is fundamentally safer and more accurate than a flat, aggressive sweep (e.g., running `nmap -A` across a /24 subnet). A flat aggressive sweep generates overwhelming log noise, risks crashing fragile legacy devices by throwing heavy scripts at unverified services, and practically guarantees a reactive ban from the IDS.

### 5.2 Technical Execution of Reconnaissance
The following techniques were methodically applied to map the Berent network:

1.  **Discovery:** Bypassed aggressive ICMP blocking using a mixed array of probes (`-PE -PP -PM -PS -PA -PU`) to force responses from stealthy hosts based on varied protocol RFC compliance.
2.  **State Determination:** Differentiated genuinely open UDP ports from silently filtered ones by sending protocol-specific payloads rather than empty packets (`-sU -sV`), forcing the application to respond.
3.  **ACK Mapping:** Read the firewall's access control lists by bouncing naked ACK packets off the target to map the `filtered` vs `unfiltered` boundaries (`-sA`), revealing the perimeter policy.
4.  **Version Detection:** Refined soft matches by pushing detection intensity to maximum (`--version-all`), forcing the daemon to process all known Nmap probes and reveal its exact software token.
5.  **Manual Banner Grabbing:** Bypassed automated scanner failures on wrapped services by manually establishing a secure tunnel (`openssl s_client -servername -crlf`) to read the daemon's raw output.
6.  **Timing Restrictions:** Defeated perimeter IDS packet-counting algorithms by explicitly capping the scan rate well beneath the detection threshold (`--max-rate 1 --scan-delay 1s`), trading time for stealth.
7.  **Source-Port & Fragmentation Evasion:** Defeated naive firewall rules by fragmenting TCP headers (`-f`) into 8-byte chunks and masquerading as returning DNS traffic (`-g 53`).
8.  **Decoy Scanning:** Masked the true origin of the probes by hiding the scanner's IP amongst a cluster of credible, live subnet IPs (`-D`), polluting the IDS logs and making attribution mathematically difficult.
9.  **Idle Scanning:** Achieved absolute source anonymity by bouncing probes off a genuinely idle zombie host (10.10.10.50), reading the target's port state purely from the perturbation of the zombie's incremental IPID counter (`-sI`).
10. **OS Detection:** Fingerprinted the target's TCP/IP stack (analyzing window sizes, options, and MSS) by bouncing probes off a combination of confirmed open and explicitly closed ports to generate a probability-weighted match (`-O --osscan-guess`).

---

## 6. Confidence and limitations

### 6.1 Confidence in Findings
We possess high confidence in the enumerated service versions, the host inventory, and the structural logic of the perimeter firewall. The findings clearly distinguish between confirmed open ports and filtered drops. The evasion vectors (source-port manipulation and sub-threshold paced scanning) have been practically verified against the target infrastructure and are ready for the exploitation team to utilize immediately.

### 6.2 Limitations and Residual Uncertainty
While the external-facing attack surface is heavily mapped, certain elements remain uncertain or hidden from this methodology:
* **UDP Topography:** Deep UDP space remains largely unmapped. Only targeted management ports (such as 161) were confirmed open due to the extreme time-cost, unreliability, and noise generation of exhaustive 65k UDP port scanning.
* **Adaptive IDS Behavior:** The IDS rate-limiting threshold was calibrated against a specific network segment; other internal enclaves or distinct subnet zones may employ different or adaptive thresholds that could still trap rapid exploitation attempts.
* **Advanced Obfuscation:** Ambiguous ports that appear strictly `filtered` may actually be hiding services behind application-aware proxies or port-knocking sequences that our current baseline probes were not designed to trigger.

---

## Appendix A: Task deliverables index

The methodology detailed in Section 5 was executed using the following repeatable task scripts. These scripts correlate directly to the findings documented in this report:

* **`1-discovery.sh`:** Broad host discovery bypassing default ICMP blocks.
* **`2-udp.sh`:** Payload-specific UDP port state determination.
* **`3-firewall.sh`:** ACK mapping for firewall policy deduction.
* **`4-versions.sh`:** Refined, high-intensity version detection against specific ports.
* **`5-banner.sh`:** TLS-aware manual banner grab for implicitly wrapped services.
* **`6-timing.sh`:** Paced scanning below the IDS rate threshold to avoid alerting.
* **`7-evasion.sh`:** Source-port and fragmentation firewall bypass execution.
* **`8-decoy.sh`:** Obfuscated scanning via live host decoys to pollute target logs.
* **`9-idlescan.sh`:** Fully blind state discovery utilizing an IPID zombie.
* **`10-osdetect.sh`:** Target TCP/IP stack fingerprinting against open/closed port baselines.
