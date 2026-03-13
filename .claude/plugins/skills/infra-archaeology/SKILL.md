---
name: infra-archaeology
description: >
  This skill should be used when the user wants to "understand what a previous engineer did",
  "figure out why this was set up this way", "document existing infrastructure", "investigate
  legacy configs", "map out the current state", "reverse-engineer a decision", "make sense of
  inherited infrastructure", or needs help untangling infrastructure from a company merger.
  Also triggers for questions like "what does this config do", "why is this here", or
  "what was this resource for" in an AWS, Azure, or Kubernetes context.
version: 0.1.0
---

# Infrastructure Archaeology

Systematically investigate, interpret, and document infrastructure left by previous engineers — especially in merged-company environments where context is sparse and naming conventions are inconsistent.

## Core Principle

Work from evidence to hypothesis. Never assert intent — infer it from configuration, naming patterns, resource relationships, and timing. Document what you find and what you inferred separately. Label inferred content explicitly as "(inferred)".

## Investigation Framework

When approaching an unknown piece of infrastructure, work through four layers:

1. **What exists** — inventory the resources, configs, and relationships
2. **What it does** — understand the function and data flows
3. **Why it was built this way** — infer the decision context from evidence
4. **What risks it carries** — identify gaps, tech debt, or legacy workarounds

## AWS Investigation Patterns

### Starting points
- Resource tags (or absence of them) often reveal which legacy company created a resource
- VPC CIDR blocks may hint at original company network address allocations
- IAM role naming conventions differ per company and team era
- CloudFormation stack names and descriptions (where they exist) can anchor timelines
- CloudTrail logs show who created a resource and when — use this to correlate with company history

### Key services to map first
- **VPC/Networking**: Subnets, routing tables, security groups, VPC peering — draw this before anything else
- **EKS clusters**: Node group configs, addon versions, IRSA role mappings, OIDC provider
- **RDS (Postgres/MSSQL)**: Parameter groups, subnet groups, multi-AZ setting, backup windows, security group ingress rules
- **Redshift**: Cluster config, WLM queues, Spectrum external tables, IAM roles for S3 access
- **IAM**: Inline vs managed policies, cross-account trust relationships, service-linked roles, unused roles

### Merge artifact patterns
When three companies merge, watch for:
- Duplicate resources serving the same purpose (e.g., three separate VPN or bastion setups)
- Overlapping CIDR ranges causing routing workarounds or blackhole routes
- Redundant RDS instances or schemas that were never consolidated
- Multiple logging pipelines coexisting (CloudWatch, Datadog, Splunk, etc.)
- IAM trust relationships referencing accounts that may no longer exist

## Azure Investigation Patterns

- Resource Group naming often encodes team, environment, and project context
- Tags in Azure are less consistently applied than AWS — check Management Group policies for intent
- NSG rules frequently carry legacy wide-open CIDRs with no description added at creation time
- Use the Activity Log to identify who created a resource and approximately when
- Check for orphaned resources: unattached disks, unused public IPs, empty resource groups

## Kubernetes Investigation Patterns

When investigating an unfamiliar cluster:

1. List all namespaces — namespace names reveal team/application decomposition
2. For each namespace, examine: Deployments, Services, ConfigMaps, Secrets (names only — never print secret values), HPA configs, PodDisruptionBudgets, NetworkPolicies
3. Inspect resource requests/limits — missing or zero limits are extremely common legacy debt
4. Check RBAC: ClusterRoleBindings with wildcard verbs or broad cluster-admin grants are red flags
5. Look at Ingress objects — class annotations reveal which ingress controllers are active
6. Run `helm list -A` — release names and chart versions expose deployment history
7. Check image registries across workloads — multiple registries often hint at different origin companies

### kOps-managed clusters (current state)

The production and other clusters are currently managed with kOps, with EKS as the migration target. When investigating a kOps cluster:

