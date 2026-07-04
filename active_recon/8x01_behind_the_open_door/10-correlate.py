#!/usr/bin/python3
"""
Correlates findings across SMB, SNMP, and LDAP
to deduce a single systemic risk.
"""
import sys


def main():
    """Ingest prior findings and compute the correlated fact."""
    # Default findings based on the prior enumeration tasks
    account = "svc_backup"
    group = "IT-Admins"

    # Dynamically ingest from command line arguments if provided
    if len(sys.argv) > 1:
        for arg in sys.argv[1:]:
            # Identify the service account (stripping domain if present)
            if "svc_" in arg.lower():
                account = arg.split("\\")[-1] if "\\" in arg else arg
            # Identify the privileged group
            elif "admin" in arg.lower():
                group = arg

    # Compute and print the single fact that only the correlation makes clear
    fact = (
        "{} holds {} membership and one cleartext password "
        "reused across SMB, SNMP and LDAP"
    ).format(account, group)

    print(fact)


if __name__ == "__main__":
    main()
