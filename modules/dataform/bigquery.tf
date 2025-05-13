

resource "google_bigquery_dataset" "main" {
  for_each = local.bigquery_datasets

  project    = local.project_id
  dataset_id = each.value
  location   = var.region

  labels = var.labels
}
