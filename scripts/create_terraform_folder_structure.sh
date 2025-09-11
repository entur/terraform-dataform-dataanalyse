#!/bin/bash

set -euo pipefail

# Script to create a Terraform folder structure with environment tfvars, backend, and module setup
# Usage: bash scripts/create_terraform_folder_structure.sh


# Accept destination as argument, default to ../terraform if not provided

# Always create a 'terraform' subfolder inside the specified destination
if [ -n "${1:-}" ]; then
  BASE_PARENT="$1"
else
  BASE_PARENT="$(dirname "$0")/.."
fi


BASE_DIR="$BASE_PARENT/terraform"


if [ -d "$BASE_DIR" ]; then
  # Only allow overwrite if the folder is named 'terraform'
  if [ "$(basename "$BASE_DIR")" != "terraform" ]; then
    echo "Refusing to overwrite: $BASE_DIR is not named 'terraform'. Aborting."; exit 1
  fi
  read -p "Directory $BASE_DIR already exists. Overwrite? (y/n): " choice
  case "$choice" in
    y|Y )
      rm -rf "$BASE_DIR";;
    n|N )
      echo "Aborting."; exit 1;;
    * )
      echo "Invalid response. Aborting."; exit 1;;
  esac
fi

mkdir -p "$BASE_DIR/env"

cat > "$BASE_DIR/env/prd.tfvars" <<EOF
environment = "prd"

dataform_workflows = {
  nightly = {
    cron_schedule = "0 4 * * *"
    tags          = ["nightly"]
    include_dependencies = true
  }
  hourly = {
    cron_schedule = "0 * * * *"
    tags          = ["hourly"]
  }
}
EOF
echo 'environment = "tst"' > "$BASE_DIR/env/tst.tfvars"
echo 'environment = "dev"' > "$BASE_DIR/env/dev.tfvars"

if [ -z "${APP_ID:-}" ]; then
  read -p "Enter APP_ID for backend bucket: " APP_ID
  if [ -z "$APP_ID" ]; then
    echo "APP_ID is required. Aborting."; exit 1
  fi
fi

cat > "$BASE_DIR/backend.tf" <<EOF
terraform {
  backend "gcs" {
    bucket = "ent-gcs-tfa-${APP_ID}"
  }
}
EOF

cat > "$BASE_DIR/main.tf" <<EOF
module "dataform" {
  source      = "github.com/entur/terraform-dataform-dataanalyse//modules/dataform?ref=1.0.0"
  env         = var.environment
  app_id      = var.app_id
  branch_name = var.branch_name
  github_repo_url = var.github_repo_url
  main_cron_schedule = var.main_cron_schedule
  region      = var.region
  location    = var.location
  github_default_branch = var.github_default_branch
  github_secret_name    = var.github_secret_name
  slack_notification_channel_id = var.slack_notification_channel_id
  source_datasets = var.source_datasets
  dataform_workflows = var.dataform_workflows
}
EOF

cat > "$BASE_DIR/versions.tf" <<EOF
terraform {
  required_version = ">= 1.11.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}
EOF

cat > "$BASE_DIR/variables.tf" <<EOF
variable "environment" {
  description = "Environment descriptor (i.e. 'dev', 'tst', 'prd')."
  type        = string
}

variable "app_id" {
  description = "Entur application ID"
  type        = string
}

variable "branch_name" {
  description = "Branch name for the GitHub repository"
  type        = string
  default     = "main"
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}

variable "main_cron_schedule" {
  description = "Cron schedule for the main dataform workflow"
  type        = string
  default     = "0 * * * *"
}

variable "region" {
  description = "Region for GCP resources"
  type        = string
  default     = "EU"
}

variable "location" {
  description = "Location for GCP resources"
  type        = string
  default     = "europe-west1"
}

variable "github_default_branch" {
  description = "Default branch for the GitHub repository"
  type        = string
  default     = "main"
}

variable "github_secret_name" {
  description = "Name of the GitHub access token in Secret Manager"
  type        = string
  default     = "github-token"
}

variable "slack_notification_channel_id" {
  description = "Notification channel id for Slack alerting"
  type        = string
  default     = null
}

variable "source_datasets" {
  description = "Map of source datasets. Dataform service account will be granted access to these datasets if owned by Team Data."
  type = map(object({
    project_id = string
    dataset_id = string
  }))
  default = {}
}

variable "dataform_workflows" {
  description = "Map of workflow configs for Dataform."
  type = map(object({
    cron_schedule        = string
    tags                = list(string)
    include_dependencies = optional(bool)
  }))
}
EOF

touch "$BASE_DIR/bigquery.tf"

echo "Terraform folder structure created at $BASE_DIR."