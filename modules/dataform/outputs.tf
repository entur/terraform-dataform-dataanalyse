output "effective_service_account" {
  description = "The service account actively used by the Dataform repository at runtime. Reflects the custom SA only when both service_account_email is set and activate_service_account is true."
  value       = local.active_sa_email
}
