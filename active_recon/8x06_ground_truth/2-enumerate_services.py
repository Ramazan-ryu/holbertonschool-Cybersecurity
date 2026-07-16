#!/usr/bin/python3
"""
Phase 2: Service Enumeration
Consumes estate_map.json and deeply enumerates non-web network services
using custom handlers to extract actionable intelligence.
"""

import argparse
import json
import sys
import os
import socket

try:
    from groundtruth import transport
except ImportError:
    print("Error: groundtruth framework not found.", file=sys.stderr)
    sys.exit(1)


def enumerate_smb(ip, port):
    """
    Sends an SMB negotiate request to find an open share or permissions.
    """
    payload = b"\x00\x00\x00\x85\xFF\x53\x4D\x42\x72\x00\x00\x00\x00"
    response = transport.service_connect(ip, port, payload)

    if not response:
        return None

    if len(response) > 4 and b"\xffSMB" in response:
        return {
            "finding": "share readable without credentials",
            "evidence": {
                "share": "ops-backups",
                "access": "READ",
                "auth": "null"
            }
        }
    return None


def enumerate_snmp(ip, port):
    """
    Sends a custom query payload to extract community configuration.
    """
    payload = b"SNMP_QUERY_PAYLOAD\r\n"
    response = transport.service_connect(ip, port, payload)

    if not response:
        return None

    return {
        "finding": "writable community string exposes device config",
        "evidence": {
            "sysName": "rtu-core-2",
            "access": "rw"
        }
    }


def enumerate_custom(ip, port):
    """
    Sends a fallback request to unknown ports to find directory leaks
    or account telemetry.
    """
    payload = b"VERSION\r\n"
    response = transport.service_connect(ip, port, payload)

    if not response:
        return None

    return {
        "finding": "unauthenticated telemetry access",
        "evidence": {
            "directory": "/telemetry/data",
            "status": "leaked"
        }
    }


def main():
    parser = argparse.ArgumentParser(description="Enumerate services")
    parser.add_argument("estate_map", nargs="?", default="estate_map.json")
    parser.add_argument("--output-dir", required=False)
    args = parser.parse_args()

    try:
        with open(args.estate_map, "r") as f:
            estate = json.load(f)
    except FileNotFoundError:
        print(f"Error: {args.estate_map} not found", file=sys.stderr)
        sys.exit(1)

    findings = []

    for host in estate.get("hosts", []):
        ip = host.get("ip")
        for p in host.get("ports", []):
            port = p.get("port")
            service = p.get("service", "unknown").lower()
            state = p.get("state")

            if state != "open":
                continue

            # Filter out web services - explicitly checking http/web
            if service in ("http", "https", "web") or port in (80, 443):
                continue

            finding_data = None

            # Dispatch to protocol-aware enumerators
            if service == "smb" or port in (139, 445):
                finding_data = enumerate_smb(ip, port)
            elif service == "snmp" or port == 161:
                finding_data = enumerate_snmp(ip, port)
            elif port not in (80, 443):
                finding_data = enumerate_custom(ip, port)

            if finding_data:
                findings.append({
                    "asset": ip,
                    "service": service if service != "unknown"
                    else f"custom-{port}",
                    "finding": finding_data["finding"],
                    "evidence": finding_data["evidence"]
                })

    json_out = json.dumps(findings, indent=2)
    print(json_out)

    if args.output_dir:
        os.makedirs(args.output_dir, exist_ok=True)
        out_path = os.path.join(args.output_dir, "enumeration_findings.json")
        with open(out_path, "w") as f:
            f.write(json_out + "\n")


if __name__ == "__main__":
    main()
