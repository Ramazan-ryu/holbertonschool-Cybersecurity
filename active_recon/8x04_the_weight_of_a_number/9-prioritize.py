#!/usr/bin/python3
"""
9-prioritize.py
Builds the business-risk prioritization that integrates threat context.
Consumes rescored.json and threat_context.json, producing a final
action order that beats the raw severity order, highlighting inversions.
"""

import sys
import json
import os
import csv


def calculate_priority(kev, epss, env):
    """Assign a priority string based on threat context."""
    if kev:
        if env > 8.0:
            return "critical"
        return "high"
    if epss > 0.5 or env > 8.0:
        return "high"
    if epss > 0.1 or env > 5.0:
        return "medium"
    return "low"


def main():
    """Main execution function."""
    findings_file = "rescored.json"
    threat_file = "threat_context.json"

    if len(sys.argv) >= 3:
        findings_file = sys.argv[1]
        threat_file = sys.argv[2]
    elif len(sys.argv) == 2:
        findings_file = sys.argv[1]

    if not os.path.exists(findings_file):
        print(f"Error: {findings_file} not found.", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(threat_file):
        print(f"Error: {threat_file} not found.", file=sys.stderr)
        sys.exit(1)

    try:
        with open(findings_file, 'r') as f:
            findings = json.load(f)
        with open(threat_file, 'r') as f:
            threat_context = json.load(f)
    except Exception as e:
        print(f"Error reading JSON: {e}", file=sys.stderr)
        sys.exit(1)

    enriched = []
    for finding in findings:
        mid = finding.get("merged_id", "unknown")
        base = finding.get("base", 0.0)
        env = finding.get("environmental", 0.0)

        t_data = threat_context.get(mid, {})
        kev = t_data.get("kev", False)

        # Handle potential string booleans from JSON mapping
        if isinstance(kev, str):
            kev = kev.lower() == 'true'

        epss = float(t_data.get("epss", 0.0))

        priority = calculate_priority(kev, epss, env)

        # Sort priority: KEV listed (1), then EPSS prob, then Env score
        sort_score = (1 if kev else 0, epss, env)

        enriched.append({
            "merged_id": mid,
            "asset": finding.get("asset", "unknown"),
            "base": base,
            "environmental": env,
            "kev": kev,
            "epss": epss,
            "priority": priority,
            "sort_score": sort_score
        })

    # Sort by base score to determine base rank
    base_sorted = sorted(enriched, key=lambda x: x["base"], reverse=True)
    base_ranks = {
        item["merged_id"]: idx + 1 for idx, item in enumerate(base_sorted)
    }

    # Sort by business/threat risk to determine final action order
    final_sorted = sorted(
        enriched, key=lambda x: x["sort_score"], reverse=True
    )

    output_json = []

    # Emitting the prioritized findings as a CSV priority table to stdout
    writer = csv.writer(sys.stdout)
    writer.writerow([
        "rank", "merged_id", "asset", "base", "environmental",
        "kev", "epss", "priority"
    ])

    for idx, item in enumerate(final_sorted):
        rank = idx + 1
        mid = item["merged_id"]
        b_rank = base_ranks[mid]

        # Explicitly mark inversions versus the base-score order
        inversion = rank < b_rank

        kev_str = "true" if item["kev"] else "false"

        writer.writerow([
            rank, mid, item["asset"], item["base"],
            item["environmental"], kev_str, item["epss"], item["priority"]
        ])

        output_json.append({
            "rank": rank,
            "merged_id": mid,
            "asset": item["asset"],
            "base": item["base"],
            "environmental": item["environmental"],
            "kev": item["kev"],
            "epss": item["epss"],
            "priority": item["priority"],
            "base_rank": b_rank,
            "inversion": inversion
        })

    # Emitting the prioritized findings as JSON
    try:
        json_str = json.dumps(output_json, indent=2)
        with open("prioritized.json", "w") as jf:
            jf.write(json_str)
    except Exception:
        pass


if __name__ == '__main__':
    main()
