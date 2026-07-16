"""groundtruth - reusable assessment framework for the Castellan engagement.

Infrastructure (config, scope, transport client, evidence, state, schemas) plus
the phase modules. Each phase script is a thin entry into this package, and
ground_truth.py chains the phases into one run with resume.
"""
__all__ = [
    "config", "scope", "transport", "evidence", "state", "schemas",
    "discovery", "enumeration", "webmap", "bespoke", "intelligence",
    "scoring", "prioritization", "reporting",
]
