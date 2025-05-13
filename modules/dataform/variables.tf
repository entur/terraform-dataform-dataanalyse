variable "env" {
  type = string
}

variable "app_id" {
  type = string
}

variable "labels" {
  type = map(string)
}

variable "github_repo_url" {
  type = string
}

variable "main_cron_schedule" {
  type    = string
  default = "0 * * * *"
}

variable "region" {
  default = "EU"
  type    = string
}

variable "location" {
  default = "europe-west1"
  type    = string
}

variable "github_default_branch" {
  type    = string
  default = "main"

}

variable "github_secret_name" {
  type    = string
  default = "github-token"
}

variable "bigquery_datasets" {
  type    = set(string)
  default = []
}

variable "slack_notification_channel_id" {
  type    = string
  default = null
}

variable "source_datasets" {
  description = "A map of source datasets with project_id and dataset_id"
  type = map(object({
    project_id = string
    dataset_id = string
  }))
  default = {}
}

variable "bigquery_dataset_prefix" {
  type    = string
  default = ""
}

locals {
  project_id               = module.init.app.project_id
  dataform_service_account = "serviceAccount:service-${module.init.app.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
  github_repo_name         = regex(".*\\/([^.]+)\\.git$", var.github_repo_url)[0] // Extracts string between last "/" and ".git"
  bigquery_datasets        = toset([for bq_dataset in var.bigquery_datasets : format("%s%s", var.bigquery_dataset_prefix, bq_dataset)])
  labels                   = merge(var.labels, { "repo" : local.github_repo_name })
}




