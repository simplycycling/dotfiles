# Investigation Patterns Reference

Deep heuristics and worked patterns for infrastructure archaeology.

## Reading Security Groups as a History Book

Security groups accumulate rules over time. Old rules are rarely deleted. Read them as a timeline:
- Rules with port 22 open to `0.0.0.0/0` suggest a period before bastion or SSM adoption
- Rules referencing specific /32 CIDRs are often developer home IPs — clue that direct access was once common
- Rules with descriptions like "temp", "test", or a name that no longer matches an active team are candidates for removal
- Overlapping rules for the same port from different source CIDRs suggest multiple teams independently added access

## IAM Role Archaeology

IAM roles tell a story of how trust was established over time:
- Roles with no tags and random-looking names were likely created manually through the console
- Roles with structured names (e.g., `prod-eks-node-role`, `data-pipeline-redshift-role`) suggest a period of IaC adoption
- Inline policies attached directly to a role rather than managed policies indicate older manual work — managed policies are easier to audit
- Trust policies that reference external account IDs: check if those accounts still exist and are still owned by your org
- Roles with `AdministratorAccess` attached that aren't clearly for a break-glass scenario are high-risk legacy

## VPC Structure Patterns

- A single large VPC with a flat subnet structure (no public/private split) indicates early-stage or fast-moving infrastructure
- Multiple VPCs peered together often means different teams operated independently before centralisation
- Transit Gateway attachments indicate a deliberate network consolidation effort at some point
- VPCs with overlapping CIDRs that are peered = someone had to work around this with specific routes, look for those routes

## Kubernetes Namespace Signals

| Namespace pattern | Likely origin |
|-------------------|--------------|
| `default` (production workloads in here) | Pre-K8s-maturity, monolith era |
| `team-name-*` | Post-merger team isolation attempt |
| `legacy-*` or `old-*` | Workloads that survived a migration |
| `monitoring`, `logging`, `ingress-nginx` | Standard tooling namespaces |
| Multiple monitoring namespaces | Different companies had different observability stacks |

## RDS Parameter Group Forensics

Non-default parameter group values are clues to past incidents or performance tuning:

| Parameter | If changed from default | Likely reason |
|-----------|------------------------|---------------|
| `max_connections` (Postgres) | Increased | Connection pool exhaustion at some point |
| `log_min_duration_statement` | Set to a value | Past performance investigation |
| `shared_buffers` | Increased | Memory tuning for heavy read workloads |
| `work_mem` | Increased | Complex query or sort performance issues |
| `rds.force_ssl` | Disabled | Legacy app that couldn't handle SSL — tech debt |
| MSSQL `max degree of parallelism` | Set to 1 | Past runaway parallel query incident |

## Reading Redshift WLM Queues

The default WLM config is a single queue with 5 slots. Any deviation from this has a reason:
- Multiple queues with user group or query group routing = past contention between workloads (e.g., ETL vs. BI tools)
- Short query acceleration enabled = history of short queries being blocked by long ones
- Low concurrency per queue = past memory pressure or OOM errors
- Queue with very high memory % allocation = a specific workload (e.g., dbt transforms) that needed isolation

## Merge Artifact Checklist

When you suspect a resource is a merge artifact, check:

- [ ] Is there another resource with a similar name in a different namespace/account/region?
- [ ] Are there two resources that appear to serve the same function but use different tech stacks?
- [ ] Is the resource referenced by any active application or pipeline?
- [ ] Does the cost allocation tag (if present) reference a company/team that no longer exists?
- [ ] Is there a corresponding resource in a different cloud (AWS vs Azure) that does the same thing?
- [ ] Does the resource have any active connections or recent query/access activity?

If the answer to the last two questions is "no", it's a strong candidate for decommissioning — but document it as an ADR before removing.

## The "Why Did They Do That" Decision Tree

When a config choice seems strange:

1. **Was it a workaround?** Look for related resources that explain the constraint (e.g., an unusual routing rule often exists because of a CIDR conflict upstream)
2. **Was it a cost optimisation?** Single-AZ RDS, small instance types, no redundancy — often a fast-moving startup phase trade-off
3. **Was it a compliance requirement?** Unusual encryption settings, audit logging, VPC flow logs to an unusual destination
4. **Was it an incident response?** Over-allocated resources, unusually aggressive alerting thresholds, DR replicas in unexpected regions
5. **Was it copied from somewhere?** Config that matches a well-known blog post or AWS sample — often applied without customisation

## Confluence Search Strategies

When Confluence is hit-or-miss:
- Search for the resource ARN prefix (e.g., `arn:aws:rds`) combined with an environment name
- Search for the service name plus the environment (e.g., `payments-db prod`)
- Search by the likely timeframe — if CloudTrail shows the resource was created in Jan 2022, filter to that period
- Check the space for the team that owned the resource (if tags hint at team ownership)
- Search for the IP address or CIDR of the resource — sometimes referenced in network diagrams
