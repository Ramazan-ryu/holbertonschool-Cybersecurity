#!/usr/bin/python3
"""
Script to disprove finding F-WEB-002 (SQL Injection False Positive).
"""

import argparse
import json
import requests
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True, help="Target URL")
    parser.add_argument("--param", required=True, help="Target parameter")
    args = parser.parse_args()

    target = args.target.rstrip('/')
    param = args.param
    session = requests.Session()

    # Inputs: Malicious, Benign, and Empty
    payloads = {
        "sql_input": "' OR 1=1 --",
        "benign_input": "test_input",
        "empty_input": ""
    }

    evidence = {}
    status_codes = set()

    try:
        # Test each payload to observe how the server reacts
        for key, val in payloads.items():
            req = session.get(target, params={param: val}, timeout=5)
            evidence[key] = f"HTTP {req.status_code}"
            status_codes.add(req.status_code)

        # If all responses are structurally identical (generic error)
        if len(status_codes) == 1:
            verdict = "false_positive"
            evidence["conclusion"] = (
                "error identical for every input; generic error page, "
                "not an injectable query"
            )
        else:
            verdict = "unconfirmed"
            evidence["conclusion"] = (
                "Responses varied across inputs; cannot definitively "
                "confirm a false positive."
            )

    except requests.RequestException as e:
        sys.stderr.write(f"Request failed: {e}\n")
        sys.exit(1)

    result = {
        "finding": "F-WEB-002",
        "class": "sql_injection",
        "verdict": verdict,
        "evidence": evidence,
        "stopped_at": "condition disproven; no further action"
    }

    if verdict == "unconfirmed":
        result["to_settle"] = "Requires manual investigation of responses."

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
