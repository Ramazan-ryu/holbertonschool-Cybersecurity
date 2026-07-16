# Output contracts (neutral)

  outputs/estate_map.json          hosts[].{ip,name,role,ports[]}, summary
  outputs/enumeration_findings.json [{asset,service,finding,evidence}]
  outputs/web_surface.json         {baseline, surface[]}
  outputs/bespoke_assessment.json  {service,fingerprint,finding,stopped_at}
  outputs/intel_findings.json      [{merged_id,asset,sources,classification,verdict}]
  outputs/verified_findings.json   [{finding,class,verdict,evidence,stopped_at}]
  outputs/risk_register.json/.csv  ranked register
  outputs/run_manifest.json        phase status; outputs/evidence.jsonl events
Emit machine-readable output from code; never hand-author artifacts.
