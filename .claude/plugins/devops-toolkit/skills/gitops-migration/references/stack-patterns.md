# Stack Patterns Reference

Detailed patterns and import command reference for migrating specific resources to Terraform.

## Import Command Reference

### Networking
```bash
# VPC
terraform import aws_vpc.main vpc-0123456789abcdef0

# Subnets
terraform import aws_subnet.private_a subnet-0123456789abcdef0

# Security Groups
terraform import aws_security_group.rds sg-0123456789abcdef0

# Route Tables
terraform import aws_route_table.private rtb-0123456789abcdef0
```

### EKS
```bash
# EKS Cluster
terraform import aws_eks_cluster.main my-cluster-name

# Node Group
terraform import aws_eks_node_group.workers my-cluster-name:workers-node-group

# OIDC Provider (for IRSA)
terraform import aws_iam_openid_connect_provider.eks arn:aws:iam::123456789012:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/XXXXXXXXXX
```

### RDS
```bash
# RDS Instance
terraform import aws_db_instance.payments_postgres payments-db-prod

# Parameter Group
terraform import aws_db_parameter_group.postgres14 my-postgres14-params

# Subnet Group
terraform import aws_db_subnet_group.rds my-rds-subnet-group

# Option Group (MSSQL)
terraform import aws_db_option_group.mssql my-mssql-options
```

### Redshift
```bash
# Cluster
terraform import aws_redshift_cluster.analytics my-redshift-cluster

# Parameter Group
terraform import aws_redshift_parameter_group.wlm my-redshift-params

# Subnet Group
terraform import aws_redshift_subnet_group.main my-redshift-subnet-group
```

### IAM
```bash
# Role
terraform import aws_iam_role.eks_node_role my-eks-node-role

# Policy (managed)
terraform import aws_iam_policy.custom arn:aws:iam::123456789012:policy/my-policy

# Role Policy Attachment
terraform import aws_iam_role_policy_attachment.eks_worker_node "my-eks-node-role/arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
```

## RDS Postgres Terraform Template

```hcl
resource "aws_db_instance" "main" {
  identifier              = "${var.environment}-postgres-main"
  engine                  = "postgres"
  engine_version          = "15.4"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_storage_gb
  max_allocated_storage   = var.db_max_storage_gb
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds.arn

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password  # use aws_secretsmanager_secret_version reference instead

  parameter_group_name = aws_db_parameter_group.main.name
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az               = var.environment == "prod" ? true : false
  backup_retention_period = var.environment == "prod" ? 14 : 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment == "prod" ? false : true
  final_snapshot_identifier = "${var.environment}-postgres-main-final"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(local.common_tags, {
    Name = "${var.environment}-postgres-main"
  })
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.environment}-postgres15"
  family = "postgres15"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"  # log queries > 1s
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = local.common_tags
}
```

## RDS MSSQL Terraform Template

```hcl
resource "aws_db_instance" "mssql" {
  identifier     = "${var.environment}-mssql-main"
  engine         = "sqlserver-se"
  engine_version = "15.00.4345.5.v1"
  instance_class = var.mssql_instance_class
  license_model  = "license-included"

  allocated_storage     = var.mssql_storage_gb
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn

  username = var.mssql_username
  password = var.mssql_password

  parameter_group_name   = aws_db_parameter_group.mssql.name
  option_group_name      = aws_db_option_group.mssql.name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az                = var.environment == "prod" ? true : false
  backup_retention_period = 14
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  deletion_protection       = var.environment == "prod" ? true : false
  skip_final_snapshot       = var.environment == "prod" ? false : true
  final_snapshot_identifier = "${var.environment}-mssql-main-final"

  timezone = "UTC"

  tags = merge(local.common_tags, {
    Name = "${var.environment}-mssql-main"
  })
}
```

## EKS IRSA Pattern

