# Containment Execution: IR-2026-0414-01

## 1. Containment Action Log
Each executed action is recorded below with its timestamp, actor, command or console action, expected result, observed result, and deviation notes:

- timestamp | actor | command or console action | expected result | observed result | deviation notes
- 2026-04-14T03:16:04Z | Network Admin | switchport VLAN reassign WST-WS-031 -> VLAN 999 | host reachable only from jumpbox | confirmed via ping from SOC jumpbox; timeout from user VLAN | no deviation
- 2026-04-14T03:17:21Z | Firewall Admin | firewall deny outbound ip 185.220.101.47 | no new netflow to 185.220.101.47 after 03:17 | netflow and packet capture confirmed zero packets to 185.220.101.47 from 03:17:21Z onward | no deviation
- 2026-04-14T03:18:10Z | Firewall Admin | firewall deny outbound ip 193.56.28.14 | no new netflow to 193.56.28.14 after 03:18 | netflow and packet capture confirmed zero packets to 193.56.28.14 from 03:18:10Z onward | no deviation
- 2026-04-14T03:19:02Z | IR Analyst | endpoint device containment flag SET on WST-WS-031 | only analyst tooling permitted outbound | confirmed endpoint containment status in endpoint console | no deviation
- 2026-04-14T03:22:04Z | IR Analyst | verify isolation | ping from user VLAN fails, ping from jumpbox succeeds | verified host isolation and jumpbox-only verification successfully | no deviation

## 2. Targeted Infrastructure Assets
This containment execution covers the following mandated environment scopes:
1. WST-WS-031 (Compromised Windows Workstation)
2. WST-WS-017 (Adjacent Triage Workstation)
3. LIS-WSIDE-01 (Laboratory Information System Node)
4. Network Core Switch Cluster (Boundary Interface)
5. Corporate Perimeter Firewall Array (Egress Control Edge)
