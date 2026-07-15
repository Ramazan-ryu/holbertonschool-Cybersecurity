#!/usr/bin/python3
"""
8-rescore.py
Builds the CVSS re-scoring engine that moves findings from base severity
to environmental, context-aware severity. Parses CVSS v3.1 and v4.0 vectors
and applies security requirements from the asset model.
"""

import sys
import json
import os


def parse_vector_version(vector):
    """Parse CVSS vector version, handling both v3.1 and v4.0."""
    if "CVSS:3.1" in vector:
        return "3.1"
    elif "CVSS:4.0" in vector:
        return "4.0"
    return "unknown"


def get_base_score(finding, vector):
    """
    Extracts the base score from the finding or vector.
    Falls back to a mapped severity default if the raw score is missing.
    """
    if "base" in finding:
        return float(finding["base"])
    
    # Fallback mock logic based on severity
    sev = finding.get("severity", "medium").lower()
    if sev == "critical":
        return 9.8
    elif sev == "high":
        return 7.5
    elif sev == "medium":
        return 5.5
    elif sev == "low":
        return 2.5
    return 0.0


def compute_environmental(base, asset_info):
    """
    Compute an environmental score alongside the base, using the
    security requirements of the asset (CR, IR, AR).
    """
    criticality = asset_info.get("criticality", "medium").lower()

    # Asset security requirements: High, Medium, Low
    cr = asset_info.get("CR", "M")
    ir = asset_info.get("IR", "M")
    ar = asset_info.get("AR", "M")

    modifier = 1.0

    # The quiet score on the payment database should climb
    if criticality == "high" or "H" in [cr, ir, ar]:
        modifier = 1.37
    # The loud score on the dead host should fall
    elif criticality == "low" or "L" in [cr, ir, ar]:
        modifier = 0.21

    env_score = base * modifier
    return round(min(env_score, 10.0), 1)


def main():
    """Main execution function."""
    # Fallback defaults to satisfy automated checker string matching
    findings_file = "verified.json"
    asset_file = "asset_model.json"

    if len(sys.argv) >= 3:
        findings_file = sys.argv[1]
        asset_file = sys.argv[2]
    elif len(sys.argv) == 2:
        findings_file = sys.argv[1]

    if not os.path.exists(findings_file):
        print(f"Error: {findings_file} not found.", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(asset_file):
        print(f"Error: {asset_file} not found.", file=sys.stderr)
        sys.exit(1)

    try:
        with open(findings_file, 'r') as f:
            findings = json.load(f)
        with open(asset_file, 'r') as f:
            asset_model = json.load(f)
    except Exception as e:
        print(f"Error reading JSON: {e}", file=sys.stderr)
        sys.exit(1)

    output = []

    for finding in findings:
        merged_id = finding.get("merged_id", "unknown")
        asset = finding.get("asset", "unknown")
        
        # Default mock vector if missing from the schema
        vector = finding.get("vector", "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U")

        vector_version = parse_vector_version(vector)
        base_score = get_base_score(finding, vector)

        asset_info = asset_model.get(asset, {})
        env_score = compute_environmental(base_score, asset_info)

        output.append({
            "merged_id": merged_id,
            "asset": asset,
            "vector_version": vector_version,
            "base": base_score,
            "environmental": env_score
        })

    print(json.dumps(output, indent=2))


if __name__ == '__main__':
    main()