- **State store**: kOps stores all cluster config in an S3 bucket (the kOps state store). The bucket name is usually set via `KOPS_STATE_STORE`. Run `kops get clusters` to list known clusters. This is the source of truth — not the live cluster.
- **Cluster spec**: `kops get cluster <cluster-name> -o yaml` reveals the full intended state: networking config (Calico, Weave, Canal, Cilium), K8s version, API server flags, OIDC config, and addon selections. Non-default values here are deliberate decisions worth documenting.
- **Instance groups**: `kops get instancegroups -o yaml` shows node group definitions — machine types, min/max counts, subnets, taints, and labels. Multiple instance groups with taints often indicate workload segregation decisions (e.g., a GPU group, a high-memory group for specific workloads).
- **Addons**: Check `kops get addons` and the cluster spec's `addons` field. Managed addons (metrics-server, cluster-autoscaler, etc.) baked into kOps config vs. those deployed separately via Helm reveal what was considered "core" vs. "optional".
- **IAM**: kOps creates IAM roles for masters and nodes. Check if OIDC/IRSA is configured (`spec.kubeAPIServer.serviceAccountIssuer`) — many kOps clusters predate IRSA and use node-level instance profiles for pod AWS access instead, which is a security gap to document.
- **Networking**: Check `spec.networking` — the CNI choice (Calico, Weave, Canal, Cilium, Amazon VPC) has significant implications for NetworkPolicy support and EKS migration compatibility.
- **Etcd**: kOps manages etcd on master nodes. Check `spec.etcdClusters` for volume sizes and encryption — undersized etcd volumes are a common operational issue.

When comparing kOps intended state vs. live cluster state, run `kops validate cluster` and `kops update cluster --dry-run` to surface drift between the state store spec and what's actually running.

## Database Investigation Patterns

### RDS Postgres
- `pg_stat_activity` for active connections and long-running queries
- `information_schema.tables` and `information_schema.schemata` for schema structure
- Multiple schemas in one database commonly indicate apps that were consolidated at the DB level
- Non-default parameter group values usually indicate past performance tuning — document what was changed

### RDS MSSQL
- `sys.databases` for all databases on the instance
- Login and user mappings via `sys.server_principals` and `sys.database_principals`
- Linked server configs in `sys.servers` often reveal cross-company integrations that were never removed
- SQL Agent jobs in `msdb.dbo.sysjobs` reveal scheduled processes that may be entirely undocumented

### Redshift
- WLM queue config often reflects past query performance problems — each queue tweak has a story
- `svl_query_summary` and `stl_query` for historical query patterns and common query shapes
- Spectrum external tables reference S3 paths that reveal data lake structure and ownership

## Documentation Strategy

For each piece of infrastructure investigated:

1. **Create an infra-doc** — factual record of what exists (use the `/infra-doc` command)
2. **Create an ADR** — record the inferred decision and rationale (use the `/adr` command)
3. **Flag unknowns explicitly** — unresolved questions become follow-up tasks, not assumptions

Use consistent tags in all documentation:
- `[LEGACY-AWS]` — resource predates the GitOps migration
- `[LEGACY-AZURE]` — Azure resource from pre-merger era
- `[LEGACY-K8S]` — Kubernetes workload without clear ownership
- `[KOPS-MANAGED]` — resource or config specific to the kOps-managed cluster; needs EKS migration consideration
- `[MERGE-ARTIFACT]` — likely a duplicate or overlap from the three-company merger
- `[TECH-DEBT]` — known gap that needs resolution
- `[UNDOCUMENTED]` — no Confluence page, ADR, or code comment found

## When Context Is Missing

If you cannot find documentation and cannot infer intent:
- Search Confluence for the resource name, service name, or ARN/ID fragments
- Check Azure DevOps commit history for any config files referencing the resource
- Look for related CloudWatch alarms, dashboards, or cost allocation tags
- Check whether the resource appears in any Azure DevOps deployment pipelines
- Look at who the resource is tagged to or billed against

See `references/investigation-patterns.md` for deeper heuristics and worked examples.
