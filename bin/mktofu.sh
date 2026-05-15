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

# Directories
mkdir -p \
    "$ROOT/modules/vpc" \
    "$ROOT/modules/ec2" \
    "$ROOT/modules/rds" \
    "$ROOT/envs/dev" \
    "$ROOT/envs/staging" \
    "$ROOT/envs/prod" \
    "$ROOT/global/iam"

# Files with content
touch \
    "$ROOT/envs/dev/main.tf" \
    "$ROOT/envs/dev/variables.tf" \
    "$ROOT/envs/dev/backend.tf" \
    "$ROOT/global/iam/main.tf" \
    "$ROOT/global/iam/outputs.tf"

cat > "$ROOT/README.md" <<'EOF'
# Terraform Project

## Structure

- `modules/`  - Reusable building blocks (vpc, ec2, rds)
- `envs/`     - Per-environment configurations (dev, staging, prod)
- `global/`   - Shared resources (IAM roles, etc.)

## Usage

Navigate to the relevant environment directory and run:

```
tofu init
tofu plan
tofu apply
```
EOF

echo "Done. Structure created:"
find "$ROOT" | sort | sed "s|$ROOT||" | sed 's|^/||'
