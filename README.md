Project wide permissions (BigQuery Job User) cannot be given through Github Actions, so initial terraform apply needs to be run locally


to generate terraform docs run:

```bash
terraform-docs --config .terraform-docs.yml ./modules/dataform
```