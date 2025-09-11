<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.11.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.30.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 6.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.30.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 6.30.0 |

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
| [google_bigquery_dataset_iam_member.source_data_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_monitoring_alert_policy.workflow_run_failed](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_project_iam_member.project_bigquery_job_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.service_account_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret_iam_member.dataform_secret_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret.github_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret) | data source |
| [google_secret_manager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Entur application ID | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment descriptor (i.e. 'dev', 'tst', 'prd'). | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | GitHub repository URL | `string` | n/a | yes |
| <a name="input_branch_name"></a> [branch\_name](#input\_branch\_name) | Branch name for the GitHub repository | `string` | `"main"` | no |
| <a name="input_dataform_workflows"></a> [dataform\_workflows](#input\_dataform\_workflows) | Dataform workflows to be created | <pre>map(object({<br/>    cron_schedule        = string<br/>    tags                 = list(string)<br/>    include_dependencies = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_extra_labels"></a> [extra\_labels](#input\_extra\_labels) | extra labels to be applied to all resources (in addition to init module labels) | `map(string)` | `{}` | no |
| <a name="input_github_default_branch"></a> [github\_default\_branch](#input\_github\_default\_branch) | Default branch for the GitHub repository | `string` | `"main"` | no |
| <a name="input_github_secret_name"></a> [github\_secret\_name](#input\_github\_secret\_name) | Name of the GitHub access token in Secret Manager | `string` | `"github-token"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location for gcp resources | `string` | `"europe-west1"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for gcp resources | `string` | `"EU"` | no |
| <a name="input_slack_notification_channel_id"></a> [slack\_notification\_channel\_id](#input\_slack\_notification\_channel\_id) | notification channel id for slack alerting | `string` | `null` | no |
| <a name="input_source_datasets"></a> [source\_datasets](#input\_source\_datasets) | Map of source datasets. Dataform service account will be granted access to these datasets if owned by Team Data. | <pre>map(object({<br/>    project_id = string<br/>    dataset_id = string<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->