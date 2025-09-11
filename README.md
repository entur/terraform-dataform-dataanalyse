# Terraform Dataform Data Analysis Module

This repository contains a Terraform module for setting up Google Cloud Dataform infrastructure and workflows for data analysis.

## Table of Contents
- [Quick Start](#quick-start)
  - [1. Creating Default Terraform Configuration](#1-creating-default-terraform-configuration)
  - [2. Creating Dataform Project Structure](#2-creating-dataform-project-structure)
- [Typical Workflow](#typical-workflow)
- [Important Notes](#important-notes)
- [Module Configuration](#module-configuration)
- [Documentation](#documentation)

## Quick Start

### 1. Creating Default Terraform Configuration

To create a complete Terraform configuration that uses this module, run the following script:

```bash
bash scripts/create_terraform_folder_structure.sh [target-directory]
```

**Prerequisites:**
- You need an Entur APP_ID for the GCS backend bucket
- The script will prompt you for the APP_ID if not set as an environment variable

**What this creates:**
- `terraform/` directory with complete Terraform configuration
- Environment-specific `.tfvars` files (`dev`, `tst`, `prd`)
- Backend configuration for GCS state storage
- Main module configuration referencing this dataform module
- All required variable definitions
- Provider version constraints

**Example usage:**
```bash
# Create terraform config in current directory
bash scripts/create_terraform_folder_structure.sh .

# Create terraform config in specific directory
bash scripts/create_terraform_folder_structure.sh /path/to/my-project
```

### 2. Creating Dataform Project Structure

To create the Dataform project folder structure and example files:

```bash
bash scripts/create_dataform_folder_structure.sh <target-path>
```

**What this creates:**
- Organized folder structure with numbered prefixes:
  - `includes/01 sources/` - Source data declarations
  - `includes/02 intermediate/` - Data transformations
  - `includes/03 outputs/` - Final output tables
  - `includes/04 extras/` - Additional files
- `workflow_settings.yaml` with default configuration
- Example SQL files to get started

**Example usage:**
```bash
# Create dataform project structure
bash scripts/create_dataform_folder_structure.sh ./my-dataform-project
```

## Typical Workflow

1. **Set up Terraform configuration:**
   ```bash
   export APP_ID="your-app-id"
   bash scripts/create_terraform_folder_structure.sh .
   ```

2. **Create Dataform project structure:**
   ```bash
   bash scripts/create_dataform_folder_structure.sh ./dataform
   ```

3. **Configure your environment variables:**
   ```bash
   cd terraform
   # Edit env/dev.tfvars, env/tst.tfvars, env/prd.tfvars as needed
   # You must specify at minimum:
   # - app_id = "your-entur-app-id"
   # - github_repo_url = "https://github.com/your-org/your-repo"
   ```

4. **Initialize and apply Terraform:**
   ```bash
   terraform init
   terraform plan -var-file=env/dev.tfvars
   terraform apply -var-file=env/dev.tfvars
   ```

## Important Notes

- **Project wide permissions (BigQuery Job User) cannot be given through Github Actions, so initial terraform apply needs to be run locally**
- The terraform script automatically detects your repository name for the GCS backend prefix
- Environment files include example dataform workflows (nightly and hourly schedules)

## Module Configuration

The generated terraform configuration references this module with version pinning. By default, it uses:

```hcl
module "dataform" {
  source = "github.com/entur/terraform-dataform-dataanalyse//modules/dataform?ref=1.0.0"
  # ... other configuration
}
```

You can update the `ref=1.0.0` to use a different version or `ref=main` for the latest development version.

## Documentation

To generate terraform docs run:

```bash
terraform-docs --config .terraform-docs.yml ./modules/dataform
```