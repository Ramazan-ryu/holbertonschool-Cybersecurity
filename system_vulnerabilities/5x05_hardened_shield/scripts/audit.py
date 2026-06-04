#!/usr/bin/env python3
"""
scripts/audit.py
Purpose: Security audit tool for hardened container/system
Checks: Kernel, filesystem, identity, services, container
Outputs: audit_result.md with scores and pass/fail
"""

import os
import subprocess

# Output file
OUTPUT_FILE = "/opt/scripts/audit_result.md"

# Initialize category results
results = {
    "Kernel hardening": False,
    "Filesystem security": False,
    "Identity security": False,
    "Service security": False,
    "Container security": False
}

# --------------------------
# 1. Kernel hardening
# --------------------------
# Check for some sysctl hardening parameters
kernel_checks = [
    "net.ipv4.ip_forward = 0",
    "net.ipv4.conf.all.send_redirects = 0",
    "net.ipv4.conf.default.send_redirects = 0",
    "net.ipv4.tcp_syncookies = 1"
]

try:
    output = subprocess.check_output(["sysctl", "-a"], text=True)
    kernel_pass = all(k in output for k in kernel_checks)
    results["Kernel hardening"] = kernel_pass
except Exception:
    results["Kernel hardening"] = False

# --------------------------
# 2. Filesystem security
# --------------------------
# Check if /etc/shadow is immutable
try:
    attrs = subprocess.check_output(["lsattr", "/etc/shadow"], text=True)
    results["Filesystem security"] = "i" in attrs.split()[0]
except Exception:
    results["Filesystem security"] = False

# --------------------------
# 3. Identity security
# --------------------------
# Check root account is locked
try:
    shadow_info = open("/etc/shadow").read()
    results["Identity security"] = shadow_info.startswith("root:!")
except Exception:
    results["Identity security"] = False

# --------------------------
# 4. Service security
# --------------------------
# Check if SSH and Apache services are enabled
ssh_status = subprocess.run(["systemctl", "is-enabled", "ssh"], capture_output=True, text=True)
apache_status = subprocess.run(["systemctl", "is-enabled", "apache2"], capture_output=True, text=True)
results["Service security"] = ("enabled" in ssh_status.stdout.strip()) and ("enabled" in apache_status.stdout.strip())

# --------------------------
# 5. Container security
# --------------------------
# Simple check: user is non-root inside container
results["Container security"] = os.geteuid() != 0

# --------------------------
# Compute score and overall
# --------------------------
total_categories = len(results)
passed = sum(1 for r in results.values() if r)
percentage = int((passed / total_categories) * 100)
status = "PASS" if percentage >= 80 else "FAIL"

# --------------------------
# Write Markdown report
# --------------------------
with open(OUTPUT_FILE, "w") as f:
    f.write("# Security Audit Report\n\n")
    for cat, passed_flag in results.items():
        f.write(f"## {cat}\n")
        f.write(f"- Status: {'✅ PASS' if passed_flag else '❌ FAIL'}\n\n")
    f.write(f"## Overall Score\n")
    f.write(f"- Passed Categories: {passed} / {total_categories}\n")
    f.write(f"- Percentage: {percentage}%\n")
    f.write(f"- Final Result: {status}\n")

print(f"Audit complete. Results saved to {OUTPUT_FILE}")
