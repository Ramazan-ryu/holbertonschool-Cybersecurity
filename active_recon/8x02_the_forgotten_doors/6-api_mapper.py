#!/usr/bin/python3
"""
API Mapper for Driftwood
Infers undocumented endpoints, methods, and structure.
"""
import sys
import re
import requests
from urllib.parse import urlparse


def discover_methods(url):
    """Discover which HTTP methods each route honors versus rejects."""
    all_methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS']
    honors = []
    rejects = []
    
    for method in all_methods:
        try:
            resp = requests.request(method, url, timeout=5)
            # 405 Method Not Allowed or 501 Not Implemented means the method is rejected
            if resp.status_code in [405, 501]:
                rejects.append(method)
            elif resp.status_code != 404:
                honors.append(method)
        except requests.RequestException:
            pass
            
    return ", ".join(honors)


def extract_structure(response_json, base_path):
    """Read response structure for objects that name routes you have not seen."""
    unseen_objects = set()
    json_string = str(response_json)
    
    # Regex to find paths matching the API shape inside the JSON structure
    shape_pattern = re.compile(rf"({base_path}/[a-zA-Z0-9_/-]+)")
    for match in shape_pattern.findall(json_string):
        unseen_objects.add(match)
        
    return unseen_objects


def main():
    if len(sys.argv) < 2:
        print("Usage: ./6-api_mapper.py <api_base_url> [wordlist]")
        sys.exit(1)
        
    base_url = sys.argv[1].rstrip('/')
    # Use the lab's small wordlist if a second argument isn't passed
    wordlist_path = sys.argv[2] if len(sys.argv) > 2 else "content-small.txt"
    
    parsed = urlparse(base_url)
    base_path = parsed.path
    
    try:
        with open(wordlist_path, 'r') as f:
            words = f.read().splitlines()
    except FileNotFoundError:
        print(f"Error: Wordlist '{wordlist_path}' not found.")
        sys.exit(1)

    sibling_routes = set()
    
    # Start with the known endpoint from Task 4
    known_endpoint = f"{base_path}/internal/exports"
    sibling_routes.add(known_endpoint)
    
    # Enumerate sibling routes following the same naming shape
    for word in words:
        sibling_routes.add(f"{base_path}/internal/{word}")
        
    discovered_api = {}
    queue = list(sibling_routes)
    visited = set()
    
    while queue:
        current_route = queue.pop(0)
        
        if current_route in visited:
            continue
            
        visited.add(current_route)
        target_url = f"{parsed.scheme}://{parsed.netloc}{current_route}"
        
        try:
            resp = requests.get(target_url, timeout=5)
            
            # Check if route exists and is not a fossil
            if resp.status_code not in [404, 410]:
                
                # Discover honored methods
                supported_methods = discover_methods(target_url)
                
                # Tag it based on whether it was known from JS
                is_undocumented = "(undocumented)" if current_route != known_endpoint else ""
                discovered_api[current_route] = (supported_methods, is_undocumented)
                
                # Read response structure to find deeper routes
                try:
                    json_data = resp.json()
                    unseen_routes = extract_structure(json_data, base_path)
                    
                    for unseen in unseen_routes:
                        if unseen not in visited:
                            queue.append(unseen)
                except ValueError:
                    pass # Not valid JSON
                    
        except requests.RequestException:
            continue

    # Print the mapped API structure
    for route in sorted(discovered_api.keys()):
        methods, tag = discovered_api[route]
        if tag:
            print(f"[+] {route:<28} {methods:<14} {tag}")
        else:
            print(f"[+] {route:<28} {methods}")


if __name__ == "__main__":
    main()
