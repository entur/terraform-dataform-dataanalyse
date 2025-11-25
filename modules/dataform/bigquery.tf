
resource "google_bigquery_dataset" "datasets" {
  for_each = var.bigquery_datasets

  dataset_id  = each.value.dataset_id
  location    = each.value.region
  description = each.value.description
  project     = local.project_id
}




