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

resource "google_bigquery_dataset_iam_binding" "dataform_sa_bigquery_access" {
  for_each = google_bigquery_dataset.datasets

  dataset_id = each.value.dataset_id
  role       = "roles/bigquery.dataEditor"
  members    = [local.dataform_service_account]
  project    = local.project_id
}
