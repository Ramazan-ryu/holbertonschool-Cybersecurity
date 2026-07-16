"""Reusable scope guard (student-side mirror of the engagement scope).

The transport backend enforces scope independently; this lets your tooling
refuse to even form an out-of-scope request, recording it instead.
"""
import ipaddress
import re
from typing import Iterator, List

SCOPE_CIDR = ipaddress.ip_network("10.40.0.0/22")
DOMAIN_ROOT = "castellan.example"
_HOST_RE = re.compile(r"^(?:[a-z0-9-]+\.)*castellan\.example$", re.I)


def ip_in_scope(ip: str) -> bool:
    try:
        return ipaddress.ip_address(ip) in SCOPE_CIDR
    except ValueError:
        return False


def host_in_scope(host: str) -> bool:
    if not host:
        return False
    host = host.split(":")[0].strip().lower()
    return host == DOMAIN_ROOT or bool(_HOST_RE.match(host))


def hosts(cidr: str = None) -> List[str]:
    net = ipaddress.ip_network(cidr) if cidr else SCOPE_CIDR
    return [str(h) for h in net.hosts()]


def iter_scope(cidr: str = None) -> Iterator[str]:
    net = ipaddress.ip_network(cidr) if cidr else SCOPE_CIDR
    for h in net.hosts():
        yield str(h)
