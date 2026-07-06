# Enumeration Report, Driftwood
For: Ridgeline web testing team

## 1. Executive summary
The Driftwood application presents a segmented but highly interconnected attack surface. While the public-facing application relies on a catch-all routing mechanism to obscure content, active reconnaissance revealed three primary environments: a public front, a CMS-driven marketing site, and a hidden administrative/development virtual host. The most critical operational risk stems from the administrative vhost, which exposes undocumented API endpoints through client-side JavaScript bundles. These endpoints honor hidden parameters that lack proper authorization controls.

## 2. Mapped surface
* **Virtual Hosts:** `admin-dev.driftwood.example` (administrative/development surface, inaccessible without explicit Host header routing).
* **Content Directories:** `/partner-portal` and `/partner-portal/uploads/` (discovered by defeating soft-404s).
* **API Endpoints:** `/api/v2/internal/exports` (identified via JS chunks) and `/api/v2/internal/users` (undocumented sibling route).
* **Parameters:** `role` (honored by the `/users` endpoint, exhibiting authorization-relevant behavioral changes).
* **CMS (blog.driftwood.example):** Identified user `editor.jdoe` and pinned plugin `booking-widget` version `2.3.1`.

## 3. Tooling
* **1-discovery_engine.py:** Bypasses soft-404s by generating mathematical baselines for nonexistent paths. Run: `./1-discovery_engine.py <url> <wordlist>`
* **2-recursive_discovery.py:** Descends into discovered directories and infers file extensions based on technology headers. Run: `./2-recursive_discovery.py <url> <wordlist>`
* **3-vhost_finder.py:** Discovers hidden routing configurations by fuzzing the Host header and monitoring response differentials. Run: `./3-vhost_finder.py <domain> <ip> <wordlist>`
* **4-js_recon.py:** Parses JS bundles and lazy-loaded chunks for hidden API paths and hardcoded keys. Run: `./4-js_recon.py <url>`
* **5-js_triage.py:** Filters out external noise and probes extracted JS endpoints for liveness (identifying fossils). Run: `./5-js_triage.py <url>`
* **6-api_mapper.py:** Infers API structure by testing sibling routes and discovering supported HTTP methods. Run: `./6-api_mapper.py <api_url> <wordlist>`
* **7-param_finder.py:** Fuzzes parameters and detects baseline behavioral changes (length/status) to confirm honored inputs. Run: `./7-param_finder.py <endpoint_url> <wordlist>`
* **8-cms_enum.py:** Enumerates users and parses exact CMS plugin versions for local vulnerability orchestration. Run: `./8-cms_enum.py <url>`
* **9-chain.py:** Automates the complete attack path from vhost to confirmation. Run: `./9-chain.py`

## 4. The chain
The reconnaissance pipeline successfully linked seemingly isolated findings into a cohesive attack path:
1. **Vhost Discovery:** Identified `admin-dev.driftwood.example` by bypassing default server routing.
2. **JS Extraction:** Mined the vhost's frontend code to discover the internal `/api/v2/internal/exports` endpoint.
3. **API Mapping:** Extrapolated the API structure to find the undocumented sibling route `/api/v2/internal/users`.
4. **Parameter Fuzzing:** Discovered the hidden `role` parameter on the `/users` endpoint.
5. **Confirmation:** Confirmed missing authorization on the `role` parameter without exploiting it.

## 5. Methodology and limitations
* **Methodology:** We strictly adhered to the "enumerate and confirm" discipline. Misconfigurations were identified through behavioral changes (response differentials, length variances, status shifts) rather than active exploitation. We identified parameters as injectable-looking or authorization-relevant and stopped immediately upon confirmation.
* **Limitations:** The automated mapping relies on single-parameter fuzzing and standard naming conventions. Complex endpoints requiring specific JSON body structures, chained parameters, or multi-step state transitions may remain undiscovered. Furthermore, backend components that do not reflect behavioral changes to the HTTP client (blind vulnerabilities) are outside the scope of this engine.
