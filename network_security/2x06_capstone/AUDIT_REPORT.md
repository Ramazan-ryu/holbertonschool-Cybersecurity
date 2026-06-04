# LogiCorp Gateway Audit Report

**Auditor:** [Your Name]  
**Date:** [YYYY-MM-DD]  
**Target:** LogiCorp Gateway  

---

## 1. System Information

| Item | Observed State |
|------|----------------|
| OS Version | `$(cat /etc/os-release)` |
| Kernel Version | `$(uname -r)` |
| Hostname | `$(hostname)` |
| Uptime | `$(uptime -p)` |

---

## 2. Network Topology

### Interfaces & IP Addresses

| Interface | IP Address | Netmask | Status |
|-----------|------------|---------|--------|
| eth0 | `$(ip addr show eth0 | grep 'inet ' | awk '{print $2}')` | [Fill] | UP |
| eth1 | [Fill] | [Fill] | [Fill] |

### Routing Table

```bash
$(ip route)
