"""Shared configuration and paths for the groundtruth framework."""
import os

TRANSPORT_URL = os.environ.get("CASTELLAN_TRANSPORT", "http://127.0.0.1:8090")

PHASES = [
    "discovery", "enumeration", "webmap", "bespoke",
    "intelligence", "verification", "prioritization", "report",
]

ARTIFACT_BY_PHASE = {
    "discovery": "estate_map.json",
    "enumeration": "enumeration_findings.json",
    "webmap": "web_surface.json",
    "bespoke": "bespoke_assessment.json",
    "intelligence": "intel_findings.json",
    "verification": "verified_findings.json",
    "prioritization": "risk_register.json",
    "report": None,
}


def workspace_root() -> str:
    env = os.environ.get("GROUND_TRUTH_WS")
    if env:
        return env
    return os.getcwd()


def outputs_dir(override: str = None) -> str:
    if override:
        return override
    return os.path.join(workspace_root(), "outputs")


def reports_dir(override: str = None) -> str:
    return override or os.path.join(workspace_root(), "reports")


def context_dir(override: str = None) -> str:
    return override or os.path.join(workspace_root(), "context")


def default_scope() -> str:
    return "10.40.0.0/22"


def default_domain() -> str:
    return "castellan.example"
