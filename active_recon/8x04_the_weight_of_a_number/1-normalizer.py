#!/usr/bin/python3
"""
1-normalizer.py
Parses a Nikto report (XML or JSON) and emits findings in a unified schema.
Tags false_positive-prone or noisy check classes with reduced confidence.
"""

import sys
import json
import xml.etree.ElementTree as ET
import os

# Keywords found in Nikto's noisy or false_positive checks
NOISY_KEYWORDS = [
    "x-frame-options",
    "x-content-type-options",
    "strict-transport-security",
    "server header",
    "allowed http methods",
    "cookie",
    "directory indexing",
    "generic header",
    "cross-site scripting protection",
    "x-xss-protection",
    "load balancer"
]


def evaluate_finding(description):
    """
    Evaluates the finding description for severity and confidence.
    """
    desc_lower = description.lower()

    for keyword in NOISY_KEYWORDS:
        if keyword in desc_lower:
            return "info", 0.20

    return "medium", 0.85


def parse_xml(filepath):
    """Parses Nikto XML reports."""
    findings = []
    tree = ET.parse(filepath)
    root = tree.getroot()

    for scandetails in root.findall('.//scandetails'):
        host = scandetails.attrib.get('targethostname')
        ip = scandetails.attrib.get('targetip', 'unknown')
        target = host if host else ip

        for item in scandetails.findall('.//item'):
            item_id = item.attrib.get('id', '000000')
            desc_elem = item.find('description')
            if desc_elem is not None and desc_elem.text:
                desc = desc_elem.text.strip()
            else:
                desc = "No description provided"

            severity, confidence = evaluate_finding(desc)

            findings.append({
                "id": f"F-NIK-{item_id}",
                "asset": target,
                "source": "nikto",
                "severity": severity,
                "confidence": confidence,
                "description": desc
            })
    return findings


def parse_json(filepath):
    """Parses Nikto JSON reports."""
    findings = []
    with open(filepath, 'r') as f:
        data = json.load(f)

    # Nikto JSON export format handling
    if isinstance(data, dict):
        vulnerabilities = data.get('vulnerabilities', [])
    else:
        vulnerabilities = data

    for item in vulnerabilities:
        if isinstance(item, dict):
            item_id = item.get('id', '000000')
            host = item.get('host', 'unknown')
            ip = item.get('ip', 'unknown')
            target = host if host != 'unknown' else ip
            desc = item.get('msg', '') or item.get('description', 'No desc')

            severity, confidence = evaluate_finding(desc)

            findings.append({
                "id": f"F-NIK-{item_id}",
                "asset": target,
                "source": "nikto",
                "severity": severity,
                "confidence": confidence,
                "description": desc
            })
    return findings


def main():
    """Main execution function."""
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <report_file>", file=sys.stderr)
        sys.exit(1)

    filepath = sys.argv[1]

    if not os.path.exists(filepath):
        print(f"Error: File '{filepath}' not found.", file=sys.stderr)
        sys.exit(1)

    findings = []
    try:
        if filepath.lower().endswith('.json'):
            findings = parse_json(filepath)
        else:
            findings = parse_xml(filepath)
    except ET.ParseError:
        try:
            findings = parse_json(filepath)
        except Exception as e:
            print(f"Error parsing file: {e}", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error processing file: {e}", file=sys.stderr)
        sys.exit(1)

    print(json.dumps(findings, indent=2))


if __name__ == '__main__':
    main()
