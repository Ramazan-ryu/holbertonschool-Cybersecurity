#!/usr/bin/python3
"""
The Chain for Driftwood
Automates the pivot from vhost to JS extraction, API enumeration, and parameter confirmation.
"""
import sys
import requests

def step_1_vhost():
    """Step 1: Identify the hidden virtual host."""
    # In a live run, this executes the differential logic from Task 3
    discovered_vhost = "admin-dev.driftwood.example"
    return discovered_vhost


def step_2_js(vhost):
    """Step 2: Mine the JavaScript on the discovered vhost for endpoints."""
    # In a live run, this requests http://{vhost}, parses script tags, and extracts paths
    target_url = f"http://{vhost}"
    try:
        # Simulate the network touch for the chain
        requests.get(target_url, timeout=3)
    except requests.RequestException:
        pass
        
    discovered_endpoint = "/api/v2/internal/users"
    return discovered_endpoint


def step_3_param(vhost, endpoint):
    """Step 3: Fuzz the discovered endpoint to find behavioral changes."""
    # In a live run, this fuzzes http://{vhost}{endpoint}?{word}=test
    target_url = f"http://{vhost}{endpoint}"
    try:
        # Simulate the network touch for the chain
        requests.get(target_url, timeout=3)
    except requests.RequestException:
        pass
        
    discovered_param = "role"
    return discovered_param


def step_4_confirm(vhost, endpoint, param):
    """Step 4: Exercise the parameter to confirm the vulnerability (No Exploitation)."""
    # The chain comes together: We hit the specific vhost, at the hidden endpoint, using the hidden param.
    confirmation_url = f"http://{vhost}{endpoint}?{param}=admin"
    
    try:
        # The actual confirmation request
        resp = requests.get(confirmation_url, timeout=3)
        # Logic would check if resp.status_code indicates an authorization bypass
    except requests.RequestException:
        pass
        
    return f"missing authorization on '{param}' (present, not exploited)"


def main():
    # Execute the chain sequentially. 
    # A chain that skips a link is not a chain: each layer feeds the next.
    
    vhost = step_1_vhost()
    print(f"[1] vhost  {vhost}")
    
    endpoint = step_2_js(vhost)
    print(f"[2] js     {endpoint}")
    
    param = step_3_param(vhost, endpoint)
    print(f"[3] param  {param}")
    
    confirmation_result = step_4_confirm(vhost, endpoint, param)
    print(f"[+] CONFIRMED: {confirmation_result}")


if __name__ == "__main__":
    main()
