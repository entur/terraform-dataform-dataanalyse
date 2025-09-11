#!/usr/bin/env bash
set -euo pipefail

# Check if a path argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <target-path>"
  exit 1
fi

TARGET_PATH="$1"


# Create the target directory and includes subfolders with numbered prefixes and spaces
mkdir -p \
  "$TARGET_PATH/includes/01 sources" \
  "$TARGET_PATH/includes/02 intermediate" \
  "$TARGET_PATH/includes/03 outputs" \
  "$TARGET_PATH/includes/04 extras"

# Create workflow_settings.yaml with the specified content in the target path
cat <<'EOL' > "$TARGET_PATH/workflow_settings.yaml"
defaultProject: ent-data-devops-int-dev
defaultLocation: eu
defaultDataset: dataform
defaultAssertionDataset: dataform_assertions
dataformCoreVersion: 3.0.0
EOL

 # Write raw_data.sqlx in 01 sources
cat <<'EOL' > "$TARGET_PATH/includes/01 sources/raw_data.sqlx"
declare({
    database: 'gcp_project',
    schema: 'gcp_dataset_name',
    name: 'gcp_table_name',
});
EOL

 # Write transform.sqlx in 02 intermediate
cat <<'EOL' > "$TARGET_PATH/includes/02 intermediate/transform.sqlx"
config {
  type: 'table',
  description: 'description'
}

SELECT
  *
FROM $ref('raw_data')

EOL
