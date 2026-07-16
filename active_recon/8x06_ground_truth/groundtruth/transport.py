"""Client for the low-level training transport.

The Castellan lab uses real application-layer services. Network-layer
reachability for the logical 10.40.0.0/22 estate is exposed through this
low-level training transport because the platform does not grant raw-network
capabilities. The adapter provides probe primitives only; discovery,
classification, orchestration and assessment logic remain yours.
"""
import base64
from typing import Dict, Optional, Tuple

import requests

from groundtruth import config, scope


class TransportError(Exception):
    pass


class OutOfScope(TransportError):
    pass


def _post(path: str, body: dict, timeout: float = 6.0) -> dict:
    url = config.TRANSPORT_URL.rstrip("/") + path
    try:
        r = requests.post(url, json=body, timeout=timeout)
    except requests.RequestException as exc:
        raise TransportError(str(exc))
    data = r.json() if r.content else {}
    if r.status_code == 403:
        raise OutOfScope(data.get("error", "out_of_scope"))
    if r.status_code >= 500:
        raise TransportError(data.get("error", "transport_error"))
    return data


def resolve_host(ip: str) -> Optional[str]:
    if not scope.ip_in_scope(ip):
        raise OutOfScope(ip)
    return _post("/v1/resolve", {"ip": ip}).get("name")


def icmp_probe(ip: str, timeout: float = 2.0) -> bool:
    if not scope.ip_in_scope(ip):
        raise OutOfScope(ip)
    return bool(_post("/v1/icmp", {"ip": ip, "timeout": timeout}).get("alive"))


def tcp_probe(ip: str, port: int,
              timeout: float = 2.0) -> Tuple[bool, Optional[str]]:
    if not scope.ip_in_scope(ip):
        raise OutOfScope(ip)
    out = _post("/v1/tcp", {"ip": ip, "port": port, "timeout": timeout})
    return out.get("state") == "open", out.get("banner")


def service_connect(ip: str, port: int, payload: bytes = b"",
                    timeout: float = 3.0) -> bytes:
    """One safe exchange over a TCP service: send payload, read the reply."""
    if not scope.ip_in_scope(ip):
        raise OutOfScope(ip)
    body = {"ip": ip, "port": port, "timeout": timeout,
            "send_b64": base64.b64encode(payload).decode("ascii")}
    out = _post("/v1/exchange", body)
    return base64.b64decode(out.get("recv_b64") or "")


def udp_probe(ip: str, port: int, payload: bytes,
              timeout: float = 3.0) -> Optional[bytes]:
    if not scope.ip_in_scope(ip):
        raise OutOfScope(ip)
    body = {"ip": ip, "port": port, "timeout": timeout,
            "send_b64": base64.b64encode(payload).decode("ascii")}
    out = _post("/v1/udp", body)
    rb = out.get("recv_b64")
    return base64.b64decode(rb) if rb else None


def http_request(ip: str, host: str, method: str = "GET", path: str = "/",
                 headers: Dict[str, str] = None, body: bytes = b"",
                 port: int = 443, timeout: float = 4.0) -> dict:
    if not scope.ip_in_scope(ip):
        raise OutOfScope(ip)
    if not scope.host_in_scope(host):
        raise OutOfScope(host)
    payload = {
        "ip": ip, "host": host, "method": method, "path": path, "port": port,
        "headers": headers or {}, "timeout": timeout,
        "body_b64": base64.b64encode(body or b"").decode("ascii"),
    }
    out = _post("/v1/http", payload)
    return {
        "status": out.get("status"),
        "headers": out.get("headers", {}),
        "body": base64.b64decode(out.get("body_b64") or ""),
    }
