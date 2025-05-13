data "google_secret_manager_secret" "github_token" {
  project   = local.project_id
  secret_id = var.github_secret_name
}

data "google_secret_manager_secret_version" "github_token" {
  secret  = data.google_secret_manager_secret.github_token.id
  version = "latest"
}