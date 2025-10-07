resource "google_secret_manager_secret_iam_member" "dataform_secret_access" {
  secret_id  = data.google_secret_manager_secret.github_token.id
  role       = "roles/secretmanager.secretAccessor"
  member     = local.dataform_service_account
  depends_on = [google_dataform_repository.main]
}

resource "google_project_iam_member" "project_bigquery_job_user" {
  project    = local.project_id
  role       = "roles/bigquery.jobUser"
  member     = local.dataform_service_account
  depends_on = [google_dataform_repository.main]
}

resource "google_project_iam_member" "service_account_editor" {
  project = local.project_id
  role    = "roles/bigquery.dataEditor"
  member  = local.dataform_service_account
}

resource "google_project_iam_member" "workflow_runner_roles" {
  for_each = toset(var.runner_service_account_project_roles)

  project = local.project_id
  role    = each.value
  member  = local.workflow_service_account_member
}

resource "google_service_account_iam_member" "workflow_runner_dataform_act_as" {
  service_account_id = local.workflow_service_account_name
  role               = "roles/iam.serviceAccountUser"
  member             = local.dataform_service_account
}

resource "google_service_account_iam_member" "workflow_runner_additional_act_as" {
  for_each = local.runner_service_account_user_members

  service_account_id = local.workflow_service_account_name
  role               = "roles/iam.serviceAccountUser"
  member             = each.value
}

