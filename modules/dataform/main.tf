terraform {
  required_version = "1.11.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0.0"
    }
  }
}

module "init" {
  source      = "github.com/entur/terraform-google-init//modules/init?ref=v1.0.0"
  app_id      = var.app_id
  environment = var.env
}


resource "google_dataform_repository" "main" {
  provider = google-beta
  project  = local.project_id
  name     = local.github_repo_name
  region   = var.location
  labels   = local.labels

  git_remote_settings {
    default_branch                      = var.github_default_branch
    url                                 = var.github_repo_url
    authentication_token_secret_version = data.google_secret_manager_secret_version.github_token.id
  }
}

resource "google_dataform_repository_release_config" "main" {
  provider = google-beta

  project    = local.project_id
  region     = var.location
  repository = google_dataform_repository.main.name

  name          = "main"
  git_commitish = "main"
  cron_schedule = "0 5 * * *"
  time_zone     = "UTC"

  code_compilation_config {
    default_database = local.project_id
  }
}

resource "google_dataform_repository_workflow_config" "main" {
  provider = google-beta

  name          = "main"
  cron_schedule = var.main_cron_schedule
  time_zone     = "UTC"


  project        = local.project_id
  region         = var.location
  repository     = google_dataform_repository.main.name
  release_config = google_dataform_repository_release_config.main.id
}

