# 8x06 - Ground Truth (Module 8 capstone)

You run a full vulnerability assessment of the Castellan Energy estate, end to
end, as a sequence of phases that each feed the next. Every phase is a tool YOU
build that emits a structured artifact; the assessment console visualises your
artifacts but is never the source of truth.

## Phases / deliverables (you write these)
  1-discover_estate.py     estate_map.json
  2-enumerate_services.py  enumeration_findings.json
  3-map_web_surface.py     web_surface.json
  4-assess_bespoke.py      bespoke_assessment.json
  5-intel_layer.py         intel_findings.json
  6-verify_findings.py     verified_findings.json
  7-prioritize_risk.py     risk_register.json + .csv
  8-vulnerability_assessment_report.md
  ground_truth.py          the integrated orchestrator (run/phase/resume/...)

## The transport (read reference/TRANSPORT_API.md)
The estate uses real application-layer services. Network-layer reachability for
the logical 10.40.0.0/22 estate is exposed through a low-level training
transport because the platform does not grant raw-network capabilities. The
adapter provides probe PRIMITIVES only (icmp/tcp/udp/exchange/http/resolve);
discovery, classification, orchestration and assessment remain your work. Use
the framework in `groundtruth/` (config, scope, transport, evidence, state,
schemas) to build on.

## Scope
  10.40.0.0/22   castellan.example   *.castellan.example
Everything else is out of scope; record it, never follow it.

Tasks 0 and 9-12 are completed on the intranet, not here.
