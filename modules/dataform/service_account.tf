resource "google_service_account" "workflow" {
  count        = var.runner_service_account_email == null ? 1 : 0
  project      = local.service_account_project
  account_id   = local.service_account_id
  display_name = var.runner_service_account_display_name
  description  = var.runner_service_account_description

  lifecycle {
    precondition {
      condition     = length(local.service_account_id) >= 6 && length(local.service_account_id) <= 30
      error_message = "Derived service account id must be between 6 and 30 characters. Override runner_service_account_id if needed."
    }
  }
}
