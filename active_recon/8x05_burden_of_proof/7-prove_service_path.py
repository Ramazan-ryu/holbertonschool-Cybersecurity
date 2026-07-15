#!/usr/bin/python3
"""
Script to verify finding F-SVC-022 (Service Vulnerability / Unauth Access).
"""

import argparse
import json
import socket
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True, help="Target host")
    parser.add_argument("--port", type=int, required=True, help="Target port")
    args = parser.parse_args()

    target = args.target
    port = args.port

    evidence = {
        "probe": "PING",
        "response": "unknown",
        "auth_required": True
    }
    verdict = "unconfirmed"

    try:
        # Speak to the service using a raw socket
        with socket.create_connection((target, port), timeout=5) as sock:
            # Send a standard line-oriented TCP probe (e.g., Redis PING)
            sock.sendall(b"PING\r\n")

            # Read the behavioral tell
            resp_bytes = sock.recv(1024)
            response = resp_bytes.decode('utf-8', errors='ignore').strip()

            evidence["response"] = response

            # Decide verdict based on the raw response
            if response == "+PONG":
                verdict = "confirmed"
                evidence["auth_required"] = False
            elif "NOAUTH" in response.upper() or "AUTH" in response.upper():
                verdict = "false_positive"
                evidence["auth_required"] = True
            else:
                verdict = "unconfirmed"

    except (socket.error, socket.timeout) as e:
        sys.stderr.write(f"Connection failed: {e}\n")
        sys.exit(1)

    stop_msg = ("unauthenticated code path reachable; "
                "no data read, no exploit run")

    result = {
        "finding": "F-SVC-022",
        "class": "service_vulnerability",
        "verdict": verdict,
        "evidence": evidence,
        "stopped_at": stop_msg
    }

    if verdict == "unconfirmed":
        result["to_settle"] = "Response did not match expected PONG or NOAUTH."

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
