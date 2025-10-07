variable "env" {
  description = "Environment descriptor (i.e. 'dev', 'tst', 'prd')."
  validation {
    condition     = length(var.env) == 3
    error_message = "The environment descriptor should be a 3 character string (i.e. 'dev', 'tst', 'prd')."
  }
  type = string
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

variable "extra_labels" {
  type        = map(string)
  default     = {}
  description = "extra labels to be applied to all resources (in addition to init module labels)"
}

variable "github_repo_url" {
  type        = string
  description = "GitHub repository URL"
}

variable "dataform_workflows" {
  type = map(object({
    cron_schedule        = string
    tags                 = list(string)
    include_dependencies = optional(bool, false)
  }))
  default     = {}
  description = "Dataform workflows to be created"
}

variable "location" {
  default     = "europe-west1"
  type        = string
  description = "Location for gcp resources"
}

variable "github_default_branch" {
  type        = string
  default     = "main"
  description = "Default branch for the GitHub repository"
}

variable "github_secret_name" {
  type        = string
  default     = "github-token"
  description = "Name of the GitHub access token in Secret Manager"
}

variable "runner_service_account_email" {
  type        = string
  default     = null
  description = "Existing service account email to run Dataform workflows. Leave null to let the module create one."
}

variable "runner_service_account_project" {
  type        = string
  default     = null
  description = "Project ID for the existing runner service account. Defaults to the target project when omitted."
}

variable "runner_service_account_id" {
  type        = string
  default     = null
  description = "Account ID to use when creating the runner service account (omit domain). Defaults to a derived value based on app, env and repository."
}

variable "runner_service_account_display_name" {
  type        = string
  default     = "Dataform workflow runner"
  description = "Display name to apply to the runner service account when it is created."
}

variable "runner_service_account_description" {
  type        = string
  default     = "Service account used to run Dataform workflows"
  description = "Description to apply to the runner service account when it is created."
}

variable "runner_service_account_user_members" {
  type        = list(string)
  default     = []
  description = "Additional principals to grant roles/iam.serviceAccountUser on the runner service account."
}

variable "runner_service_account_project_roles" {
  type = list(string)
  default = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ]
  description = "Project-level roles to bind to the runner service account."
}

variable "slack_notification_channel_id" {
  type        = string
  default     = null
  description = "notification channel id for slack alerting"
}




locals {
  project_id                 = module.init.app.project_id
  dataform_service_account   = "serviceAccount:service-${module.init.app.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
  github_repo_name           = regex(".*\\/([^.]+)\\.git$", var.github_repo_url)[0] // Extracts string between last "/" and ".git"
  service_account_project    = coalesce(var.runner_service_account_project, local.project_id)
  service_account_id_source  = lower(join("-", compact(["df", var.app_id, var.env, local.github_repo_name])))
  service_account_id_tokens  = regexall("[a-z0-9]+", local.service_account_id_source)
  service_account_id_base    = length(local.service_account_id_tokens) > 0 ? join("-", local.service_account_id_tokens) : lower("df-${var.env}-runner")
  service_account_id_default = substr(local.service_account_id_base, 0, 30)
  service_account_id         = coalesce(var.runner_service_account_id, local.service_account_id_default)
  workflow_service_account_email = coalesce(
    var.runner_service_account_email,
    try(google_service_account.workflow[0].email, null)
  )
  workflow_service_account_member = "serviceAccount:${local.workflow_service_account_email}"
  workflow_service_account_name   = var.runner_service_account_email != null ? "projects/${local.service_account_project}/serviceAccounts/${var.runner_service_account_email}" : try(google_service_account.workflow[0].name, null)
  labels = merge(
    var.extra_labels,
    { "repo" : local.github_repo_name },
    module.init.labels
  )
}




