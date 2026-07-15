#!/usr/bin/python3
"""
4-correlate.py
Consumes normalized findings, merges those referring to the same
underlying vulnerability, and classifies them by scanner agreement.
Flags unique, high-confidence findings as coverage gaps.
"""

import sys
import json
import os


def get_classification(source_count, total_scanners=3):
    """Determines the classification based on scanner agreement."""
    if source_count >= total_scanners:
        return "agreed"
    elif source_count > 1:
        return "contested"
    else:
        return "unique"


def main():
    """Main execution function."""
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <normalized_json>", file=sys.stderr)
        sys.exit(1)

    filepath = sys.argv[1]
    if not os.path.exists(filepath):
        print(f"Error: File '{filepath}' not found.", file=sys.stderr)
        sys.exit(1)

    try:
        with open(filepath, 'r') as f:
            findings = json.load(f)
    except Exception as e:
        print(f"Error reading JSON: {e}", file=sys.stderr)
        sys.exit(1)

    merged = {}
    unmerged = []

    # First pass: Group findings
    for finding in findings:
        asset = finding.get("asset", "unknown")
        cve = finding.get("cve")
        source = finding.get("source", "unknown")
        confidence = finding.get("confidence", 0.0)

        if cve:
            key = f"{asset}_{cve}"
            if key not in merged:
                merged[key] = {
                    "cve": cve,
                    "asset": asset,
                    "sources": set(),
                    "max_confidence": confidence
                }
            merged[key]["sources"].add(source)
            if confidence > merged[key]["max_confidence"]:
                merged[key]["max_confidence"] = confidence
        else:
            unmerged.append(finding)

    output = []
    counter = 1

    # Second pass: Process CVE-merged findings
    for key, data in merged.items():
        sources = sorted(list(data["sources"]))
        classification = get_classification(len(sources))

        out_item = {
            "merged_id": f"V-{counter:04d}",
            "cve": data["cve"],
            "asset": data["asset"],
            "classification": classification,
            "sources": sources
        }

        # A unique finding with a CVE is a genuine vulnerability missed by others
        if classification == "unique":
            out_item["coverage_gap"] = True

        output.append(out_item)
        counter += 1

    # Third pass: Process unmerged (often web/header) findings
    for finding in unmerged:
        asset = finding.get("asset", "unknown")
        source = finding.get("source", "unknown")
        confidence = finding.get("confidence", 0.0)

        sources = [source]
        classification = "unique"

        out_item = {
            "merged_id": f"V-{counter:04d}",
            "asset": asset,
            "classification": classification,
            "sources": sources
        }

        # Differentiate genuine unique findings from noisy false positives
        # Using 0.70 threshold based on previous normalization parameters
        if confidence >= 0.70:
            out_item["coverage_gap"] = True

        # Optional: carry over specific descriptions/IDs if needed by your schema
        if "cve" in finding:
            out_item["cve"] = finding["cve"]

        output.append(out_item)
        counter += 1

    print(json.dumps(output, indent=2))


if __name__ == '__main__':
    main()
