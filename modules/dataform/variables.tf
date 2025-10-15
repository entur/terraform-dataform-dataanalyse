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

variable "dataform_repository_name" {
  type        = string
  default     = null
  description = "Dataform workflows to be created"
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

variable "runner_service_account_user_members" {
  type        = list(string)
  default     = []
  description = "Additional principals to grant roles/iam.serviceAccountUser on the workflow runner service account supplied by the init module. The module always grants group:sg-dig-team-data@entur.no by default."
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
  project_id               = module.init.app.project_id
  dataform_service_account = "serviceAccount:service-${module.init.app.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
  github_repo_name         = regex(".*\\/([^.]+)\\.git$", var.github_repo_url)[0] // Extracts string between last "/" and ".git"
  init_service_account     = try(module.init.service_accounts.default, null)

  workflow_service_account_email = try(local.init_service_account.email, null)
  workflow_service_account_project_from_email = local.workflow_service_account_email == null ? null : split(".iam", split("@", local.workflow_service_account_email)[1])[0]
  workflow_service_account_project = coalesce(
    local.workflow_service_account_project_from_email,
    try(local.init_service_account.project, null),
    local.project_id
  )
  workflow_service_account_member = local.workflow_service_account_email == null ? null : "serviceAccount:${local.workflow_service_account_email}"
  workflow_service_account_name   = local.workflow_service_account_email == null ? null : format("projects/%s/serviceAccounts/%s", local.workflow_service_account_project, local.workflow_service_account_email)

  runner_service_account_user_members = toset(concat([
    "group:sg-dig-team-data@entur.no",
  ], var.runner_service_account_user_members))

  labels = merge(
    var.extra_labels,
    { "repo" : local.github_repo_name },
    module.init.labels
  )
}




