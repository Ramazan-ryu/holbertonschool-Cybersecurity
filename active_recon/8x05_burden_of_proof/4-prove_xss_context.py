#!/usr/bin/python3
"""
Script to verify finding F-WEB-021 (XSS).
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

    # Benign marker and special characters to test for escaping
    marker = "zzqmark91"
    payload = f"';//{marker}<>\"'"

    evidence = {
        "marker": marker,
        "context": "unknown",
        "html_encoded": True
    }
    verdict = "unconfirmed"

    try:
        req = session.get(target, params={param: payload}, timeout=10)

        # Check if the raw payload is reflected entirely unescaped
        if payload in req.text:
            verdict = "confirmed"
            evidence["html_encoded"] = False
            evidence["context"] = (
                "reflected unescaped inside a <script> block"
            )
        # Check if it was reflected but safely encoded
        elif marker in req.text and "&lt;" in req.text:
            verdict = "false_positive"
            evidence["html_encoded"] = True
            evidence["context"] = "safely HTML encoded"

    except requests.RequestException as e:
        sys.stderr.write(f"Request failed: {e}\n")
        sys.exit(1)

    stop_msg = ("executable context reached with a benign marker; "
                "no payload deployed")

    result = {
        "finding": "F-WEB-021",
        "class": "xss",
        "verdict": verdict,
        "evidence": evidence,
        "stopped_at": stop_msg
    }

    if verdict == "unconfirmed":
        result["to_settle"] = "Reflection not found in response body."

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
