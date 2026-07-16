# Transport API (neutral)

`from groundtruth import transport` gives probe primitives that enforce scope:
  resolve_host(ip) -> name|None
  icmp_probe(ip) -> bool
  tcp_probe(ip, port) -> (open: bool, banner: str|None)
  service_connect(ip, port, payload=b"") -> bytes   # one safe send/recv
  udp_probe(ip, port, payload) -> bytes|None
  http_request(ip, host, method, path, headers, body, port) -> dict
Primitives only. No host list, no estate map, no answers. You choose scope
iteration, ports, concurrency, parsing, classification and evidence.
