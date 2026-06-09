# MedDefense Vendor Evaluation Brief

## Purpose
This evaluation brief provides a metrics-driven selection recommendation for our primary Security Operations Center analyst surface based on cross-platform investigative exercises. By analyzing empirical time-to-first-answer measurements and action-count data, we define the optimal platform selection for clinical infrastructure visibility.

## Evaluation Methodology
The assessment process was evaluated across six scenarios selected specifically to target distributed infrastructure environments. Each of these six scenarios was investigated across two distinct workflows: a low-level Command Line Interface (CLI) surface using native streaming utilities like `jq`, and a centralized Wazuh Export platform mapping pre-indexed schemas. We recorded time-to-first-answer in elapsed seconds, total analyst actions required to construct finding ledgers, and index field transparency to minimize investigative bias.

## Findings Summary
The aggregate dataset derived from `workflow_comparison.json` proves significant operational variances across our detection ecosystem. The CLI pipeline required a total of 928 seconds across all evaluated datasets, resulting in an average investigation velocity of 232 seconds, a median velocity of 247 seconds, and an administrative cost of 39 standalone manual analyst actions. In contrast, the Wazuh Export interface achieved an aggregate time of 788 seconds, reducing the average investigation time to 197 seconds and the median duration to 193 seconds, while lowering administrative friction to 22 actions. This indicates an aggregate velocity advantage for pre-indexed export schemas, saving 140 seconds of total investigative time per incident cycle.

## Strengths and Weaknesses per Interface
The CLI framework provides notable technical elasticity when streaming raw unparsed log arrays or performing complex inline matching across unstructured elements. As shown in `tradeoff_table.json`, a clear strength of the CLI is its superior pipeline expressiveness, allowing a single nested query join to bypass secondary asset categorization structures. However, its primary weakness is its strict reliance on text-speed iteration, which heavily inflates analyst action counts and induces structural bottlenecks when processing large distributed volumes without uniform indexing properties. 
Conversely, the Wazuh Export model demonstrates massive efficiency gains as its core strength due to native field surfacing and uniform index normalization. The primary weakness of the export dashboard interface arises when a target log lacks essential context mappings, forcing the analyst to break dashboard workflows and execute secondary fallback lookups against decoupled data sets.

## Recommendation
The Wazuh Export interface is selected as our primary analyst surface due to its optimized schema normalization and reduced administrative action metrics. The CLI interface must be maintained as a secondary fallback surface specifically reserved for hunting advanced persistent threats within non-indexed data dumps or analyzing complex network traffic telemetry that falls outside standard schema structures.

## Operational Risks of Being Wrong
* Risk 1: Forcing analysts to manually decouple and parse complex multi-stage event streams via the CLI for standard compliance events induces an estimated burden of 15 additional analyst hours per week in redundant querying overhead.
* Risk 2: Over-reliance on visual dashboards when resolving undocumented alert fields generates localized analysis blind spots, escalating critical incident resolution latency by an estimated 12 analyst hours per week.
* Risk 3: Misaligned interface deployment increases structural maintenance overhead and log parsing fragmentation across teams, generating technical debt equivalent to 10 analyst hours per week.

## Security+ 4.7 Considerations
The selection strategy directly addresses core security infrastructure principles including automation, efficiency, scaling, complexity, cost, and technical debt. Utilizing pre-indexed export dashboards minimizes analytical complexity and operational cost, while scaling automation across identical endpoints without accumulating engineering debt.

## Next Steps
1. The detection engineering team must translate existing legacy rules into normalized platform schemas.
2. The compliance team must review cross-platform storage profiles to guarantee multi-year log retention requirements.
3. The SOC manager must establish baseline training paths to unify analytical workflows across tiers.
