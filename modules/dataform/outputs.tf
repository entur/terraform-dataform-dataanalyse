output "effective_service_account" {
  description = "The service account used by Dataform (custom SA if set, otherwise the default Dataform agent)."
  value       = local.use_custom_service_account ? var.service_account_email : "service-${module.init.app.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
}
