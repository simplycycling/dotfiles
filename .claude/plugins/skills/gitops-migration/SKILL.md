---
name: gitops-migration
description: >
  This skill should be used when the user wants to "migrate to GitOps", "write Terraform
  for existing infrastructure", "create Terraform configs", "import existing resources into
  Terraform", "write Ansible playbooks", "set up IaC", "convert existing infrastructure to
  code", "plan a GitOps workflow", or needs guidance on Terraform or Ansible patterns for
  AWS, Azure, Kubernetes, RDS (Postgres or MSSQL), or Redshift. Also triggers for questions
  about Terraform state, module structure, provider configs, Azure DevOps pipelines for IaC,
  Ansible role design, or migrating from kOps to EKS.
version: 0.1.0
---

# GitOps Migration

Migrate existing AWS/Azure infrastructure to a GitOps workflow using Terraform for provisioning and Ansible for configuration management, integrating with Azure DevOps pipelines.

## Stack Context

- **Cloud**: AWS (primary), Azure (secondary)
- **Compute/Orchestration**: Kubernetes — currently kOps-managed (prod + others), migrating to EKS
- **Databases**: RDS Postgres, RDS MSSQL, Redshift
- **IaC approach**: Terraform with flat per-environment directories; Ansible for configuration management
- **Source control and CI/CD**: Azure DevOps

## Terraform Directory Structure

The established pattern is flat configs per environment. Follow this layout:

```
infra/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   └── (same structure)
│   └── prod/
│       └── (same structure)
└── modules/            # optional: only extract shared logic when it's genuinely reused
    └── rds-postgres/
```

Each environment directory is self-contained with its own state file. Do not create modules prematurely — flat configs are easier to understand during an active migration.

## Provider and Version Pinning

Always pin provider versions explicitly:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.5.0"
}
```

## State Management

- Store remote state in **S3 + DynamoDB locking** for AWS-managed resources
- Store remote state in **Azure Blob Storage** for Azure-managed resources
- Use separate state files per environment and per logical service domain
- Never mix AWS and Azure resources in the same state file

Backend stub for AWS:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "environments/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

## Importing Existing Resources

When adopting existing manually-created infrastructure, use import blocks (Terraform 1.5+) before writing the resource config:

```hcl
import {
  to = aws_db_instance.payments_postgres
  id = "payments-db-prod"
}
```

Always run `terraform plan` after import to confirm there is no unexpected drift before committing the config.

For complex resources, generate a starting config with:
```bash
terraform plan -generate-config-out=generated.tf
```

Review and clean up the generated config — it will contain all attributes, many of which can be removed.

## Tagging Strategy

Apply consistent tags to all taggable AWS resources via a locals block:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Team        = var.team
    CostCenter  = var.cost_center
    Repository  = var.repo_url
  }
}
```

Pass `tags = local.common_tags` (merged with any resource-specific tags) on every taggable resource. This is critical for cost attribution and ownership identification during archaeology.

## Key Resource Patterns

### kOps → EKS Migration

The current state is kOps-managed clusters. EKS is the target. This is a significant migration — plan it carefully per cluster.

**Pre-migration assessment for each kOps cluster:**
1. Run `kops get cluster -o yaml` and document the full cluster spec before touching anything
2. Note the CNI in use (`spec.networking`) — if it's Weave or Canal (not Amazon VPC CNI or Calico), you'll need to plan a CNI migration as well, since EKS defaults to Amazon VPC CNI
3. Check whether IRSA is configured on the kOps cluster (`spec.kubeAPIServer.serviceAccountIssuer`). If not, pods may be using node instance profiles for AWS access — audit which pods need AWS permissions before migrating
4. Inventory all instance groups (`kops get ig -o yaml`) — map these to EKS managed node group equivalents, preserving taints, labels, and instance type choices
5. Run `helm list -A` and `kubectl get all -A` to capture all workloads — this becomes your migration checklist

**Migration approach (blue/green recommended for prod):**
- Provision the new EKS cluster in Terraform alongside the existing kOps cluster
- Migrate workloads namespace-by-namespace, starting with stateless services
- Use DNS cutover or weighted routing (Route 53) to shift traffic incrementally
- Keep the kOps cluster running until all workloads are validated on EKS
- Only decommission the kOps cluster (and its S3 state store) after a defined stability period

