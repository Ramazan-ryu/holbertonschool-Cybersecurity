"""Run manifest + limitations: atomic phase-status tracking for resume."""
import json
import os
import time
from typing import Dict, List

from groundtruth import config


def _now() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


class RunState:
    def __init__(self, outputs_dir: str):
        os.makedirs(outputs_dir, exist_ok=True)
        self.outputs = outputs_dir
        self.manifest_path = os.path.join(outputs_dir, "run_manifest.json")
        self.limitations_path = os.path.join(outputs_dir, "limitations.json")
        self.manifest = self._load()

    def _load(self) -> dict:
        if os.path.exists(self.manifest_path):
            try:
                with open(self.manifest_path) as fh:
                    return json.load(fh)
            except (OSError, ValueError):
                pass
        return {"created": _now(), "updated": _now(),
                "phases": {p: {"status": "pending", "artifact": None,
                               "error": None, "updated": None}
                           for p in config.PHASES}}

    def _atomic_write(self, path: str, obj) -> None:
        tmp = path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(obj, fh, indent=2)
        os.replace(tmp, path)

    def save(self) -> None:
        self.manifest["updated"] = _now()
        self._atomic_write(self.manifest_path, self.manifest)

    def set_status(self, phase: str, status: str, artifact: str = None,
                   error: str = None) -> None:
        entry = self.manifest["phases"].setdefault(
            phase, {"status": "pending", "artifact": None, "error": None})
        entry["status"] = status
        entry["updated"] = _now()
        if artifact is not None:
            entry["artifact"] = artifact
        entry["error"] = error
        self.save()

    def status(self, phase: str) -> str:
        return self.manifest["phases"].get(phase, {}).get("status", "pending")

    def first_incomplete(self) -> str:
        for p in config.PHASES:
            if self.status(p) not in ("complete", "skipped"):
                return p
        return None

    def all_complete(self) -> bool:
        return all(self.status(p) in ("complete", "skipped")
                   for p in config.PHASES)

    def add_limitation(self, phase: str, note: str,
                       to_settle: str = None) -> None:
        lim: List[Dict] = []
        if os.path.exists(self.limitations_path):
            try:
                with open(self.limitations_path) as fh:
                    lim = json.load(fh)
            except (OSError, ValueError):
                lim = []
        lim.append({"phase": phase, "note": note, "to_settle": to_settle,
                    "timestamp": _now()})
        self._atomic_write(self.limitations_path, lim)
