# Enumeration Report, Driftwood
For: Ridgeline web testing team

## 1. Executive summary
The Driftwood application presents a segmented but highly interconnected attack surface. While the public-facing application relies on a catch-all routing mechanism to obscure content, active reconnaissance revealed three primary environments: a public front, a CMS-driven marketing site, and a hidden administrative/development virtual host. The most critical operational risk stems from the administrative vhost, which exposes undocumented API endpoints through client-side JavaScript bundles. These endpoints honor a hidden authorization-relevant parameter that lacks proper access control. All findings below are marked as either **confirmed** (behavior verified through non-destructive testing) or **identified** (flagged as notable but not pursued further, left for the next phase).

## 2. Mapped surface

**Virtual Hosts**
* `admin-dev.driftwood.example` — **confirmed**. Administrative/development surface, inaccessible without explicit Host header routing; not reachable through default vhost resolution.
* `blog.driftwood.example` — **confirmed**. CMS-driven marketing site, publicly routable.

**Content Directories**
* `/partner-portal` — **confirmed**, discovered by defeating soft-404 baselines.
* `/partner-portal/uploads/` — **confirmed**, child of the above; returns a directory listing distinct from the soft-404 baseline.

**JavaScript-derived endpoints and keys**
* `4-js_recon.py` parsed both the main bundle and lazy-loaded chunks on the admin-dev vhost. It surfaced two internal API paths (below) and one third-party analytics key, which was **identified** as out-of-scope (belongs to an external vendor domain, not Driftwood infrastructure) and not investigated further. No Driftwood-owned secrets or credentials were found hardcoded in the bundles examined.
* `5-js_triage.py` confirmed both extracted paths were live; a third path found in a chunk (`/api/v2/internal/legacy-export`) returned a persistent connection-refused and is **identified** as a fossil (dead reference, not a live route).

**API Endpoints and Methods**
* `/api/v2/internal/exports` — **confirmed** live via JS chunk reference. `6-api_mapper.py` confirmed `GET` and `POST` are accepted; `PUT`, `DELETE`, and `PATCH` return 405.
* `/api/v2/internal/users` — **confirmed** as an undocumented sibling route via naming-convention inference. `6-api_mapper.py` confirmed `GET` and `PATCH` are accepted; `POST`, `PUT`, and `DELETE` return 405.

**Parameters**
* `role` (on `/api/v2/internal/users`, `PATCH`) — **confirmed** honored; `7-param_finder.py` measured a response length and status-code delta when varying this value, indicating the backend reads and acts on it without an accompanying authorization check.
* `/api/v2/internal/exports` was fuzzed with the same wordlist against both `GET` and `POST`; no additional honored parameters were found on this endpoint (baseline held steady across the tested list) — **identified** as clean, not a finding.
* `include_disabled` (on `/api/v2/internal/users`, `GET`) — **identified**, produced a minor response-length shift but inconsistent across repeat requests; flagged as inconclusive and left unexploited pending manual verification.

**CMS (blog.driftwood.example)**
* User `editor.jdoe` — **confirmed** via `8-cms_enum.py` user enumeration.
* No other valid usernames were confirmed from the tested wordlist; enumeration coverage is therefore partial, not exhaustive (see Limitations).
* Plugin `booking-widget` v2.3.1 — **confirmed**, exact version pinned via asset hash comparison.
* Two additional plugins were detected active (`gallery-lite`, `contact-forms`) but `8-cms_enum.py` could not pin exact versions for either — **identified**, version left unconfirmed and out of scope for this pass.

## 3. Tooling
All scripts are self-contained and safe to re-run against the same targets to reproduce these results.

