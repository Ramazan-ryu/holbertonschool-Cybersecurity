#!/usr/bin/python3
"""
Virtual Host Finder for Driftwood
"""
import sys
import requests
import uuid

def main():
    # The prompt expects 2 arguments: domain and IP, but we also need a wordlist.
    # We will default to vhosts-small.txt if a third isn't provided.
    if len(sys.argv) < 3:
        print("Usage: ./3-vhost_finder.py <domain> <ip> [wordlist]")
        sys.exit(1)
        
    domain = sys.argv[1]
    ip = sys.argv[2]
    wordlist_path = sys.argv[3] if len(sys.argv) > 3 else "vhosts-small.txt"
    
    target_url = f"http://{ip}"
    
    # 1. Establish the baseline with a mathematically impossible host
    impossible_sub = str(uuid.uuid4())[:8]
    impossible_host = f"{impossible_sub}.{domain}"
    
    try:
        base_resp = requests.get(target_url, headers={"Host": impossible_host}, timeout=5)
        baseline = {
            "status": base_resp.status_code,
            "length": len(base_resp.text)
        }
        print(f"[*] baseline: {baseline['status']} len={baseline['length']}")
    except requests.RequestException:
        print("Error: Could not connect to the target IP.")
        sys.exit(1)
        
    # 2. Load the wordlist
    try:
        with open(wordlist_path, 'r') as f:
            words = f.read().splitlines()
    except FileNotFoundError:
        print(f"Error: Wordlist '{wordlist_path}' not found.")
        sys.exit(1)
        
    # 3. Fuzz the Host header
    for word in words:
        test_host = f"{word}.{domain}"
        headers = {"Host": test_host}
        
        try:
            resp = requests.get(target_url, headers=headers, timeout=5)
            
            # Compare response to the baseline to catch differentials
            if resp.status_code != baseline["status"] or abs(len(resp.text) - baseline["length"]) > 10:
                print(f"[+] {test_host}   {resp.status_code} len={len(resp.text)}   (differs from baseline)")
        except requests.RequestException:
            continue

if __name__ == "__main__":
    main()
