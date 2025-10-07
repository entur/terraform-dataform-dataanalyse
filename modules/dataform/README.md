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
| [google_project_iam_member.workflow_runner_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.workflow](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.workflow_runner_additional_act_as](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.workflow_runner_dataform_act_as](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_secret_manager_secret_iam_member.dataform_secret_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret.github_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret) | data source |
| [google_secret_manager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app_id](#input_app_id) | Entur application ID | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input_env) | Environment descriptor (i.e. 'dev', 'tst', 'prd'). | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github_repo_url](#input_github_repo_url) | GitHub repository URL | `string` | n/a | yes |
| <a name="input_branch_name"></a> [branch_name](#input_branch_name) | Branch name for the GitHub repository | `string` | `"main"` | no |
| <a name="input_dataform_workflows"></a> [dataform_workflows](#input_dataform_workflows) | Dataform workflows to be created | <pre>map(object({<br/>    cron_schedule        = string<br/>    tags                 = list(string)<br/>    include_dependencies = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_extra_labels"></a> [extra_labels](#input_extra_labels) | extra labels to be applied to all resources (in addition to init module labels) | `map(string)` | `{}` | no |
| <a name="input_github_default_branch"></a> [github_default_branch](#input_github_default_branch) | Default branch for the GitHub repository | `string` | `"main"` | no |
| <a name="input_github_secret_name"></a> [github_secret_name](#input_github_secret_name) | Name of the GitHub access token in Secret Manager | `string` | `"github-token"` | no |
| <a name="input_location"></a> [location](#input_location) | Location for gcp resources | `string` | `"europe-west1"` | no |
| <a name="input_runner_service_account_description"></a> [runner_service_account_description](#input_runner_service_account_description) | Description to apply to the runner service account when it is created. | `string` | `"Service account used to run Dataform workflows"` | no |
| <a name="input_runner_service_account_display_name"></a> [runner_service_account_display_name](#input_runner_service_account_display_name) | Display name to apply to the runner service account when it is created. | `string` | `"Dataform workflow runner"` | no |
| <a name="input_runner_service_account_email"></a> [runner_service_account_email](#input_runner_service_account_email) | Existing service account email to run Dataform workflows. Leave null to let the module create one. | `string` | `null` | no |
| <a name="input_runner_service_account_id"></a> [runner_service_account_id](#input_runner_service_account_id) | Account ID to use when creating the runner service account (omit domain). Defaults to a derived value based on app, env and repository. | `string` | `null` | no |
| <a name="input_runner_service_account_project"></a> [runner_service_account_project](#input_runner_service_account_project) | Project ID for the existing runner service account. Defaults to the target project when omitted. | `string` | `null` | no |
| <a name="input_runner_service_account_project_roles"></a> [runner_service_account_project_roles](#input_runner_service_account_project_roles) | Project-level roles to bind to the runner service account. | `list(string)` | <pre>[<br/>  "roles/bigquery.dataEditor",<br/>  "roles/bigquery.jobUser"<br/>]</pre> | no |
| <a name="input_runner_service_account_user_members"></a> [runner_service_account_user_members](#input_runner_service_account_user_members) | Additional principals to grant roles/iam.serviceAccountUser on the runner service account. | `list(string)` | `[]` | no |
| <a name="input_slack_notification_channel_id"></a> [slack_notification_channel_id](#input_slack_notification_channel_id) | notification channel id for slack alerting | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workflow_service_account_email"></a> [workflow_service_account_email](#output_workflow_service_account_email) | Email address of the service account used to run Dataform workflows. |
<!-- END_TF_DOCS -->