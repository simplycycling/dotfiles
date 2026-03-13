---
description: Generate a MADR Architecture Decision Record
allowed-tools: Write, Read
argument-hint: [title, topic, or paste a config/snippet to infer the decision from]
---

Generate a MADR (Markdown Architectural Decision Records) for: $ARGUMENTS

Use MADR 3.0 format with the following sections:

```
# [Short imperative title — noun phrase describing the decision]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Context and Problem Statement
[2–4 sentences: what situation led to this decision? What problem needed solving?]

## Decision Drivers
- [Key requirement, constraint, or goal]
- ...

## Considered Options
- Option 1: [name]
- Option 2: [name]
- Option 3: [name]

## Decision Outcome
Chosen option: "[option name]", because [concise justification].

## Pros and Cons of the Options

### [Option 1 name]
- Pro: [reason]
- Con: [reason]

### [Option 2 name]
...
```

Rules:
1. If the user provides a config snippet, manifest, CLI output, or describes an existing infrastructure setup rather than a decision topic, **infer** the ADR from the evidence: what problem was being solved, what alternatives likely existed, and why this approach was probably chosen. Clearly label inferred sections with `(inferred)`.
2. The title must be an imperative noun phrase (e.g., "Use IRSA for pod-level AWS permissions" not "IRSA decision").
3. Status defaults to "Accepted" for existing infrastructure, "Proposed" for new decisions.
4. Tailor content to a fintech DevOps context: AWS, Azure, EKS, RDS (Postgres/MSSQL), Redshift, Terraform, Ansible, Azure DevOps.
5. Include at least two considered options — even if one is clearly the right choice, document what was rejected and why.
6. Keep the document concise — ADRs should be readable in under 3 minutes.

After generating, offer to save the ADR as a Markdown file.