**kOps state store cleanup:**
When decommissioning a kOps cluster, the S3 state store bucket and associated IAM roles (`masters.<cluster>`, `nodes.<cluster>`) must be deleted explicitly — kOps does not clean these up automatically unless you run `kops delete cluster --yes`.

**Terraform for the new EKS cluster:**
When writing Terraform for the replacement EKS cluster, do not attempt to import the kOps cluster — it was not created by Terraform. Create the EKS cluster as a net-new resource.

### EKS (target state)
- Use managed node groups rather than self-managed worker nodes
- Enable IRSA (IAM Roles for Service Accounts) for pod-level AWS permissions — this replaces node-level instance profiles used in kOps clusters
- Define cluster addons (CoreDNS, kube-proxy, VPC CNI, EBS CSI driver) as `aws_eks_addon` resources for lifecycle management
- Set `force_update_version = false` on addons in production

### RDS Postgres / MSSQL
- Always define parameter groups and option groups explicitly — never rely on `default.*` groups, which can change under you
- Enable `deletion_protection = true` in prod and staging
- Define `maintenance_window` and `backup_window` that avoid peak traffic hours
- Use `aws_db_subnet_group` explicitly rather than relying on defaults
- Enable `storage_encrypted = true` with a managed KMS key

### Redshift
- Define WLM configuration in Terraform via the `wlm_json_configuration` parameter on the cluster or via `aws_redshift_parameter_group`
- Use `aws_redshift_serverless_*` resources for variable/bursty analytics workloads
- Define IAM roles for Spectrum S3 access explicitly and attach via `iam_roles` on the cluster resource

## Ansible Patterns

Use Ansible for:
- OS-level configuration on EC2 instances and bastion hosts
- Post-provisioning tasks (SSL cert deployment, directory structure, OS hardening)
- Kubernetes application deployment via `community.kubernetes` when Helm is not appropriate
- RDS-adjacent tasks requiring OS-level tooling (e.g., running schema migrations from a bastion)

### Directory structure
```
ansible/
├── inventory/
│   ├── dev.ini
│   └── prod.ini
├── group_vars/
│   ├── all.yml          # non-secret shared vars
│   └── prod.yml         # prod-specific overrides
├── roles/
│   └── role-name/
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       ├── defaults/main.yml
│       └── templates/
├── site.yml
└── requirements.yml
```

### Key conventions
- Reference secrets via `ansible-vault` (`{{ vault_secret_name }}`); never store plaintext secrets in the repo
- Tag every task for selective execution (`tags: [install, configure, harden]`)
- Use `block/rescue/always` for tasks that require rollback handling
- `become: yes` only where root genuinely required — not as a default
- Every `shell` or `command` task must have `changed_when` defined to preserve idempotency

## Azure DevOps Pipeline Structure for Terraform

Recommended pipeline stages:

1. `terraform init` — inject backend config from pipeline variables (`-backend-config` flags)
2. `terraform validate` — catch syntax errors early
3. `terraform plan` — save plan as pipeline artifact (`-out=tfplan`)
4. **Manual approval gate** — required for staging and prod environments
5. `terraform apply tfplan` — apply the saved plan only

Never run `terraform apply` with `-auto-approve` in a prod pipeline. Always use a saved plan from the previous stage to prevent drift between plan and apply.

Store Terraform variables as Azure DevOps variable groups (mark sensitive values as secret). Inject them as environment variables (`TF_VAR_*`) rather than writing them to `terraform.tfvars` in the pipeline.

## Migration Sequencing

When migrating an environment from manual to GitOps:

1. Inventory all existing resources (use infra-archaeology skill + `/infra-doc` command)
2. Identify dependencies and sequencing (networking before compute, compute before applications)
3. Write Terraform configs for lowest-risk resources first (networking, IAM)
4. Import and validate each resource before moving to the next layer
5. Enable state locking before multiple engineers start contributing
6. Add pipeline gates progressively — start with dev, add prod gates only when process is stable

See `references/stack-patterns.md` for environment-specific patterns and import command reference.