```hcl
# OIDC provider (required once per cluster)
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# IAM role for a specific service account
data "aws_iam_policy_document" "pod_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account}"]
    }
  }
}

resource "aws_iam_role" "pod_role" {
  name               = "${var.environment}-${var.service_name}-pod-role"
  assume_role_policy = data.aws_iam_policy_document.pod_assume_role.json
  tags               = local.common_tags
}
```

## Azure DevOps Pipeline YAML Template

```yaml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - infra/environments/$(environment)/**

parameters:
  - name: environment
    displayName: Environment
    type: string
    values: [dev, staging, prod]

variables:
  - group: terraform-$(environment)  # variable group per environment

stages:
  - stage: Plan
    jobs:
      - job: TerraformPlan
        steps:
          - task: TerraformInstaller@1
            inputs:
              terraformVersion: '1.7.x'

          - script: |
              terraform init \
                -backend-config="bucket=$(TF_BACKEND_BUCKET)" \
                -backend-config="key=environments/$(environment)/terraform.tfstate" \
                -backend-config="region=$(AWS_REGION)" \
                -backend-config="dynamodb_table=$(TF_LOCK_TABLE)"
            displayName: 'Terraform Init'
            env:
              AWS_ACCESS_KEY_ID: $(AWS_ACCESS_KEY_ID)
              AWS_SECRET_ACCESS_KEY: $(AWS_SECRET_ACCESS_KEY)

          - script: terraform validate
            displayName: 'Terraform Validate'

          - script: terraform plan -out=tfplan -var-file=terraform.tfvars
            displayName: 'Terraform Plan'
            env:
              TF_VAR_db_password: $(DB_PASSWORD)

          - publish: tfplan
            artifact: terraform-plan

  - stage: Apply
    dependsOn: Plan
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: TerraformApply
        environment: $(environment)  # environment gates for approval
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: terraform-plan

                - script: terraform apply tfplan
                  displayName: 'Terraform Apply'
```

## kOps Cluster Decommission Checklist

Before running `kops delete cluster --yes` on a cluster being replaced by EKS:

- [ ] All workloads validated running on the new EKS cluster
- [ ] DNS records updated to point at EKS ingress / load balancers
- [ ] No active connections to kOps node IPs (check NLB/ALB target group health)
- [ ] kOps-managed IAM roles documented (`masters.<cluster>`, `nodes.<cluster>`) — Terraform the equivalents on EKS first
- [ ] kOps S3 state store bucket backed up (snapshot or copy) before deletion
- [ ] Any kOps-managed Route 53 records removed or handed over
- [ ] CloudWatch alarms referencing kOps EC2 instance IDs updated
- [ ] Bastion / VPN access to the old cluster's VPC reviewed — does it change post-migration?
- [ ] ADR written documenting the migration decision and date

## kOps to EKS Node Group Mapping

| kOps Instance Group field | EKS Managed Node Group equivalent |
|---------------------------|----------------------------------|
| `spec.machineType` | `instance_types` list |
| `spec.minSize` / `spec.maxSize` | `scaling_config.min_size` / `max_size` |
| `spec.nodeLabels` | `labels` on the node group |
| `spec.taints` | `taint` blocks on the node group |
| `spec.subnets` | `subnet_ids` on the node group |
| `spec.rootVolumeSize` | `disk_size` |
| `spec.rootVolumeType` | `launch_template` with `block_device_mappings` |

## Migration Priority Order

Recommended order for migrating an environment to Terraform:

1. **Networking foundation** (VPC, subnets, route tables, internet/NAT gateways)
2. **Security groups** (start with permissive, tighten progressively)
3. **IAM roles and policies** (import existing, avoid recreating)
4. **KMS keys** (required by other resources)
5. **S3 buckets** (state bucket itself should be pre-existing)
6. **RDS instances** (high-value, high-risk — import carefully)
7. **Redshift cluster** (import — recreating is very destructive)
8. **EKS cluster** (import cluster + node groups, then addons)
9. **Application-level resources** (K8s manifests, Helm releases)

Never import in a rush. Work one resource type at a time, validate plan shows no changes after import, commit before moving on.
