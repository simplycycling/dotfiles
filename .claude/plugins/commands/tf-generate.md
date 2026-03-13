---
description: Generate Terraform for AWS/Azure resources
allowed-tools: Write, Read
argument-hint: [describe a resource, or paste existing config/CLI output to convert]
---

Generate Terraform configuration for: $ARGUMENTS

Context:
- Primary cloud: AWS. Secondary: Azure.
- Directory structure: flat configs per environment (each environment directory is self-contained)
- Terraform version: >= 1.5.0
- AWS provider: ~> 5.0 | Azure provider (azurerm): ~> 3.0

Rules:
1. Write production-grade HCL — no placeholders like `<your-value-here>`, no pseudo-code. Use `var.x` references for environment-specific values.
2. Include a `variables.tf` block defining all variables used, with types, descriptions, and sensible defaults where appropriate.
3. Include an `outputs.tf` block for values other resources are likely to consume.
4. Apply a `local.common_tags` locals block to all taggable resources. Include `Environment`, `ManagedBy = "terraform"`, `Team`, and `CostCenter` in the tags locals.
5. Enable `deletion_protection = true` for all database resources (RDS, Redshift) in any config that could be prod. Use a variable to control this.
6. Define parameter groups and option groups explicitly for all RDS resources — never rely on `default.*` parameter groups.
7. Use IRSA (IAM Roles for Service Accounts) for EKS pod-level AWS permissions — not node instance profiles.
8. Pin provider versions in a `terraform {}` required_providers block.
9. Include a `backend.tf` stub with a remote state config (S3 + DynamoDB for AWS, Azure Blob for Azure). Leave connection values as variables.
10. Add inline comments for any non-obvious decisions or gotchas.
11. Use `storage_encrypted = true` with a KMS key reference for all RDS and Redshift resources.

If given an existing manual setup, CLI output (`aws ec2 describe-*`, `kubectl get -o yaml`, etc.), or a description of a resource that already exists:
- Generate the equivalent Terraform config
- Include an `import` block (Terraform 1.5+ syntax) or `terraform import` command so the resource can be adopted without recreation
- Note any attributes that may cause drift after import (e.g., computed values, ignored_changes candidates)

After generating, offer to save as .tf files in the appropriate structure.
