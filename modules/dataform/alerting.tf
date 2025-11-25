locals {
  # Create a map of workflow names to their release config names for alerting
  workflow_release_configs = {
    for k, v in var.dataform_workflows : k => (
      v.release_config != null ?
      v.release_config :
      (length(var.dataform_release_configs) == 0 ?
        coalesce(var.dataform_release_config_name, var.branch_name) :
        null # Will need to be specified if multiple release configs exist
      )
    )
  }
}

resource "google_monitoring_alert_policy" "workflow_run_failed" {
  for_each = var.slack_notification_channel_id == null ? {} : google_dataform_repository_workflow_config.main

  project               = local.project_id
  display_name          = "Dataform Workflow Failure Alert for ${local.github_repo_name} - ${each.key}"
  notification_channels = [local.notification_channel_id]
  combiner              = "OR"

  conditions {
    display_name = "Dataform Workflow Execution Failed for ${local.github_repo_name} - ${each.key}"

    condition_matched_log {
      filter = templatefile("${path.module}/templates/dataform_logging_metric.tftpl",
        {
          release_config_id = (
            length(var.dataform_release_configs) > 0 && local.workflow_release_configs[each.key] != null ?
            local.workflow_release_configs[each.key] :
            google_dataform_repository_release_config.main[0].name
          )
          workflow_config_id     = each.value.name
          dataform_repository_id = each.value.repository
      })
    }
  }

  alert_strategy {
    notification_prompts = ["OPENED"] # Only notify once when the alert is opened
    auto_close           = "604800s"  # 7 days
    notification_rate_limit {
      period = "3600s" # 1 hour
    }
  }

  documentation {
    content = templatefile("${path.module}/templates/slack_alert_message.tftpl", {
      release_config_id = (
        length(var.dataform_release_configs) > 0 && local.workflow_release_configs[each.key] != null ?
        local.workflow_release_configs[each.key] :
        google_dataform_repository_release_config.main[0].name
      )
      workflow_config_id     = each.value.name
      dataform_repository_id = each.value.repository
    })
  }
  user_labels = local.labels

}
