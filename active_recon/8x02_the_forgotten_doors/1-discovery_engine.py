# Abstract pseudocode - not a functional tool
def create_baseline(target_url):
    fake_path = generate_random_string()
    response = make_http_request(target_url + "/" + fake_path)
    
    signature = {
        "status": response.status_code,
        "base_length": len(response.text) - len(fake_path), # Adjusting for reflection
        "content_hash": hash(response.text)
    }
    return signature

def analyze_path(response, path, signature):
    if response.status_code != signature["status"]:
        return True # Finding: Status change
        
    adjusted_length = len(response.text) - len(path)
    if abs(adjusted_length - signature["base_length"]) > TOLERANCE_THRESHOLD:
        return True # Finding: Content length drastically different
        
    return False # Matches soft-404 signature
