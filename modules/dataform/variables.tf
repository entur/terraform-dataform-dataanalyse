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

variable "dataform_release_cron_schedule" {
  type = object(
    {
      cron_schedule = optional(string, "0 5 * * *")
      timezone      = optional(string, "UTC")
    }
  )
  default     = {}
  description = "Cron schedule for dataform release config"
}

variable "dataform_workflows" {
  type = map(object({
    cron_schedule        = string
    tags                 = list(string)
    include_dependencies = optional(bool, false)
    timezone             = optional(string, "UTC")
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




locals {
  project_id               = module.init.app.project_id
  dataform_service_account = "serviceAccount:service-${module.init.app.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
  github_repo_name         = regex(".*\\/([^.]+)\\.git$", var.github_repo_url)[0] // Extracts string between last "/" and ".git"
  labels = merge(
    var.extra_labels,
    { "repo" : local.github_repo_name },
    module.init.labels
  )
}




