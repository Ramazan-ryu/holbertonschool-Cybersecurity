#!/usr/bin/python3
"""
JS Analyzer and Triage for Driftwood
Extracts targets, filters noise, and probes endpoints for liveness.
"""
import sys
import re
import requests
from urllib.parse import urljoin
from bs4 import BeautifulSoup


def main():
    if len(sys.argv) != 2:
        print("Usage: ./5-js_triage.py <url>")
        sys.exit(1)
        
    base_url = sys.argv[1].rstrip('/')
    
    try:
        html_resp = requests.get(base_url, timeout=5)
        html_resp.raise_for_status()
    except requests.RequestException:
        print("Error: Could not connect to the target.")
        sys.exit(1)
        
    soup = BeautifulSoup(html_resp.text, 'html.parser')
    
    js_queue = []
    visited_js = set()
    
    for script in soup.find_all('script'):
        src = script.get('src')
        if src:
            js_url = urljoin(base_url, src)
            js_queue.append(js_url)
            
    # 1. Regex Patterns - Filter for Internal Only
    # Matches relative API endpoints
    path_pattern = re.compile(r'[\'"`](/api/[a-zA-Z0-9_/?&={}-]+)[\'"`]')
    # Matches absolute URLs but strictly internal (driftwood.example)
    host_pattern = re.compile(r'https?://([a-zA-Z0-9.-]+\.driftwood\.example)')
    # Matches lazy-loaded JS chunks
    chunk_pattern = re.compile(r'[\'"`]([a-zA-Z0-9_-]+\.js)[\'"`]')
    
    candidates = set()
    
    # 2. Extract Candidates
    while js_queue:
        current_js = js_queue.pop(0)
        
        if current_js in visited_js:
            continue
            
        visited_js.add(current_js)
        
        try:
            js_resp = requests.get(current_js, timeout=5)
            js_text = js_resp.text
        except requests.RequestException:
            continue
            
        # Extract relative paths
        for p in path_pattern.findall(js_text):
            candidates.add(("path", p))
            
        # Extract internal hosts
        for h in host_pattern.findall(js_text):
            candidates.add(("host", h))
            
        # Find more chunks for the queue
        for chunk in chunk_pattern.findall(js_text):
            chunk_url = urljoin(current_js, chunk)
            if chunk_url not in visited_js:
                js_queue.append(chunk_url)
                
    # 3. Triage / Probe for Liveness
    live_results = []
    dead_results = []
    
    for cand_type, cand_val in candidates:
        if cand_type == "path":
            test_url = urljoin(base_url, cand_val)
            display_name = cand_val
        else:
            test_url = f"http://{cand_val}"  # Assuming HTTP for internal lab routing
            display_name = cand_val
