# CVSS version notes (neutral)

Vectors come in CVSS:3.1/ and CVSS:4.0/ forms; detect by prefix and branch. v4.0
splits impact into VC/VI/VA and SC/SI/SA and retires Scope. Environmental metrics
(CR/IR/AR + modified base) carry the asset context. Preserve the base score;
compute environmental from the asset-criticality model. Severity is not risk.
