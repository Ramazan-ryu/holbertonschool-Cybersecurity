#!/usr/bin/env python3
"""
1-normalizer.py
Parses a Nikto report (XML or JSON) and emits findings in a unified schema.
Tags false-positive-prone or noisy check classes with reduced confidence.
"""

import sys
import json
import xml.etree.ElementTree as ET
import os

# A list of keywords commonly found in Nikto's low-value / noisy checks
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
    "site appears to use a load balancer"
]

def evaluate_finding(description):
    """
    Evaluates the description of a finding to assign severity and confidence.
    """
    desc_lower = description.lower()
    
    # Check if the finding belongs to a known noisy class
    for keyword in NOISY_KEYWORDS:
        if keyword in desc_lower:
            return "info", 0.20
    
    # Default assumptions for findings that aren't purely informational headers
    return "medium", 0.85

def parse_xml(filepath):
    findings = []
    tree = ET.parse(filepath)
    root = tree.getroot()
    
    # Nikto's XML nests findings under <scandetails> -> <item>
    for scandetails in root.findall('.//scandetails'):
        target = scandetails.attrib.get('targethostname') or scandetails.attrib.get('targetip', 'unknown')
        
        for item in scandetails.findall('.//item'):
            item_id = item.attrib.get('id', '000000')
            desc_elem = item.find('description')
            desc = desc_elem.text.strip() if desc_elem is not None and desc_elem.text else "No description provided"
            
            severity, confidence = evaluate_finding(desc)
            
            findings.append({
                "id": f"F-NIK-{item_id}",
                "asset": target,
                "source": "nikto",
                "severity": severity,
                "confidence": confidence,
                "desc": desc
            })
    return findings

def parse_json(filepath):
    findings = []
    with open(filepath, 'r') as f:
        data = json.load(f)
        
    # Depending on the Nikto JSON export format
    vulnerabilities = data.get('vulnerabilities', []) if isinstance(data, dict) else data
    
    for item in vulnerabilities:
        if isinstance(item, dict):
            item_id = item.get('id', '000000')
            target = item.get('host', 'unknown') or item.get('ip', 'unknown')
            desc = item.get('msg', '') or item.get('description', 'No description provided')
            
            severity, confidence = evaluate_finding(desc)
            
            findings.append({
                "id": f"F-NIK-{item_id}",
                "asset": target,
                "source": "nikto",
                "severity": severity,
                "confidence": confidence,
                "desc": desc
            })
    return findings

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <report_file>", file=sys.stderr)
        sys.exit(1)
        
    filepath = sys.argv[1]
    
    if not os.path.exists(filepath):
        print(f"Error: File '{filepath}' not found.", file=sys.stderr)
        sys.exit(1)
        
    findings = []
    try:
        # Simple extension check, fallback to XML if not explicitly JSON
        if filepath.lower().endswith('.json'):
            findings = parse_json(filepath)
        else:
            findings = parse_xml(filepath)
    except ET.ParseError:
        # If XML parsing fails, attempt JSON parsing as a fallback
        try:
            findings = parse_json(filepath)
        except Exception as e:
            print(f"Error parsing file as XML or JSON: {e}", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error processing file: {e}", file=sys.stderr)
        sys.exit(1)
        
    # Output the unified schema as a JSON array
    print(json.dumps(findings, indent=2))

if __name__ == '__main__':
    main()
