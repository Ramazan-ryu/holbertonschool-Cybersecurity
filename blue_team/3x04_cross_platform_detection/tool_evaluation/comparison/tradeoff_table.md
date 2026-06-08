# Cross-Platform Interface Trade-off Analysis Matrix

| Scenario ID | Faster Interface | Time Delta (s) | Action Delta | Operational Advantage Cause |
|---|---|---|---|---|
| anchor_scenario | CLI | -120 | -5 | text_speed_iteration |
| scenario_a | wazuh_export | -19 | -3 | native_field_surface |
| scenario_b | wazuh_export | -20 | -2 | filter_bar_efficiency |
| scenario_c | CLI | -18 | -4 | pipeline_expressiveness |

### Operational Takeaways
* **CLI Advantage**: High execution speeds when dealing with raw streaming formats or unparsed nested elements requiring regex filtering or custom sub-string matches (`jq` parsing pipelines).
* **Wazuh Export Advantage**: Accelerated timeline synthesis when fields are pre-indexed and normalized to the Elastic/Wazuh document schema layer.
