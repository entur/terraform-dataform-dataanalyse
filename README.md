Project wide permissions (BigQuery Job User) cannot be given through Github Actions, so initial terraform apply needs to be run locally


to generate terraform docs run:

```bash
terraform-docs --config .terraform-docs.yml ./modules/dataform
```

## Creating Dataform Folder Structure

To create the Dataform folder structure and example files, run the following command from the root of the repository:

```bash
bash scripts/create_dataform_folder_structure.sh <target-path>
```