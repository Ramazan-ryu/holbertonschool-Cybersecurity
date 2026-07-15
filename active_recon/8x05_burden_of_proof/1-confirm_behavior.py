#!/usr/bin/python3
"""
Script to behaviorally confirm finding F-APP-007
(Server-Side Template Injection).
"""

import argparse
import json
import requests
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True, help="Target URL")
    args = parser.parse_args()

    target = args.target.rstrip('/')
    session = requests.Session()

    # Define the benign probe and its control
    probe = "zzq{{7*7}}"
    control = "zzq{{8*8}}"

    evidence = {
        "sent": probe,
        "reflected": None,
        "control_sent": control,
        "control_reflected": None
    }

    verdict = "unconfirmed"

    # Common injection vectors: query parameters and 404 path reflection
    test_vectors = [
        {"method": "GET", "url": target, "params": {"q": probe}},
        {"method": "GET", "url": f"{target}/{probe}", "params": None},
        {"method": "GET", "url": f"{target}/api/v1/profile",
         "params": {"name": probe}}
    ]

    control_vectors = [
        {"method": "GET", "url": target, "params": {"q": control}},
        {"method": "GET", "url": f"{target}/{control}", "params": None},
        {"method": "GET", "url": f"{target}/api/v1/profile",
         "params": {"name": control}}
    ]

    try:
        # Loop through vectors to find the reflection point
        for i in range(len(test_vectors)):
            v_probe = test_vectors[i]
            v_control = control_vectors[i]

            req_probe = session.request(
                v_probe["method"],
                v_probe["url"],
                params=v_probe["params"],
                timeout=5
            )

            req_control = session.request(
                v_control["method"],
                v_control["url"],
                params=v_control["params"],
                timeout=5
            )

            if "zzq49" in req_probe.text and "zzq64" in req_control.text:
                evidence["reflected"] = "zzq49"
                evidence["control_reflected"] = "zzq64"
                verdict = "confirmed"
                break

    except requests.RequestException as e:
        sys.stderr.write(f"Request failed: {e}\n")
        sys.exit(1)

    # Construct the final schema
    result = {
        "finding": "F-APP-007",
        "class": "behavioral_confirmation",
        "verdict": verdict,
        "evidence": evidence,
        "stopped_at": "input is evaluated; no file read or code "
                      "execution attempted"
    }

    if verdict == "unconfirmed":
        result["to_settle"] = "Could not identify evaluation reflection point."

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
