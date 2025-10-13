Project wide permissions (BigQuery Job User) cannot be given through Github Actions, so initial terraform apply needs to be run locally

[Dataform Module](modules/dataform/readme.md)

## Security Model Update: Strict Act-As Mode

### Overview
This module has been updated to comply with Google's mandatory security changes for Dataform (effective mid-2026). The new security model requires:

1. **Custom Service Accounts**: Workflows must use custom service accounts instead of the default Dataform service agent
2. **IAM Permissions**: Users or services invoking workflows must have the `roles/iam.serviceAccountUser` role on the custom service account

### Required Changes for Users

#### 1. Create a Custom Service Account
Before using this module, create a custom service account in your GCP project:

```bash
gcloud iam service-accounts create dataform-workflow-sa \
    --display-name="Dataform Workflow Service Account" \
    --project=YOUR_PROJECT_ID
```

#### 2. Configure the Module
Pass the service account email to the module:

```hcl
module "dataform" {
  source = "./modules/dataform"
  
  # Required: Custom service account email
  service_account_email = "dataform-workflow-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com"
  
  # Optional: Members who need to invoke workflows
  workflow_invoker_members = [
    "user:developer@example.com",
    "serviceAccount:ci-cd@YOUR_PROJECT_ID.iam.gserviceaccount.com"
  ]
  
  # ... other required variables
}
```

#### 3. Grant Required Permissions
The module automatically grants:
- `roles/secretmanager.secretAccessor` - Access to GitHub token secret
- `roles/bigquery.jobUser` - Execute BigQuery jobs
- `roles/bigquery.dataEditor` - Read/write BigQuery data
- `roles/iam.serviceAccountUser` - For specified workflow invokers

### Breaking Changes

⚠️ **BREAKING CHANGE**: The `service_account_email` variable is now required. Users must provide a custom service account.

The following behavior has changed:
- Workflows no longer use the default Dataform service agent
- All IAM permissions are granted to the custom service account
- Users invoking workflows must have `roles/iam.serviceAccountUser` on the custom service account

### Automatic Releases

**Important**: If your repository is not connected to a third-party Git provider (GitHub, GitLab, etc.), automatic releases may be disabled due to these security changes. This is a limitation of the new security model.

### Migration Guide

For existing deployments:

1. Create a custom service account as described above
2. Update your Terraform configuration to include `service_account_email`
3. Add any users/service accounts that need to invoke workflows to `workflow_invoker_members`
4. Run `terraform plan` to review the changes
5. Run `terraform apply` to update your infrastructure

Note: This update will modify existing workflow configurations but should not cause downtime.