* **`1-discovery_engine.py`** — Bypasses soft-404s by generating mathematical baselines for nonexistent paths, then flags real responses that deviate from that baseline. Run: `./1-discovery_engine.py <url> <wordlist>`
* **`2-recursive_discovery.py`** — Descends into directories found by the discovery engine and infers likely file extensions from technology headers (e.g. server/framework fingerprints). Run: `./2-recursive_discovery.py <url> <wordlist>`
* **`3-vhost_finder.py`** — Discovers hidden routing configurations by fuzzing the Host header against a fixed IP and diffing response bodies/status codes. Run: `./3-vhost_finder.py <domain> <ip> <wordlist>`
* **`4-js_recon.py`** — Parses JS bundles and lazy-loaded chunks for hidden API paths and hardcoded keys/tokens. Run: `./4-js_recon.py <url>`
* **`5-js_triage.py`** — Filters out third-party/external noise from JS recon output and probes remaining endpoints for liveness, separating live routes from fossils. Run: `./5-js_triage.py <url>`
* **`6-api_mapper.py`** — Infers API structure by testing sibling routes and enumerating which HTTP methods each confirmed endpoint accepts. Run: `./6-api_mapper.py <api_url> <wordlist>`
* **`7-param_finder.py`** — Fuzzes parameters per endpoint/method pair and detects baseline behavioral changes (response length, status code) to confirm which inputs are actually read by the backend. Run: `./7-param_finder.py <endpoint_url> <wordlist>`
* **`8-cms_enum.py`** — Enumerates CMS usernames and fingerprints exact plugin versions where possible, to support local vulnerability lookups. Run: `./8-cms_enum.py <url>`
* **`9-chain.py`** — Orchestrates scripts 1 through 8 in sequence, from vhost discovery to parameter confirmation, and prints a single consolidated attack path. Run: `./9-chain.py`

## 4. The chain
Each link below only exists because the previous one was found first; none of these were independently guessable.

1. **Vhost Discovery** — `3-vhost_finder.py` fuzzed the Host header and surfaced `admin-dev.driftwood.example`, a name that returns no content under normal browsing and is absent from any public link, sitemap, or robots.txt.
2. **JS Extraction** — With the vhost in hand, `4-js_recon.py` retrieved that vhost's frontend bundle specifically (the same bundle is not served on the public vhost) and mined it for internal paths, surfacing `/api/v2/internal/exports`. Without step 1, this bundle would never have been fetched.
3. **API Mapping** — `6-api_mapper.py` took that one known path and tested naming-convention siblings, surfacing the undocumented `/api/v2/internal/users` route — a path that appears nowhere in the JS bundle itself.
4. **Parameter Fuzzing** — `7-param_finder.py` fuzzed `/api/v2/internal/users` (now known to accept `PATCH`) and identified `role` as honored by the backend, evidenced by a measurable response delta.
5. **Confirmation** — The behavioral delta was reproduced consistently across repeat requests with varying `role` values, confirming the parameter is read and acted upon without a corresponding authorization check. No write was performed against another user's data; the finding stops at confirmation of the missing check, per scope.

## 5. Methodology and limitations

**Methodology:** We adhered strictly to an "enumerate and confirm" discipline throughout. A finding was only marked **confirmed** when a tool produced a reproducible behavioral signal (response length/status delta, consistent liveness, or a verifiable version fingerprint). Anything that only looked notable — an inconsistent delta, an out-of-scope key, an unpinned plugin version — was marked **identified** and explicitly left unexploited rather than pursued or assumed.

**Limitations:**
* `1-` and `2-discovery_engine.py`/`recursive_discovery.py` rely on baseline math and header-based extension inference; content behind authentication, or served with no distinguishing headers, would not be surfaced by this pass.
* `3-vhost_finder.py` only tests Host header values present in its wordlist; vhosts using naming patterns outside that list would remain hidden.
* `4-js_recon.py` only inspects bundles and chunks that were actually loaded during the crawl; code paths gated behind login, feature flags, or lazy-loaded on user interaction we didn't trigger are outside its coverage — meaning additional hidden endpoints or keys may exist in code we never fetched.
* `6-api_mapper.py` tests HTTP methods against a fixed list; nonstandard or custom methods would not be detected, and it cannot infer required request bodies or headers for endpoints that reject requests without them.
* `7-param_finder.py` performs single-parameter fuzzing against standard naming conventions. Endpoints requiring chained parameters, specific JSON body structures, or multi-step state (e.g. a value that only becomes honored after a prior request sets session state) may hide parameters this pass could not surface. The `include_disabled` inconsistency noted above is a candidate for exactly this kind of blind spot.
* `8-cms_enum.py` enumeration is wordlist-bound; usernames or plugins outside that list, and any component that doesn't expose a version fingerprint via asset hashing, will not be found or will be reported as unconfirmed rather than absent.
* Across all tooling, any backend behavior that doesn't reflect back to the HTTP client (fully blind server-side effects) is outside the scope of this engine and this report.
