"""JSON-schema loading and artifact validation."""
import json
import os
from typing import Dict

try:
    import jsonschema
except ImportError:  # validation degrades gracefully
    jsonschema = None

ARTIFACT_SCHEMA = {
    "estate_map.json": "estate_map.schema.json",
    "enumeration_findings.json": "enumeration_findings.schema.json",
    "web_surface.json": "web_surface.schema.json",
    "bespoke_assessment.json": "bespoke_assessment.schema.json",
    "intel_findings.json": "intel_findings.schema.json",
    "verified_findings.json": "verified_findings.schema.json",
    "risk_register.json": "risk_register.schema.json",
    "run_manifest.json": "run_manifest.schema.json",
}


def _schema_dir() -> str:
    env = os.environ.get("GROUND_TRUTH_SCHEMAS")
    if env and os.path.isdir(env):
        return env
    here = os.path.dirname(os.path.abspath(__file__))
    for cand in (os.path.join(os.getcwd(), "reference", "schemas"),
                 os.path.join(here, "..", "..", "datasets", "schemas"),
                 "/opt/active-recon-target/datasets/schemas"):
        if os.path.isdir(cand):
            return cand
    return ""


def validate_artifact(artifact_name: str, outputs_dir: str) -> Dict:
    path = os.path.join(outputs_dir, artifact_name)
    if not os.path.exists(path):
        return {"artifact": artifact_name, "exists": False, "valid": None}
    try:
        with open(path) as fh:
            data = json.load(fh)
    except (OSError, ValueError) as exc:
        return {"artifact": artifact_name, "exists": True, "valid": False,
                "error": "invalid json: %s" % exc}
    schema_name = ARTIFACT_SCHEMA.get(artifact_name)
    sd = _schema_dir()
    if not jsonschema or not schema_name or not sd:
        return {"artifact": artifact_name, "exists": True, "valid": True,
                "note": "schema check skipped"}
    spath = os.path.join(sd, schema_name)
    if not os.path.exists(spath):
        return {"artifact": artifact_name, "exists": True, "valid": True,
                "note": "no schema"}
    with open(spath) as fh:
        schema = json.load(fh)
    try:
        jsonschema.validate(data, schema)
        return {"artifact": artifact_name, "exists": True, "valid": True}
    except jsonschema.ValidationError as exc:
        return {"artifact": artifact_name, "exists": True, "valid": False,
                "error": exc.message}


def validate_all(outputs_dir: str) -> Dict:
    return {name: validate_artifact(name, outputs_dir)
            for name in ARTIFACT_SCHEMA}
