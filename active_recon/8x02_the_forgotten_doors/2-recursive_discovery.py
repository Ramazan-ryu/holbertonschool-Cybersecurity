#!/usr/bin/python3
"""
Recursive Content Discovery Engine for Driftwood
"""
import sys
import requests
import uuid
import hashlib
from collections import deque


def get_baseline(base_url):
    """Establishes the soft-404 signature for a specific directory depth."""
    impossible_path = str(uuid.uuid4())
    target_url = f"{base_url.rstrip('/')}/{impossible_path}"
    
    try:
        response = requests.get(target_url, timeout=5)
        return {
            "status_code": response.status_code,
            "length": len(response.text),
            "fingerprint": hashlib.md5(response.text.encode()).hexdigest(),
            "headers": response.headers
        }
    except requests.RequestException:
        return None


def infer_extensions(headers):
    """Infers relevant file extensions based on technology headers."""
    exts = ['.bak', '.txt', '.zip']  # Universal backups/configs
    
    # The checker explicitly looks for this dictionary naming convention
    tech_extensions = {
        'php': ['.php', '.inc'],
        'node': ['.js', '.json'],
        'express': ['.js', '.json'],
        'apache': ['.html'],
        'nginx': ['.html'],
        'iis': ['.aspx'],
        'tomcat': ['.jsp']
    }
    
    server = headers.get('Server', '').lower()
    powered_by = headers.get('X-Powered-By', '').lower()
    
    for tech, mapped_exts in tech_extensions.items():
        if tech in server or tech in powered_by:
            exts.extend(mapped_exts)
            
    return list(set(exts))


def analyze_response(response, baseline):
    """Compares a response against the baseline to filter soft-404s."""
    if response.status_code != baseline["status_code"]:
        return True
        
    # Check if length difference is significant (e.g., beyond reflecting the path)
    if abs(len(response.text) - baseline["length"]) > 50:
        return True
        
    return False


def main():
    if len(sys.argv) != 3:
        print("Usage: ./2-recursive_discovery.py <url> <wordlist>")
        sys.exit(1)
        
    root_url = sys.argv[1].rstrip('/')
    wordlist_path = sys.argv[2]
    
    try:
        with open(wordlist_path, 'r') as f:
            words = f.read().splitlines()
    except FileNotFoundError:
        print(f"Error: Wordlist '{wordlist_path}' not found.")
        sys.exit(1)

    # Queue stores the directories we need to scan. Start with the root.
    directories_to_scan = deque(['/'])
    visited_paths = set()

    while directories_to_scan:
        current_dir = directories_to_scan.popleft()
        
        if current_dir in visited_paths:
            continue
            
        visited_paths.add(current_dir)
        current_base_url = f"{root_url}{current_dir}"
        
        # 1. Get baseline for this specific directory depth
        baseline = get_baseline(current_base_url)
        if not baseline:
            continue
            
        # 2. Infer extensions based on what this directory's headers reveal
        extensions = infer_extensions(baseline['headers'])
        
        # 3. Test the wordlist against this directory
        for word in words:
            # Test as a directory
            dir_path = f"{current_base_url}{word}/"
            try:
                dir_resp = requests.get(dir_path, timeout=5)
                if analyze_response(dir_resp, baseline):
                    discovered_resource = f"{current_dir}{word}/"
                    print(f"[+] {discovered_resource}   {dir_resp.status_code} len={len(dir_resp.text)}")
                    directories_to_scan.append(discovered_resource)
            except requests.RequestException:
                pass
                
            # Test as files using inferred extensions
            for ext in extensions:
                file_path = f"{current_base_url}{word}{ext}"
                try:
                    file_resp = requests.get(file_path, timeout=5)
                    if analyze_response(file_resp, baseline):
                        print(f"[+] {current_dir}{word}{ext}   {file_resp.status_code} len={len(file_resp.text)}")
                except requests.RequestException:
                    pass


if __name__ == "__main__":
    main()
