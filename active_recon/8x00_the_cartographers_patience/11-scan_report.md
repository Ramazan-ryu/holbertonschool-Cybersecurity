# Scan Report, Berent Industrial
Prepared by: Junior Penetration Tester, Ridgeline Security
For: Ridgeline engagement team
Date: 2026-07-04

## 1. Executive summary
This report details the external attack surface of the Berent Industrial network following a comprehensive, stealth-focused active reconnaissance engagement. The perimeter is guarded by a stateful firewall and an active Intrusion Detection System (IDS) configured with rate-limiting thresholds. However, critical misconfigurations in the firewall's stateless rule processing, coupled with predictable IP Identification behaviors on adjacent hosts, permitted extensive mapping of the internal topography. 

Through carefully calibrated evasion techniques, the engagement successfully mapped 8 live hosts and uncovered heavily filtered services, including database endpoints and TLS-wrapped mail daemons. The perimeter operates primarily on a default-deny policy with a targeted allowlist, but trusts traffic originating from specific source ports blindly. The intelligence gathered provides a highly confident, verified foundation for the subsequent exploitation and post-exploitation phases.

## 2. Host inventory
Initial host discovery faced aggressive ICMP filtering. Standard ICMP Echo requests failed to return accurate network topography. By deploying a blended discovery approach utilizing TCP SYN, TCP ACK, UDP probes, and alternative ICMP types (Timestamp and Address Mask requests), the following 8 hosts were confirmed live on the 10.10.10.0/24 subnet:

* **10.10.10.1:** Confirmed live via TCP ACK ping.
* **10.10.10.10:** Confirmed live via mixed TCP/ICMP discovery.
* **10.10.10.12:** Confirmed live via UDP ping.
* **10.10.10.15:** Confirmed live via TCP SYN ping.
* **10.10.10.20:** Confirmed live via TCP ACK ping.
* **10.10.10.30:** Confirmed live via mixed discovery probes.
* **10.10.10.37:** Confirmed live via TCP SYN ping.
* **10.10.10.50:** Confirmed live via mixed discovery probes; utilized as a zombie host.

## 3. Port and service inventory
No port state was accepted at face value from a single default scan. Every claim below has been verified through targeted probing and service versioning:

* **10.10.10.10 (Linux/5.X):**
    * 22/tcp (open) - OpenSSH/8.2p1 Ubuntu 4ubuntu0.5 (Verified via high-intensity version detection).
    * 80/tcp (open) - nginx/1.21.0 (Verified via high-intensity version detection and blind Idle Scan).
    * 3306/tcp (open) - mysql (Discovered behind firewall via fragmentation and source-port 53 spoofing).
* **10.10.10.12:**
    * 161/udp (open) - snmp (Verified via application-specific UDP payload matching).
* **10.10.10.15:**
    * 445/tcp (open) - microsoft-ds (Verified via decoy-obfuscated scan).
* **10.10.10.20:**
    * 8443/tcp (open) - https-alt (Verified via heavily delayed, sub-threshold paced scan).
* **Subnet Mail Host:**
    * Non-standard Port (open) - Postfix/3.5.6 (Verified via explicit TLS handshake and manual CRLF banner grab; standard Nmap detection failed due to implicit TLS wrapping).

## 4. Firewall behaviour
The perimeter firewall enforces a **default-deny-with-allowlist** policy for external traffic, augmented by naive stateless rules. 

An ACK scan against 10.10.10.10 revealed that standard web and management ports (22, 80, 443) return TCP RST packets, indicating they are `unfiltered` and the firewall explicitly allows this traffic to reach the host. Conversely, internal management ports like 445 (SMB) and 3389 (RDP) return no response (`filtered`), meaning the firewall silently drops the packets. 

Crucially, the firewall trusts traffic originating from source port 53 (DNS). A fragmented packet payload appearing to originate from port 53 successfully bypassed the filter to reach port 3306/tcp. This implies the next phase of the engagement can route malicious payloads through heavily filtered perimeter segments simply by manipulating the TCP source port and fragmenting the transmission.

## 5. Scan methodology
The engagement strictly adhered to a **Two-Phase Scan Strategy**:
* **Phase 1 (Broad Discovery):** A lightweight, mixed-protocol sweep (TCP SYN/ACK, UDP, varied ICMP) across the subnet to accurately map live assets without triggering alarms or crashing fragile IoT devices.
* **Phase 2 (Targeted Deep Scan):** Heavy, intrusive scans (version intensity, OS detection, and evasion techniques) were strictly pointed *only* at confirmed open ports on confirmed live hosts.

**Techniques Deployed:**
1.  **Discovery:** Bypassed ICMP blocks using `nmap -PE -PP -PM -PS22,80,443 -PA80,443 -PU53,161`.
2.  **State Determination:** Differentiated open/closed UDP ports from silently dropped packets using service-specific payloads (`-sU -sV`).
3.  **ACK Mapping:** Mapped firewall rulesets using naked ACK packets (`-sA`) to separate filtered from unfiltered ports.
4.  **Version Detection:** Forced complete signature matching against soft matches using maximum intensity (`-sV --version-all`).
5.  **Manual Banner Grabbing:** Bypassed automated scanner failures on implicit TLS ports by establishing the secure tunnel first (`openssl s_client -servername -crlf`).
6.  **Timing & Evasion:** Defeated the perimeter IDS rate-limiter by explicitly capping the probe rate beneath the detection threshold (`--max-rate 1 --scan-delay 1s`).
7.  **Source-Port Evasion:** Bypassed naive stateless rules using IP fragmentation (`-f`) and source port spoofing (`-g 53`).
8.  **Decoy Scanning:** Masked the true scanning IP by embedding it within a cluster of credible, live subnet IPs (`-D 10.10.10.1,10.10.10.12,ME,10.10.10.30`).
9.  **Idle Scan:** Achieved 100% source anonymity by exploiting the incremental IPID behavior of 10.10.10.50 (`-sI 10.10.10.50:80`).
10. **OS Detection:** Fingerprinted the TCP/IP stack behavior (Window size, MSS) using a combination of known open and closed ports (`-O --osscan-guess -p 22,80,9999`).

## 6. Confidence and limitations
**Confidence:** We possess high confidence in the enumerated service versions and the structural logic of the perimeter firewall. The verified bypass techniques (source-port manipulation and paced scanning) are robust and repeatable.

**Limitations:** * Deep UDP space was largely unexplored outside of standard management ports (161) due to the extreme time and stealth costs associated with thorough UDP scanning.
* The IDS threshold was measured on a single host (10.10.10.20); different subnet zones may employ different or adaptive alerting thresholds.
* Certain ports marked `closed` may simply be wrapped in port-knocking sequences or application-aware proxies not triggered by our methodologies.

## Appendix A: Task deliverables index
* `1-discovery.sh` - Broad host discovery bypassing standard ICMP.
* `2-udp.sh` - Payload-specific UDP port state determination.
* `3-firewall.sh` - ACK mapping for firewall policy deduction.
* `4-versions.sh` - High-intensity version detection.
* `5-banner.sh` - Explicit TLS banner grab via OpenSSL.
* `6-timing.sh` - Paced scan below IDS threshold.
* `7-evasion.sh` - Source-port and fragmentation firewall bypass.
* `8-decoy.sh` - Source IP obfuscation via live host clustering.
* `9-idlescan.sh` - Fully blind port state discovery via zombie IPID.
* `10-osdetect.sh` - TCP/IP stack fingerprinting against open/closed ports.
