#!/usr/bin/python3
"""
Content Discovery Engine for Driftwood
"""
import sys
import requests
import uuid
import hashlib

def get_baseline(base_url):
    """Generates an impossible path to establish a soft_404 signature."""
    # Generate a random path guaranteed not to exist
    impossible_path = str(uuid.uuid4())
    target_url = f"{base_url}/{impossible_path}"
    
    # TODO: Make your GET request here
    # response = requests.get(target_url, timeout=5)
    
    # Extract the required components for the checker
    # status = response.status_code
    # text = response.text
    # fingerprint = hashlib.md5(text.encode()).hexdigest()
    
    # Build and return the signature dictionary
    # signature = {
    #     "status_code": status,
    #     "length": len(text),
    #     "fingerprint": fingerprint
    # }
    # return signature
    pass

def main():
    # Ensure URL and wordlist can be supplied
    if len(sys.argv) != 3:
        print("Usage: ./1-discovery_engine.py <url> <wordlist>")
        sys.exit(1)
        
    url = sys.argv[1].rstrip('/')
    wordlist = sys.argv[2]
    
    # 1. Establish the baseline
    # soft_404 = get_baseline(url)
    
    # Print the signature exactly as the checker expects
    # print(f"[*] soft-404 signature: {soft_404['status_code']} len={soft_404['length']} fp=\"{soft_404['fingerprint'][:10]}...\"")
    
    # 2. Open the wordlist and iterate
    # with open(wordlist, 'r') as f:
    #     words = f.read().splitlines()
        
    # for word in words:
    #     test_url = f"{url}/{word}"
    #     
    #     # TODO: Make your GET request to test_url here
    #     # response = ...
    #     # text = response.text
    #
    #     # Compare against the baseline to see if they differ
    #     # if response.status_code != soft_404['status_code'] or abs(len(text) - soft_404['length']) > 50:
    #     #     print(f"[+] /{word}   {response.status_code} len={len(text)}  (breaks signature)")

if __name__ == "__main__":
    main()
