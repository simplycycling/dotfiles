---
description: Review Kubernetes manifests for security, resources, and best practices
allowed-tools: Read, Glob, Grep
argument-hint: [file path, directory, or paste manifest YAML]
---

Review the following Kubernetes manifest(s): $ARGUMENTS

If a file path or directory is provided, read the files. If YAML is pasted directly, analyse it as provided.

Perform a structured review across three categories. For each finding provide:
- **Severity**: Critical / Warning / Info
- **Location**: resource kind + name + field path
- **Issue**: what the problem is
- **Fix**: recommended change, with example YAML where it clarifies the fix

---

## Security

- [ ] No containers running as root — check `securityContext.runAsNonRoot: true` and `runAsUser` is not 0
- [ ] No `privileged: true` or `allowPrivilegeEscalation: true` in container securityContext
- [ ] Read-only root filesystem where feasible: `readOnlyRootFilesystem: true`
- [ ] Capabilities: `drop: ["ALL"]` present, and only genuinely required capabilities added back
- [ ] No plaintext secret values in ConfigMaps — secrets must be in Secret objects
- [ ] Secret objects not mounted unnecessarily — check for wildcard env injection (`envFrom: - secretRef`)
- [ ] RBAC: flag wildcard verbs (`verbs: ["*"]`), cluster-admin bindings, or bindings that apply to `system:authenticated`
- [ ] NetworkPolicies: check if the namespace has ingress AND egress policies; flag if none exist
- [ ] Image tags: flag `latest` or any mutable tag — production workloads should use digest-pinned images
- [ ] ImagePullPolicy: flag `Always` on high-traffic workloads (performance); require for `latest` tags (correctness)
- [ ] ServiceAccount: flag `automountServiceAccountToken: true` on workloads that don't need API access

## Resource Management

- [ ] Every container has CPU and memory `requests` AND `limits` defined
- [ ] Limits are not set to unreasonably high values that defeat bin-packing (e.g., 32Gi memory limit on a utility container)
- [ ] HorizontalPodAutoscaler defined for stateless workloads
- [ ] PodDisruptionBudget defined for workloads in production namespaces
- [ ] `topologySpreadConstraints` or `podAntiAffinity` for workloads requiring HA across zones
- [ ] Init containers also have resource requests/limits
- [ ] No `resources: {}` (empty resources block) — this is equivalent to no limits

## Best Practices and Anti-patterns

- [ ] Liveness **and** readiness probes defined — not just liveness; flag if only liveness is present
- [ ] Startup probe defined for containers with slow initialisation
- [ ] `terminationGracePeriodSeconds` is appropriate for the workload (default 30s may be too short for databases or message consumers)
- [ ] No hardcoded environment-specific values in the manifest (IPs, hostnames, connection strings) — use ConfigMaps or Secrets
- [ ] Labels follow a consistent scheme — check for `app.kubernetes.io/name`, `app.kubernetes.io/version`, `app.kubernetes.io/component`
- [ ] Deployment `strategy` is appropriate: `RollingUpdate` with sensible `maxSurge` and `maxUnavailable` values
- [ ] No `hostNetwork: true` or `hostPID: true` without explicit justification
- [ ] Service type: flag `type: LoadBalancer` where `ClusterIP` + Ingress would suffice (cost and attack surface)
- [ ] No deprecated API versions — flag any apiVersion that has been removed in recent K8s releases (e.g., `extensions/v1beta1`, `apps/v1beta1`)
- [ ] Ingress: check for `kubernetes.io/ingress.class` annotation (deprecated) vs `ingressClassName` field
- [ ] `replicas: 1` for anything in a production namespace — flag as a single point of failure

---

At the end, output a summary table:

| Severity | Count |
|----------|-------|
| Critical | X |
| Warning  | X |
| Info     | X |

Flag the top 3 most important fixes if there are many findings.
