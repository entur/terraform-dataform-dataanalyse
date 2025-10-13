# Grant the custom service account access to the GitHub token secret
resource "google_secret_manager_secret_iam_member" "dataform_secret_access" {
  secret_id  = data.google_secret_manager_secret.github_token.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${var.service_account_email}"
  depends_on = [google_dataform_repository.main]
}

# Grant the custom service account BigQuery Job User role
resource "google_project_iam_member" "project_bigquery_job_user" {
  project    = local.project_id
  role       = "roles/bigquery.jobUser"
  member     = "serviceAccount:${var.service_account_email}"
  depends_on = [google_dataform_repository.main]
}

# Grant the custom service account BigQuery Data Editor role
resource "google_project_iam_member" "service_account_editor" {
  project = local.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${var.service_account_email}"
}

# Grant workflow invokers the Service Account User role on the custom service account
# This is required for strict act-as mode compliance
resource "google_service_account_iam_member" "workflow_invoker" {
  for_each = toset(var.workflow_invoker_members)

  service_account_id = "projects/${local.project_id}/serviceAccounts/${var.service_account_email}"
  role               = "roles/iam.serviceAccountUser"
  member             = each.value
}

