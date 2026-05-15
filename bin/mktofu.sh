#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <target-path>"
    exit 1
fi

TARGET="$1"
ROOT="$TARGET/terraform-project"

if [[ -e "$ROOT" ]]; then
    echo "Error: $ROOT already exists"
    exit 1
fi

echo "Creating project structure at $ROOT..."

# ---------------------------------------------------------------------------
# Directories
# ---------------------------------------------------------------------------

mkdir -p \
    "$ROOT/modules/vpc" \
    "$ROOT/modules/ec2" \
    "$ROOT/modules/rds" \
    "$ROOT/envs/dev" \
    "$ROOT/envs/staging" \
    "$ROOT/envs/prod" \
    "$ROOT/global/iam" \
    "$ROOT/bootstrap"

# ---------------------------------------------------------------------------
# Shared file content helpers
# ---------------------------------------------------------------------------

write_versions() {
    cat > "$1/versions.tf" <<'EOF'
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
EOF
}

write_providers() {
    cat > "$1/providers.tf" <<'EOF'
provider "aws" {
  region = var.aws_region
}
EOF
}

write_env_variables() {
    cat > "$1/variables.tf" <<'EOF'
variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-southeast-2"
}
EOF
}

write_backend() {
    local env="$2"
    cat > "$1/backend.tf" <<EOF
terraform {
  backend "s3" {
    # bucket         = "your-state-bucket"
    # key            = "envs/${env}/terraform.tfstate"
    # region         = "ap-southeast-2"
    # dynamodb_table = "your-lock-table"
    # encrypt        = true
  }
}
EOF
}

write_env_main() {
    cat > "$1/main.tf" <<'EOF'
# Environment-level root module.
# Call shared modules here, e.g.:
#
# module "vpc" {
#   source = "../../modules/vpc"
# }
EOF
}

write_env_outputs() {
    cat > "$1/outputs.tf" <<'EOF'
# Expose values from called modules here, e.g.:
#
# output "vpc_id" {
#   value = module.vpc.vpc_id
# }
EOF
}

write_module_files() {
    local dir="$1"
    local name="$2"

    cat > "$dir/main.tf" <<EOF
# ${name} module - define resources here
EOF

    cat > "$dir/variables.tf" <<EOF
# ${name} module input variables
EOF

    cat > "$dir/outputs.tf" <<EOF
# ${name} module outputs - consumed by calling configurations
EOF

    write_versions "$dir"
}

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------

for mod in vpc ec2 rds; do
    write_module_files "$ROOT/modules/$mod" "$mod"
done

# ---------------------------------------------------------------------------
# Environments
# ---------------------------------------------------------------------------

for env in dev staging prod; do
    dir="$ROOT/envs/$env"
    write_versions    "$dir"
    write_providers   "$dir"
    write_env_variables "$dir"
    write_backend     "$dir" "$env"
    write_env_main    "$dir"
    write_env_outputs "$dir"
done

# ---------------------------------------------------------------------------
# Global / IAM
# ---------------------------------------------------------------------------

write_versions "$ROOT/global/iam"
write_providers "$ROOT/global/iam"
write_env_variables "$ROOT/global/iam"

cat > "$ROOT/global/iam/main.tf" <<'EOF'
# Shared IAM roles and policies - resources that span environments go here
EOF

cat > "$ROOT/global/iam/outputs.tf" <<'EOF'
# Export role ARNs and policy ARNs for consumption by environment configs
EOF

cat > "$ROOT/global/iam/backend.tf" <<'EOF'
terraform {
  backend "s3" {
    # bucket         = "your-state-bucket"
    # key            = "global/iam/terraform.tfstate"
    # region         = "ap-southeast-2"
    # dynamodb_table = "your-lock-table"
    # encrypt        = true
  }
}
EOF

# ---------------------------------------------------------------------------
# Bootstrap (state bucket + DynamoDB lock table)
# ---------------------------------------------------------------------------

write_versions "$ROOT/bootstrap"
write_providers "$ROOT/bootstrap"

cat > "$ROOT/bootstrap/variables.tf" <<'EOF'
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket used for remote state"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  type        = string
  default     = "terraform-lock"
}
EOF

cat > "$ROOT/bootstrap/main.tf" <<'EOF'
# Provisions the S3 bucket and DynamoDB table required by all backend.tf configs.
# Run once with local state, then migrate if desired.
#
# tofu init && tofu apply
#
# After applying, populate the bucket/table values in each backend.tf.

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
EOF

cat > "$ROOT/bootstrap/outputs.tf" <<'EOF'
output "state_bucket_name" {
  value = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.lock.name
}
EOF

# ---------------------------------------------------------------------------
# .gitignore
# ---------------------------------------------------------------------------

cat > "$ROOT/.gitignore" <<'EOF'
# Local state - never commit
*.tfstate
*.tfstate.backup

# Crash logs
crash.log

# Sensitive variable files
*.tfvars
*.tfvars.json

# Initialisation directory
.terraform/

# Provider lock file - commit this for reproducible provider versions
# .terraform.lock.hcl

# macOS noise
.DS_Store
EOF

# ---------------------------------------------------------------------------
# README
# ---------------------------------------------------------------------------

cat > "$ROOT/README.md" <<'EOF'
# Terraform Project

## Structure

- `bootstrap/`  - Provisions the S3 state bucket and DynamoDB lock table. Run once before anything else.
- `modules/`    - Reusable building blocks (vpc, ec2, rds). Called by environment configs.
- `envs/`       - Per-environment root configurations (dev, staging, prod).
- `global/`     - Shared resources that exist outside any single environment (IAM roles, etc.).

## Getting Started

### 1. Bootstrap remote state

```
cd bootstrap
tofu init
tofu apply
```

Populate the `bucket`, `key`, and `dynamodb_table` values in each `backend.tf` with the outputs.

### 2. Deploy an environment

```
cd envs/dev
tofu init
tofu plan
tofu apply
```

## Notes

- `.terraform.lock.hcl` is intentionally not gitignored - commit it for reproducible provider versions.
- Never commit `.tfstate` files or `.tfvars` files containing real values.
EOF

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo "Done. Structure created:"
find "$ROOT" | sort | sed "s|$ROOT||" | sed 's|^/||'
