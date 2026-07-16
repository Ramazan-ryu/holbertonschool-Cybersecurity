"""Append-only evidence log (outputs/evidence.jsonl).

Every observation that backs a finding is recorded as an evidence event, so the
final findings are traceable. No secrets are recorded.
"""
import json
import os
import time
import uuid
from typing import Optional


class EvidenceLog:
    def __init__(self, outputs_dir: str):
        os.makedirs(outputs_dir, exist_ok=True)
        self.path = os.path.join(outputs_dir, "evidence.jsonl")

    def record(self, phase: str, asset: str, action: str, observation,
               confidence: float = 1.0, source: str = "live",
               artifact: Optional[str] = None) -> str:
        event = {
            "event_id": "E-" + uuid.uuid4().hex[:10],
            "phase": phase,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "asset": asset,
            "action": action,
            "observation": observation,
            "confidence": round(float(confidence), 2),
            "source": source,
            "artifact": artifact,
        }
        with open(self.path, "a", encoding="utf-8") as fh:
            fh.write(json.dumps(event) + "\n")
        return event["event_id"]
