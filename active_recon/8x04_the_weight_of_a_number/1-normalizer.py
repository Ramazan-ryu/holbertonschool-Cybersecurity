#!/usr/bin/python3
"""
1-normalizer.py
Parses Nikto, OpenVAS, and Nessus reports into a unified schema.
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
    """Evaluates the Nikto finding description for severity and confidence."""
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
    for result in root.findall('.//result'):
        result_id = result.attrib.get('id', 'unknown')
        
        host_elem = result.find('host')
        if host_elem is not None and host_elem.text:
            asset = host_elem.text.strip()
        else:
            asset = "unknown"
        
        desc_elem = result.find('description')
        if desc_elem is not None and desc_elem.text:
            desc = desc_elem.text.strip()
        else:
            desc = "No description"
        
        threat_elem = result.find('threat')
        if threat_elem is not None and threat_elem.text:
            threat = threat_elem.text.strip().lower()
        else:
            threat = "info"

        if threat in ["log", "none"]:
            severity = "info"
        else:
            severity = threat
            
        qod_elem = result.find('./qod/value')
        if qod_elem is not None and qod_elem.text:
            try:
                confidence = float(qod_elem.text) / 100.0
            except ValueError:
                confidence = 0.70
        else:
            confidence = 0.70
            
        finding = {
            "id": f"F-OV-{result_id[:3]}", 
            "asset": asset,
            "source": "openvas",
            "severity": severity,
            "confidence": confidence,
            "description": desc
        }
        
        nvt_elem = result.find('nvt')
        if nvt_elem is not None:
            cve_elem = nvt_elem.find('cve')
            if cve_elem is not None and cve_elem.text:
                cve_text = cve_elem.text.strip().upper()
                if cve_text != 'NOCVE':
                    finding["cve"] = cve_elem.text.strip()
                    
        findings.append(finding)
    return findings


def parse_nessus_xml(root):
    """Parses Nessus XML reports into the unified schema."""
    findings = []
    
    # Nessus numerical severity mapping
    severity_map = {
        "0": "info",
        "1": "low",
        "2": "medium",
        "3": "high",
        "4": "critical"
    }

    for report_host in root.findall('.//ReportHost'):
        asset = report_host.attrib.get('name', 'unknown')

        for item in report_host.findall('.//ReportItem'):
            plugin_id = item.attrib.get('pluginID', 'unknown')
            raw_severity = item.attrib.get('severity', '0')
            severity = severity_map.get(raw_severity, "info")

            desc_elem = item.find('description')
            if desc_elem is not None and desc_elem.text:
                desc = desc_elem.text.strip()
            else:
                desc = "No description"

            finding = {
                "id": f"F-NES-{plugin_id}",
                "asset": asset,
                "source": "nessus",
                "severity": severity,
                "confidence": 0.90,
                "description": desc
            }

            # Nessus maps CVEs under `<cve>` child elements inside ReportItem
            cve_elem = item.find('cve')
            if cve_elem is not None and cve_elem.text:
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
            
            # Root tag detection to route to the correct parser
            if root.tag == 'niktoscan':
                findings = parse_nikto_xml(root)
            elif root.tag == 'report' or root.findall('.//result'):
                findings = parse_openvas_xml(root)
            elif root.tag == 'NessusClientData_v2':
                findings = parse_nessus_xml(root)
            else:
                print("Warning: Unknown XML format.", file=sys.stderr)

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
