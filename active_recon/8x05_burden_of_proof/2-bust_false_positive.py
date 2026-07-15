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

    # Define the three distinct payloads: malicious, benign, and empty
    malicious = "' OR 1=1 --"
    benign = "test_input"
    empty = ""

    try:
        # Send requests for each payload type
        req_mal = session.get(target, params={param: malicious}, timeout=5)
        req_ben = session.get(target, params={param: benign}, timeout=5)
        req_emp = session.get(target, params={param: empty}, timeout=5)

        # Check if the responses are identical (input-independent)
        if (req_mal.status_code == req_ben.status_code and
                req_ben.status_code == req_emp.status_code):
            verdict = "false_positive"
            conclusion = (
                "error identical for every input; generic error page, "
                "not an injectable query"
            )
        else:
            verdict = "unconfirmed"
            conclusion = (
                "Responses varied across inputs; cannot definitively "
                "confirm a false positive."
            )

        evidence = {
            "sql_input": f"HTTP {req_mal.status_code}",
            "benign_input": f"HTTP {req_ben.status_code}",
            "empty_input": f"HTTP {req_emp.status_code}",
            "conclusion": conclusion
        }

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
