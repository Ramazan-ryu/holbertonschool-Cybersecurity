# Scan Report, Berent Industrial
Prepared by: Junior Penetration Tester, Ridgeline Security
For: Ridgeline engagement team
Date: 2026-07-04

## 1. Executive summary
This report details the external attack surface of the Berent Industrial network following a comprehensive, stealth-focused active reconnaissance engagement. The objective of this phase was to map the network topography, identify exposed services, and deduce perimeter firewall rulesets without alerting Berent's Intrusion Detection Systems (IDS). 

The perimeter is guarded by a stateful firewall and an active IDS configured with strict rate-limiting thresholds. However, critical misconfigurations in the firewall's stateless rule processing, coupled with predictable IP Identification behaviors on adjacent hosts, permitted extensive mapping of the internal topography. Through carefully calibrated evasion techniques, the engagement successfully mapped 8 live hosts and uncovered heavily filtered services, including database endpoints and TLS-wrapped mail daemons. The intelligence gathered provides a highly confident, verified foundation for the subsequent exploitation and post-exploitation phases conducted by the Ridgeline engagement team.

## 2. Host inventory
Initial host discovery faced aggressive ICMP filtering at the perimeter. A standard default ICMP Echo request (ping) sweep yielded an incomplete picture of the network, missing the majority of the active surface. 

To overcome this, a blended discovery approach utilizing TCP SYN, TCP ACK, UDP probes, and alternative ICMP types (Timestamp and Address Mask requests) was deployed. Crucially, the following hosts were **completely missed by default ICMP discovery** (ICMP-hidden) and were only revealed by these advanced techniques:
* **10.10.10.1:** Missed by ICMP; confirmed live via TCP ACK ping.
* **10.10.10.12:** Missed by ICMP; confirmed live via UDP ping.
* **10.10.10.15:** Missed by ICMP; confirmed live via TCP SYN ping.
* **10.10.10.20:** Missed by ICMP; confirmed live via TCP ACK ping.
* **10.10.10.37:** Missed by ICMP; confirmed live via TCP SYN ping.

The remaining hosts responded to standard or mixed probes and complete the 8-host inventory:
* **10.10.10.10:** Confirmed live via mixed TCP/ICMP discovery.
* **10.10.10.30:** Confirmed live via mixed discovery probes.
* **10.10.10.50:** Confirmed live via mixed discovery probes; ultimately utilized as a predictable zombie host for idle scanning.

## 3. Port and service inventory
No port state was accepted at face value from a single default scan. We explicitly distinguish between confirmed open, closed, filtered, and ambiguous states. Every open port claim below has been verified through targeted corroborating techniques:

* **10.10.10.10 (OS: Linux 5.X):**
    * **22/tcp (Confirmed Open):** OpenSSH 8.2p1 Ubuntu 4ubuntu0.5. Verified via refined, high-intensity version detection.
    * **80/tcp (Confirmed Open):** nginx 1.21.0. Verified via high-intensity version detection and corroborated via a blind Idle Scan.
    * **3306/tcp (Confirmed Open):** mysql. Discovered hiding behind the firewall via fragmentation and source-port 53 spoofing evasion.
    * **445/tcp, 3389/tcp (Filtered):** Dropped silently by the firewall.
    * **9999/tcp (Confirmed Closed):** Used as the closed-port baseline to accurately calculate the OS detection fingerprint.
* **10.10.10.12:**
    * **161/udp (Confirmed Open):** snmp. Initially ambiguous (open|filtered), but definitively verified via application-specific SNMP UDP payload matching to elicit a response.
* **10.10.10.15:**
    * **445/tcp (Confirmed Open):** microsoft-ds. Verified via a decoy-obfuscated scan that masked the true origin IP.
* **10.10.10.20:**
    * **8443/tcp (Confirmed Open):** https-alt. Verified via a heavily delayed, sub-threshold paced scan that evaded the IDS block.
* **Subnet Mail Host (Non-standard port):**
    * **Non-standard Port (Confirmed Open):** Postfix 3.5.6. Automated version detection failed due to implicit TLS wrapping. Verified by negotiating an explicit TLS handshake via OpenSSL and executing a protocol-correct CRLF manual banner grab.

## 4. Firewall behaviour
Based on the pattern of ACK-scan responses across 10.10.10.10's known ports, we deduce that the perimeter firewall operates on a **default-deny-with-allowlist** policy, augmented by naive stateless rules.

An ACK scan against 10.10.10.10 revealed that standard web and management ports (22, 80, 443) return TCP RST packets. This indicates they are `unfiltered` and the firewall explicitly allows this traffic (the allowlist). Conversely, internal management ports like 445 (SMB) and 3389 (RDP) return no response, meaning they are `filtered` and the firewall silently drops the packets (the default deny).

**What ACK scanning structurally cannot reveal:** It is vital to note that an ACK scan structurally cannot tell you if a port is genuinely *open* or *closed* behind the firewall. It only reveals if the path is *filtered* or *unfiltered*. We had to pair the ACK mapping with subsequent deep scans to confirm the actual port states.

