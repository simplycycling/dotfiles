---
description: Document an existing infrastructure resource
allowed-tools: Write, Read
argument-hint: [paste a config, manifest, CLI output, or describe the resource]
---

Produce structured documentation for the following infrastructure: $ARGUMENTS

Output the documentation in this format:

---
## [Resource Name / Service]

**Type**: [e.g. EKS Cluster, RDS Postgres, K8s Deployment, Security Group, IAM Role]
**Cloud/Platform**: [AWS | Azure | Kubernetes | Cross-cloud]
**Environment**: [prod | staging | dev | unknown]

### What it does
[2–4 sentences: the function this resource serves and its role in the broader system]

### Configuration notes
[Key non-default settings, unusual parameter values, and relevant dependencies. Be specific — include actual values where provided.]

### Likely decision rationale
[Why this was probably set up this way. Label as "(inferred)" if not explicitly documented. Cross-reference any related ADRs if known.]

### Relationships
[Other resources it depends on or that depend on it. Include direction: "depends on X", "consumed by Y".]

### Risks and tech debt
[Security gaps, missing best practices, legacy workarounds, merge artifacts, consolidation candidates. Be specific and actionable.]

### Open questions
[What couldn't be determined from the available information. These become follow-up tasks.]
---

Rules:
1. Tailor analysis to the fintech stack: AWS (primary), Azure (secondary), EKS, RDS Postgres, RDS MSSQL, Redshift.
2. Flag merge artifacts — patterns suggesting this resource originated from one of three merged companies. Use tag `[MERGE-ARTIFACT]`.
3. Apply tags where relevant: `[LEGACY]` `[MERGE-ARTIFACT]` `[TECH-DEBT]` `[UNDOCUMENTED]`
4. Be specific about risks — "security group allows 0.0.0.0/0 on port 5432" is useful; "security could be improved" is not.
5. If given multiple resources at once (e.g., a manifest with several objects), produce a section for each.
6. If the resource appears straightforward with no risks or open questions, say so explicitly — don't invent problems.

After generating, offer to save as a Markdown file.
