# DevOps Toolkit

A plugin for DevOps engineers working across AWS and Azure with Kubernetes, RDS (Postgres/MSSQL), Redshift, Terraform, and Ansible. Particularly useful when inheriting messy infrastructure or migrating a multi-company environment to GitOps.

## Overview

Two parallel workflows:

1. **Infrastructure archaeology** — systematically investigate, document, and make sense of what previous engineers built and why
2. **GitOps migration** — write Terraform and Ansible for your specific stack, following your flat-per-environment directory structure, with Azure DevOps pipeline integration

## Components

### Skills

Skills load automatically when you describe a relevant task.

| Skill | Triggers when you... |
|-------|----------------------|
| `infra-archaeology` | Ask about what a resource does, why it exists, or how to document inherited infrastructure |
| `gitops-migration` | Ask about writing Terraform, Ansible playbooks, importing resources, or planning a GitOps migration |

### Commands

| Command | What it does |
|---------|-------------|
| `/adr` | Generate a MADR Architecture Decision Record — from a decision topic, or inferred from a config snippet |
| `/infra-doc` | Produce structured documentation for an existing resource — paste a config, manifest, or describe it |
| `/tf-generate` | Generate production-grade Terraform for AWS/Azure resources, including import blocks for existing resources |
| `/ansible-playbook` | Write a new Ansible playbook or review an existing one for idempotency, security, and best practices |
| `/k8s-review` | Review Kubernetes manifests for security, resource management, and best practices |

## Usage

### Investigating inherited infrastructure

Describe a resource or paste a config. The `infra-archaeology` skill loads automatically and guides the investigation. Use `/infra-doc` to produce structured documentation and `/adr` to record the decision rationale.

Example:
> "Here's a security group that has port 1433 open to three /16 CIDRs. I have no idea why. `/infra-doc`"

### Migrating to GitOps

Describe an existing manual setup or paste AWS CLI output. Use `/tf-generate` to produce Terraform configs with import blocks. Use `/ansible-playbook` for any configuration management tasks.

Example:
> "We have an RDS MSSQL instance called `legacy-sql-prod` that was created manually. `/tf-generate` it and give me the import command."

### Reviewing Kubernetes manifests

Point at a file path or paste YAML directly.

Example:
> "`/k8s-review` this deployment — I inherited it and want to know if there are any problems before I migrate it."

## Stack context built in

- **Cloud**: AWS (primary), Azure (secondary)
- **Orchestration**: EKS / Kubernetes
- **Databases**: RDS Postgres, RDS MSSQL, Redshift
- **IaC**: Terraform (flat per-environment directory structure) + Ansible
- **Source control and CI/CD**: Azure DevOps
- **Documentation**: Confluence (patchy)

## Setup

No environment variables or external services required. This plugin works entirely through Claude's context — paste configs, file paths, or descriptions and it will handle the rest.