Crucially, the firewall trusts traffic originating from source port 53 (DNS). A fragmented packet payload appearing to originate from port 53 successfully bypassed the filter to reach port 3306/tcp. **Implications:** The next phase of the engagement can route malicious payloads through heavily filtered perimeter segments simply by manipulating the TCP source port and fragmenting the transmission.

## 5. Scan methodology
The engagement was strictly governed by a **Two-Phase Scan Strategy**. 
1. **Broad Discovery:** We first ran a lightweight, mixed-protocol sweep across the subnet to map live assets. 
2. **Targeted Deep Scanning:** We then pointed heavy, intrusive scans only at confirmed live hosts and open ports. 
*Why this is superior:* This approach is vastly safer and more accurate than a flat, aggressive sweep (e.g., `nmap -A`). A flat sweep blasts every port with heavy scripts, which triggers IDS alarms, locks out the scanner, and frequently crashes fragile industrial/IoT devices, ruining the accuracy of the map.

**Reproducible Techniques Deployed:**
* **Discovery:** Bypassed ICMP blocks using `nmap -PE -PP -PM -PS22,80,443 -PA80,443 -PU53,161`.
* **State Determination:** Differentiated open UDP ports from filtered ones by sending specific protocol payloads (`nmap -sU -sV`).
* **ACK Mapping:** Read the firewall allowlist by sending naked ACK packets (`nmap -sA -p 22,80,443,445,3389`) to observe RST vs. Dropped behaviors.
* **Version Detection:** Forced exhaustive signature matching against soft matches using maximum intensity (`nmap -sV --version-all`).
* **Manual Banner Grabbing:** Bypassed implicit TLS wrappers by establishing the secure tunnel prior to the application query (`openssl s_client -servername <IP> -crlf -quiet`).
* **Timing / Pacing:** Defeated the perimeter IDS rate-limiter by explicitly capping the probe rate beneath the detection threshold (`nmap --max-rate 1 -T3`).
* **Source-Port & Fragmentation Evasion:** Defeated naive stateless rules by breaking headers into 8-byte chunks and spoofing DNS return traffic (`nmap -f -g 53 -sV`).
* **Decoy Scanning:** Masked the true scanning IP by embedding it within a cluster of credible, live subnet IPs (`nmap -D 10.10.10.1,10.10.10.12,ME,10.10.10.30`).
* **Idle Scanning:** Achieved absolute source anonymity by exploiting the incremental IPID sequence of a silent adjacent host (`nmap -sI 10.10.10.50:80`).
* **OS Detection:** Fingerprinted the TCP/IP stack (initial window size, options, MSS) by explicitly targeting a known open port (80) and a known closed port (9999) to ensure high-fidelity weighted matches (`nmap -O --osscan-guess -p 22,80,9999`).

## 6. Confidence and limitations
**Confidence (Confirmed Findings):** We possess high confidence in the enumerated service versions (e.g., Postfix, OpenSSH, nginx) as they were verified via application-layer interaction. The structural logic of the perimeter firewall (default-deny with allowlist) is definitively confirmed via ACK mapping. The evasion vectors (source-port 53 and timing caps) are highly reliable and reproducible for the exploit team.

**Limitations (Uncertain/Hidden Findings):** * The deep UDP space remains largely uncertain. Outside of standard management ports (161), aggressive UDP scanning was omitted due to the extreme time and stealth costs. Services hiding on high UDP ports may remain hidden.
* The IDS threshold was measured and bypassed on a single host (10.10.10.20); different subnet zones may employ adaptive or stricter alerting thresholds.
* Ambiguous or `closed` ports may in fact be open but shielded by application-aware proxies, strict IP-whitelisting, or port-knocking sequences that our current methodology would not trigger.

## Appendix A: Task deliverables index
This section indexes the raw scripts utilized to generate the findings within this report:
* **`1-discovery.sh`**: Broad host discovery bypassing standard ICMP; revealed the 8 host inventory.
* **`2-udp.sh`**: Payload-specific UDP port state determination; verified SNMP on 10.10.10.12.
* **`3-firewall.sh`**: ACK mapping; deduced the default-deny-with-allowlist firewall policy.
* **`4-versions.sh`**: High-intensity version detection; extracted OpenSSH/nginx tokens.
* **`5-banner.sh`**: Explicit TLS manual banner grab; extracted the Postfix version.
* **`6-timing.sh`**: Paced scan below IDS threshold; revealed 8443 on 10.10.10.20.
* **`7-evasion.sh`**: Source-port and fragmentation bypass; discovered hidden MySQL.
* **`8-decoy.sh`**: Source IP obfuscation via live host clustering; verified SMB on 10.10.10.15.
* **`9-idlescan.sh`**: Fully blind port state discovery; safely mapped 10.10.10.10 via zombie 10.10.10.50.
* **`10-osdetect.sh`**: TCP/IP stack fingerprinting against open/closed ports; determined Linux 5.X host OS.
