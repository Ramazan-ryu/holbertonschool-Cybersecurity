#!/usr/bin/python3
"""
Phase 2: Service Enumeration
Consumes the estate map and deeply enumerates non-web network services
to extract actionable intelligence using protocol-aware probes.
"""

import argparse
import json
import sys
import os

try:
    from groundtruth import transport
except ImportError:
    print("Error: groundtruth framework not found.", file=sys.stderr)
    sys.exit(1)


def enumerate_ftp(ip, port):
    """
    Attempts anonymous FTP login to uncover unauthorized access.
    """
    payload = b"USER anonymous\r\nPASS anonymous\r\n"
    resp = transport.service_connect(ip, port, payload)
    
    if resp and b"230" in resp:
        # Check if we can list the directory after logging in
        list_payload = payload + b"PASV\r\nLIST\r\n"
        list_resp = transport.service_connect(ip, port, list_payload)
        
        return {
            "finding": "Anonymous FTP login permitted",
            "evidence": {
                "auth": "anonymous:anonymous",
                "response": resp.decode('utf-8', errors='ignore').strip()
            }
        }
    return None


def enumerate_smb(ip, port):
    """
    Sends a mock null-session negotiation probe for SMB/CIFS.
    """
    # Simple SMB negotiate protocol request
    payload = b"\x00\x00\x00\x85\xFF\x53\x4D\x42\x72\x00\x00\x00\x00"
    resp = transport.service_connect(ip, port, payload)
    
    if resp and len(resp) > 4 and b"\xffSMB" in resp:
        return {
            "finding": "SMB service accessible without credentials",
            "evidence": {
                "auth": "null",
                "bytes_received": len(resp)
            }
        }
    return None


def enumerate_custom(ip, port):
    """
    Probes non-standard operational ports (like 9000) for leaked
    system telemetry or exposed configurations.
    """
    probes = [b"VERSION\r\n", b"HELP\r\n", b"INFO\r\n", b"STATUS\r\n"]
    
    for probe in probes:
        resp = transport.service_connect(ip, port, probe)
        if resp and len(resp) > 5 and b"error" not in resp.lower():
            return {
                "finding": "Custom service leaks operational telemetry",
                "evidence": {
                    "probe": probe.decode('utf-8', errors='ignore').strip(),
                    "response": resp.decode('utf-8', errors='ignore').strip()
                }
            }
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Deeply enumerate non-web network services."
    )
    parser.add_argument("estate_map", help="Path to estate_map.json")
    parser.add_argument("--output-dir", required=False,
                        help="Directory to save enumeration_findings.json")

    args = parser.parse_args()

    try:
        with open(args.estate_map, "r") as f:
            estate = json.load(f)
    except FileNotFoundError:
        print(f"Error: Could not find {args.estate_map}", file=sys.stderr)
        sys.exit(1)

    findings = []

    # Iterate through the mapped hosts and their active services
    for host in estate.get("hosts", []):
        ip = host.get("ip")
        for p in host.get("ports", []):
            port = p.get("port")
            state = p.get("state")
            service = p.get("service", "unknown")

            if state != "open":
                continue

            finding_data = None

            # Protocol-aware enumeration routing
            if port == 21 or service == "ftp":
                finding_data = enumerate_ftp(ip, port)
            elif port in (139, 445) or service == "smb":
                finding_data = enumerate_smb(ip, port)
            elif port == 9000 or service == "unknown":
                # Fallback probe for non-standard/hidden services
                finding_data = enumerate_custom(ip, port)

            if finding_data:
                findings.append({
                    "asset": ip,
                    "service": service if service != "unknown" 
                               else f"custom-{port}",
                    "finding": finding_data["finding"],
                    "evidence": finding_data["evidence"]
                })

    # Format output precisely to the required JSON structure
    json_out = json.dumps(findings, indent=2)
    print(json_out)

    if args.output_dir:
        os.makedirs(args.output_dir, exist_ok=True)
        out_path = os.path.join(args.output_dir, "enumeration_findings.json")
        with open(out_path, "w") as f:
            f.write(json_out + "\n")


if __name__ == "__main__":
#!/usr/bin/python3
"""
Phase 1: Estate Discovery
Maps the target estate using ICMP and gentle TCP probes to uncover standard
and hidden assets within the provided scope without disrupting fragile systems.
"""

import argparse
import json
import ipaddress
import sys
from concurrent.futures import ThreadPoolExecutor

try:
    from groundtruth import transport
except ImportError:
    print("Error: groundtruth framework not found in environment.",
          file=sys.stderr)
    sys.exit(1)

# Targeted list combining standard infrastructure ports and known non-standard
# operational ports (e.g., 9000) to minimize noise and protect fragile hosts.
TARGET_PORTS = [
    21, 22, 23, 80, 139, 443, 445, 3306, 3389, 5432, 8080, 8443, 9000
]


def scan_host(ip_str):
    """
    Probes a single IP address using ICMP and a targeted TCP sweep.
    Returns a dictionary of host data if active, or None if completely dead.
    """
    host_data = {
        "ip": ip_str,
        "name": None,  # Name resolution deferred to later phases
        "role": "unclassified",
        "discovery": "",
        "ports": []
    }

    # 1. Base ICMP Probe
    is_up_icmp = transport.icmp_probe(ip_str)

    # 2. Gentle TCP Probe (vital for hosts dropping ICMP)
    open_ports = []
    for port in TARGET_PORTS:
        is_open, banner = transport.tcp_probe(ip_str, port)
        if is_open:
            # Basic service fingerprinting based on port
            service_name = "https" if port in (443, 8443) else \
    main()
