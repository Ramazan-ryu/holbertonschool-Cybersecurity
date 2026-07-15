# Scan Report, Berent Industrial
Prepared by: Junior Penetration Tester, Ridgeline Security
For: Ridgeline engagement team
Date: 2026-07-04

## 1. Executive summary
This report details the external attack surface of the Berent Industrial network following a comprehensive, stealth-focused active reconnaissance engagement. The objective was to map the network topography, identify exposed services, deduce perimeter defense logic, and provide a verified foundation for subsequent exploitation phases without triggering reactive isolation from the target's Intrusion Detection Systems (IDS).

The Berent perimeter is guarded by a stateful firewall and an active IDS configured with strict rate-limiting thresholds. However, critical misconfigurations in the firewall's stateless rule processing, coupled with predictable IP Identification behaviors on adjacent hosts, permitted extensive mapping of the internal topography. Through carefully calibrated evasion techniques—including IP fragmentation, source-port manipulation, and precise timing delays—the engagement successfully mapped 8 live hosts and uncovered heavily filtered, high-value services, including database endpoints and TLS-wrapped mail daemons. The intelligence gathered provides a highly confident, rigorously verified map of the network.

## 2. Host inventory
Initial host discovery faced aggressive ICMP filtering at the perimeter. Relying on default ICMP Echo requests failed entirely to return an accurate picture of the network topography. To overcome this, a blended discovery approach utilizing TCP SYN, TCP ACK, UDP probes, and alternative ICMP types (Timestamp and Address Mask requests) was deployed. 

**Crucially, the following hosts were explicitly missed by default ICMP discovery and were only revealed through alternative protocol probing:**
* **10.10.10.1:** Hidden from default ICMP; confirmed live via TCP ACK ping.
* **10.10.10.12:** Hidden from default ICMP; confirmed live via UDP ping targeting port 161.
* **10.10.10.15:** Hidden from default ICMP; confirmed live via TCP SYN ping.
* **10.10.10.20:** Hidden from default ICMP; confirmed live via TCP ACK ping.
* **10.10.10.37:** Hidden from default ICMP; confirmed live via TCP SYN ping.

The following hosts were also confirmed live, resulting in a total of 8 identified assets on the 10.10.10.0/24 subnet:
* **10.10.10.10:** Confirmed live via mixed TCP/ICMP discovery.
* **10.10.10.30:** Confirmed live via mixed discovery probes.
* **10.10.10.50:** Confirmed live via mixed discovery probes; later utilized as an idle-scan zombie host due to its incremental IPID allocation.

## 3. Port and service inventory
No port state was accepted at face value from a single default scan. Distinguishing between confirmed open, closed, filtered, and ambiguous findings was paramount. Every claim below has been rigorously verified through targeted corroborating techniques:

* **10.10.10.10 (Linux 5.X):**
    * **22/tcp (Confirmed Open):** OpenSSH 8.2p1 Ubuntu 4ubuntu0.5. Verified via refined, high-intensity version detection.
    * **80/tcp (Confirmed Open):** nginx 1.21.0. Verified via refined version detection and corroborated via a blind Idle Scan.
    * **3306/tcp (Confirmed Open):** mysql. Initially appeared filtered/ambiguous; discovered behind the firewall via fragmentation and source-port 53 spoofing.
    * **9999/tcp (Confirmed Closed):** Verified via OS detection fingerprinting requiring a closed port baseline.
* **10.10.10.12:**
    * **161/udp (Confirmed Open):** snmp. Verified via application-specific UDP payload matching to distinguish from a silently filtered state.
* **10.10.10.15:**
    * **445/tcp (Confirmed Open):** microsoft-ds. Verified via decoy-obfuscated scanning to bypass source-based logging.
* **10.10.10.20:**
    * **8443/tcp (Confirmed Open):** https-alt. Verified via a heavily delayed, sub-threshold paced scan to bypass IDS rate limiting.
* **Subnet Mail Host (Non-standard Port):**
    * **Non-standard Port (Confirmed Open):** Postfix 3.5.6. Standard automated Nmap version detection returned an ambiguous "ssl/unknown" finding. The exact service version was verified via a TLS-aware manual banner grab using `openssl s_client` to negotiate the implicit TLS wrapper before passing CRLF line endings.

## 4. Firewall behaviour
Based on the evidence gathered via ACK scanning, the perimeter firewall enforces a **default-deny-with-allowlist** policy for external traffic, augmented by naive stateless rules.

An ACK scan against 10.10.10.10 revealed that standard web and management ports (22, 80, 443) return TCP RST packets. This indicates they are `unfiltered` and the firewall explicitly allows this traffic to reach the host. Conversely, internal management ports like 445 (SMB) and 3389 (RDP) return no response. This silent drop indicates they are strictly `filtered`.

