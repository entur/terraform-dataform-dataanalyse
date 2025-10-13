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


variable "slack_notification_channel_id" {
  type        = string
  default     = null
  description = "notification channel id for slack alerting"
}

variable "service_account_email" {
  type        = string
  description = "Email of the custom service account to use for Dataform workflows. Required for strict act-as mode compliance."
}

variable "workflow_invoker_members" {
  type        = list(string)
  default     = []
  description = "List of members (users or service accounts) that need to invoke workflows. They will be granted roles/iam.serviceAccountUser on the custom service account."
}


locals {
  project_id       = module.init.app.project_id
  github_repo_name = regex(".*\\/([^.]+)\\.git$", var.github_repo_url)[0] // Extracts string between last "/" and ".git"
  labels = merge(
    var.extra_labels,
    { "repo" : local.github_repo_name },
    module.init.labels
  )
}




