# Dataform Terraform Module

## Overview
This module creates and manages Google Cloud Dataform resources including repositories, release configurations, and workflow configurations.

## Security Model: Strict Act-As Mode

⚠️ **Important Security Update**: This module implements Google's mandatory "Strict Act-As" security model for Dataform (required by mid-2026).

### Key Requirements

1. **Custom Service Account**: You must provide a custom service account via the `service_account_email` variable
2. **IAM Permissions**: Users/services invoking workflows need `roles/iam.serviceAccountUser` on the custom service account
3. **No Default Service Agent**: The Dataform service agent is no longer used for workflow execution

### Usage Example

```hcl
module "dataform" {
  source = "./modules/dataform"
  
  # Required variables
  app_id            = "my-app"
  env               = "dev"
  github_repo_url   = "https://github.com/org/repo.git"
  
  # Required: Custom service account for strict act-as mode
  service_account_email = "dataform-workflow-sa@my-project.iam.gserviceaccount.com"
  
  # Optional: Members who need to invoke workflows
  workflow_invoker_members = [
    "user:developer@example.com",
    "serviceAccount:ci-cd@my-project.iam.gserviceaccount.com"
  ]
  
  # Optional: Workflow configurations
  dataform_workflows = {
    daily_etl = {
      cron_schedule        = "0 2 * * *"
      tags                 = ["daily", "etl"]
      include_dependencies = true
    }
  }
}
```

### Custom Service Account Setup

Before using this module, create a custom service account:

```bash
gcloud iam service-accounts create dataform-workflow-sa \
    --display-name="Dataform Workflow Service Account" \
    --project=YOUR_PROJECT_ID
```

The module will automatically grant this service account:
- `roles/secretmanager.secretAccessor` - Access to GitHub tokens
- `roles/bigquery.jobUser` - Execute BigQuery jobs
- `roles/bigquery.dataEditor` - Read/write BigQuery data

### IAM Permissions

Users or service accounts that need to schedule, modify, or run workflows must:
1. Be listed in the `workflow_invoker_members` variable
2. This grants them `roles/iam.serviceAccountUser` on the custom service account

### Automatic Releases

**Note**: If your repository is not connected to a third-party Git provider, automatic releases may be affected by these security changes.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 1.11.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 7.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 6.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.50.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 6.50.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_init"></a> [init](#module\_init) | github.com/entur/terraform-google-init//modules/init | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_dataform_repository.main](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository) | resource |
| [google-beta_google_dataform_repository_release_config.main](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_release_config) | resource |
| [google-beta_google_dataform_repository_workflow_config.main](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_workflow_config) | resource |
| [google_monitoring_alert_policy.workflow_run_failed](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_project_iam_member.project_bigquery_job_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.service_account_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret_iam_member.dataform_secret_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account_iam_member.workflow_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_secret_manager_secret.github_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret) | data source |
| [google_secret_manager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Entur application ID | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment descriptor (i.e. 'dev', 'tst', 'prd'). | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | GitHub repository URL | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Email of the custom service account to use for Dataform workflows. Required for strict act-as mode compliance. | `string` | n/a | yes |
| <a name="input_branch_name"></a> [branch\_name](#input\_branch\_name) | Branch name for the GitHub repository | `string` | `"main"` | no |
| <a name="input_dataform_workflows"></a> [dataform\_workflows](#input\_dataform\_workflows) | Dataform workflows to be created | <pre>map(object({<br/>    cron_schedule        = string<br/>    tags                 = list(string)<br/>    include_dependencies = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_extra_labels"></a> [extra\_labels](#input\_extra\_labels) | extra labels to be applied to all resources (in addition to init module labels) | `map(string)` | `{}` | no |
| <a name="input_github_default_branch"></a> [github\_default\_branch](#input\_github\_default\_branch) | Default branch for the GitHub repository | `string` | `"main"` | no |
| <a name="input_github_secret_name"></a> [github\_secret\_name](#input\_github\_secret\_name) | Name of the GitHub access token in Secret Manager | `string` | `"github-token"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location for gcp resources | `string` | `"europe-west1"` | no |
| <a name="input_slack_notification_channel_id"></a> [slack\_notification\_channel\_id](#input\_slack\_notification\_channel\_id) | notification channel id for slack alerting | `string` | `null` | no |
| <a name="input_workflow_invoker_members"></a> [workflow\_invoker\_members](#input\_workflow\_invoker\_members) | List of members (users or service accounts) that need to invoke workflows. They will be granted roles/iam.serviceAccountUser on the custom service account. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->