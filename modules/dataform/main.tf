terraform {
  required_version = "> 1.11.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0, < 7.0"
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
  name     = coalesce(var.dataform_repository_name, local.github_repo_name)
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

  name          = coalesce(var.dataform_release_config_name, var.branch_name)
  git_commitish = var.branch_name
  cron_schedule = var.dataform_release_cron_schedule.cron_schedule
  time_zone     = var.dataform_release_cron_schedule.timezone

  code_compilation_config {
    default_database = local.project_id
  }
}

resource "google_dataform_repository_workflow_config" "main" {
  provider = google-beta
  for_each = var.dataform_workflows

  name          = each.key
  cron_schedule = each.value.cron_schedule
  invocation_config {
    included_tags                    = each.value.tags
    transitive_dependencies_included = each.value.include_dependencies
  }

  time_zone = each.value.timezone

  project        = local.project_id
  region         = var.location
  repository     = google_dataform_repository.main.name
  release_config = google_dataform_repository_release_config.main.id
}

