resource "google_secret_manager_secret_iam_member" "dataform_secret_access" {
  secret_id  = data.google_secret_manager_secret.github_token.id
  role       = "roles/secretmanager.secretAccessor"
  member     = local.dataform_service_account
  depends_on = [google_dataform_repository.main]
}

resource "google_bigquery_dataset_iam_binding" "dataform_sa_bigquery_access" {
  for_each = google_bigquery_dataset.datasets

  dataset_id = each.value.dataset_id
  role       = "roles/bigquery.dataEditor"
  members = local.use_custom_service_account ? [
    local.dataform_service_account,
    local.effective_sa_member,
  ] : [local.dataform_service_account]
  project = local.project_id
}

resource "google_service_account_iam_member" "dataform_token_creator" {
  count              = local.use_custom_service_account && var.manage_service_account_iam ? 1 : 0
  service_account_id = "projects/${local.project_id}/serviceAccounts/${var.service_account_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = local.dataform_service_account
}
