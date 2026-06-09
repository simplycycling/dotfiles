# mktofu

A script that scaffolds a production-ready OpenTofu/Terraform project structure.

## Usage

```bash
mktofu <target-path>
```

This creates a `terraform-project/` directory inside `<target-path>`.

## What it creates

```
terraform-project/
├── bootstrap/         # Provisions S3 state bucket and DynamoDB lock table
├── envs/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── global/
│   └── iam/
├── modules/
│   ├── ec2/
│   ├── rds/
│   └── vpc/
├── .gitignore
└── README.md
```

Each environment and module directory is pre-populated with stubbed `main.tf`,
`variables.tf`, `outputs.tf`, `providers.tf`, `versions.tf`, and `backend.tf`
files where appropriate.

## Getting started

### 1. Bootstrap remote state

The `bootstrap/` directory provisions the S3 bucket and DynamoDB lock table
used by all other configurations. Run this once before anything else.

```bash
cd terraform-project/bootstrap
tofu init
tofu apply
```

Populate the `bucket` and `dynamodb_table` values in each environment's
`backend.tf` with the outputs.

### 2. Deploy an environment

```bash
cd terraform-project/envs/dev
tofu init
tofu plan
tofu apply
```

## Installation

Place the script in your `$PATH` and make it executable:

```bash
cp mktofu ~/.local/bin/mktofu
chmod +x ~/.local/bin/mktofu
```
