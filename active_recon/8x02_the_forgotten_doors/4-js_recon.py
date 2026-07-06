#!/usr/bin/python3
"""
JavaScript Analyzer for Driftwood
Extracts hidden endpoints and keys from JS bundles and lazy-loaded chunks.
"""
import sys
import re
import requests
from urllib.parse import urljoin
from bs4 import BeautifulSoup


def main():
    if len(sys.argv) != 2:
        print("Usage: ./4-js_recon.py <url>")
        sys.exit(1)
        
    base_url = sys.argv[1].rstrip('/')
    
    try:
        html_resp = requests.get(base_url, timeout=5)
        html_resp.raise_for_status()
    except requests.RequestException:
        print("Error: Could not connect to the target.")
        sys.exit(1)
        
    soup = BeautifulSoup(html_resp.text, 'html.parser')
    
    # 1. Queue all initial script tags found in the DOM
    js_queue = []
    visited_js = set()
    
    for script in soup.find_all('script'):
        src = script.get('src')
        if src:
            js_url = urljoin(base_url, src)
            js_queue.append(js_url)
            
    # 2. Define Regex Patterns
    # Matches /api/... or generic absolute paths
    general_path_pattern = re.compile(r'[\'"`](/api/[a-zA-Z0-9_/?&={}-]+)[\'"`]')
    # Matches explicitly called endpoints in fetch or axios
    fetch_pattern = re.compile(r'(?:fetch|axios(?:\.\w+)?)\s*\(\s*[\'"`](/[^\'"`]+)[\'"`]')
    
    # Matches AWS Keys (AKIA followed by 16 uppercase alphanumerics)
    key_pattern = re.compile(r'(AKIA[0-9A-Z]{16})')
    
    # Matches lazy-loaded chunk references (e.g., '7.js', 'chunk-7.js')
    chunk_pattern = re.compile(r'[\'"`]([a-zA-Z0-9_-]+\.js)[\'"`]')
    
    seen_endpoints = set()
    seen_keys = set()
    
    # 3. Recursively process JS files and discover new chunks
    while js_queue:
        current_js = js_queue.pop(0)
        
        if current_js in visited_js:
            continue
            
        visited_js.add(current_js)
        js_name = current_js.split('/')[-1]
        
        try:
            js_resp = requests.get(current_js, timeout=5)
            js_text = js_resp.text
        except requests.RequestException:
            continue
            
        # Extract Endpoints
        endpoints = fetch_pattern.findall(js_text)
        endpoints.extend(general_path_pattern.findall(js_text))
        
        for ep in endpoints:
            if ep not in seen_endpoints:
                seen_endpoints.add(ep)
                print(f"[+] endpoint  {ep:<26} (found in {js_name})")
                
        # Extract Keys
        keys = key_pattern.findall(js_text)
        for k in keys:
            if k not in seen_keys:
                seen_keys.add(k)
                print(f"[+] key       {k:<26} (found in {js_name})")
                
        # Extract further chunks (lazy loading) to maintain the crawl
        chunks = chunk_pattern.findall(js_text)
        for chunk in chunks:
            # Reconstruct the URL based on the current JS file's path
            chunk_url = urljoin(current_js, chunk)
            if chunk_url not in visited_js:
                js_queue.append(chunk_url)


if __name__ == "__main__":
    main()