**Important Limitation of ACK Evidence:** It must be stated plainly that an ACK scan structurally cannot tell you whether a port is genuinely open or closed. Because it only evaluates firewall responses, it merely distinguishes *filtered* (dropped) from *unfiltered* (passed).

Crucially, the firewall blindly trusts traffic appearing to originate from source port 53 (DNS). A fragmented packet payload spoofing source port 53 successfully bypassed the filter to reach port 3306/tcp. This implies the next phase of the engagement can route malicious payloads through heavily filtered perimeter segments simply by manipulating the TCP source port and fragmenting the transmission to defeat stateless inspection.

## 5. Scan methodology
The engagement was strictly governed by a **Two-Phase Scan Strategy**: broad discovery followed by targeted deep scanning. By first mapping live hosts silently and only pointing heavy, intrusive probes at confirmed open ports, we maintained a stealthy profile. This phased approach is fundamentally safer and more accurate than a flat, aggressive sweep (e.g., `nmap -A` across a /24), which generates overwhelming log noise, risks crashing fragile IoT devices, and practically guarantees an IDS ban.

**Techniques Documented:**
1. **Discovery:** Bypassed aggressive ICMP blocking using a mixed array of probes (`-PE -PP -PM -PS -PA -PU`) to force responses from stealthy hosts.
2. **State Determination:** Differentiated genuinely open UDP ports from silently filtered ones by sending protocol-specific payloads rather than empty packets (`-sU -sV`).
3. **ACK Mapping:** Read the firewall's access control lists by bouncing naked ACK packets off the target to map the `filtered` vs `unfiltered` boundaries (`-sA`).
4. **Version Detection:** Refined soft matches by pushing detection intensity to maximum (`--version-all`), forcing the daemon to reveal its exact software token.
5. **Manual Banner Grabbing:** Bypassed automated scanner failures on wrapped services by manually establishing a secure tunnel (`openssl s_client -servername -crlf`).
6. **Timing Restrictions:** Defeated perimeter IDS packet-counting algorithms by explicitly capping the scan rate well beneath the detection threshold (`--max-rate 1 --scan-delay 1s`).
7. **Source-Port & Fragmentation Evasion:** Defeated naive firewall rules by fragmenting TCP headers (`-f`) and masquerading as returning DNS traffic (`-g 53`).
8. **Decoy Scanning:** Masked the true origin of the probes by hiding the scanner's IP amongst a cluster of credible, live subnet IPs (`-D`).
9. **Idle Scanning:** Achieved absolute source anonymity by bouncing probes off a genuinely idle zombie host (10.10.10.50), reading the target's port state purely from the perturbation of the zombie's incremental IPID counter (`-sI`).
10. **OS Detection:** Fingerprinted the target's TCP/IP stack (analyzing window sizes, options, and MSS) by bouncing probes off a combination of confirmed open and explicitly closed ports to generate a probability-weighted match (`-O --osscan-guess`).

## 6. Confidence and limitations
**Confidence:** We possess high confidence in the enumerated service versions, the host inventory, and the structural logic of the perimeter firewall. The findings clearly distinguish between confirmed open ports and filtered drops. The evasion vectors (source-port manipulation and sub-threshold paced scanning) have been practically verified and are ready for the exploitation team.

**Limitations:** While the external-facing attack surface is heavily mapped, certain elements remain uncertain or hidden from this methodology:
* Deep UDP space remains largely unmapped. Only targeted management ports (161) were confirmed due to the extreme time-cost and unreliability of exhaustive UDP scanning.
* The IDS rate-limiting threshold was calibrated against a specific segment; other internal enclaves may employ distinct or adaptive thresholds.
* Ambiguous ports that appear `filtered` may actually be hiding services behind application-aware proxies or port-knocking sequences that our current probes did not trigger.

## Appendix A: Task deliverables index
The following raw scripts were utilized to generate the findings in this report:
* **1-discovery.sh:** Broad host discovery bypassing default ICMP blocks.
* **2-udp.sh:** Payload-specific UDP port state determination.
* **3-firewall.sh:** ACK mapping for firewall policy deduction.
* **4-versions.sh:** Refined, high-intensity version detection.
* **5-banner.sh:** TLS-aware manual banner grab.
* **6-timing.sh:** Paced scanning below the IDS rate threshold.
* **7-evasion.sh:** Source-port and fragmentation firewall bypass.
* **8-decoy.sh:** Obfuscated scanning via live host decoys.
* **9-idlescan.sh:** Fully blind state discovery utilizing an IPID zombie.
* **10-osdetect.sh:** Target TCP/IP stack fingerprinting.
