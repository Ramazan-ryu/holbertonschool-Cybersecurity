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
                           "http" if port in (80, 8080) else \
                           "ssh" if port == 22 else "unknown"

            open_ports.append({
                "port": port,
                "service": service_name,
                "state": "open"
            })

    # If the host is completely silent on ICMP and all targeted TCP ports, skip
    if not is_up_icmp and not open_ports:
        return None

    # Classify the discovery method
    if is_up_icmp:
        host_data["discovery"] = "found by standard ICMP probe"
    else:
        host_data["discovery"] = (
            "silent to default probes; found by TCP-level check"
        )

    host_data["ports"] = open_ports

    # Initial naive role classification based on exposed surface
    if any(p["port"] in (80, 443, 8080, 8443) for p in open_ports):
        host_data["role"] = "web"
    elif any(p["port"] in (3306, 5432) for p in open_ports):
        host_data["role"] = "database"

    return host_data


def main():
    parser = argparse.ArgumentParser(
        description="Map the estate accurately and discreetly."
    )
    parser.add_argument("--scope", required=True,
                        help="IP range (e.g., 10.40.0.0/22)")
    parser.add_argument("--domain", required=True,
                        help="Domain root (e.g., castellan.example)")
    parser.add_argument("--output-dir", required=False,
                        help="Directory to save artifacts")

    args = parser.parse_args()

    # strict=False allows standard network inputs with host bits set
    network = ipaddress.ip_network(args.scope, strict=False)

    hosts = []
    total_services = 0

    # ThreadPool limits simultaneous connections to remain stealthy and gentle
    # while processing the 1,024 IPs in a /22 efficiently.
    with ThreadPoolExecutor(max_workers=20) as executor:
        ip_strings = [str(ip) for ip in network.hosts()]
        results = executor.map(scan_host, ip_strings)

        for res in results:
            if res is not None:
                hosts.append(res)
                total_services += len(res
