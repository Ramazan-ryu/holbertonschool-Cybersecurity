#!/usr/bin/python3
"""
1-normalizer.py
Parses Nikto and OpenVAS reports and emits findings in a unified schema.
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


def evaluate_nikto_finding(description):
    """
    Evaluates the Nikto finding description for severity and confidence.
    """
    desc_lower = description.lower()

    for keyword in NOISY_KEYWORDS:
        if keyword in desc_lower:
            return "info", 0.20

    return "medium", 0.85


def parse_nikto_xml(root):
    """Parses Nikto XML structure."""
    findings = []
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

            severity, confidence = evaluate_nikto_finding(desc)

            findings.append({
                "id": f"F-NIK-{item_id}",
                "asset": target,
                "source": "nikto",
                "severity": severity,
                "confidence": confidence,
                "description": desc
            })
    return findings


def parse_openvas_xml(root):
    """Parses OpenVAS XML reports into the unified schema."""
    findings = []
    
    # OpenVAS wraps findings in <results><result>
    for result in root.findall('.//result'):
        result_id = result.attrib.get('id', 'unknown')
        
        # Get target asset
        host_elem = result.find('host')
        asset = host_elem.text.strip() if host_elem is not None and host_elem.text else "unknown"
        
        # Get description
        desc_elem = result.find('description')
        desc = desc_elem.text.strip() if desc_elem is not None and desc_elem.text else "No description"
        
        # Map Severity (OpenVAS uses Threat: High, Medium, Low, Log)
        threat_elem = result.find('threat')
        threat = threat_elem.text.strip().lower() if threat_elem is not None and threat_elem.text else "info"
        if threat in ["log", "none"]:
            severity = "info"
        else:
            severity = threat
            
        # Extract Quality of Detection (QoD) to use as confidence (e.g. 80 = 0.80)
        qod_elem = result.find('./qod/value')
        if qod_elem is not None and qod_elem.text:
            try:
                confidence = float(qod_elem.text) / 100.0
            except ValueError:
                confidence = 0.70
        else:
            confidence = 0.70
            
        finding = {
            # Trim the OpenVAS UUID just to keep output clean, similar to the expected format
            "id": f"F-OV-{result_id[:3]}", 
            "asset": asset,
            "source": "openvas",
            "severity": severity,
            "confidence": confidence,
            "description": desc
        }
        
        # Add CVE if present
        nvt_elem = result.find('nvt')
        if nvt_elem is not None:
            cve_elem = nvt_elem.find('cve')
            if cve_elem is not None and cve_elem.text:
                cve_text = cve_elem.text.strip().upper()
                if cve_text != 'NOCVE':
                    finding["cve"] = cve_elem.text.strip()
                    
        findings.append(finding)
        
    return findings


def parse_json(filepath):
    """Parses Nikto JSON reports."""
    findings = []
    with open(filepath, 'r') as f:
        data = json.load(f)

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

            severity, confidence = evaluate_nikto_finding(desc)

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
            tree = ET.parse(filepath)
            root = tree.getroot()
            
            # УСЛОВИЕ 1 И 2: Динамический выбор парсера на основе XML тега
            if root.tag == 'niktoscan':
                findings = parse_nikto_xml(root)
            elif root.tag == 'report' or root.findall('.//result'):
                findings = parse_openvas_xml(root)
            else:
                print("Warning: Unknown XML format. Defaulting to Nikto parser.", file=sys.stderr)
                findings = parse_nikto_xml(root)

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
