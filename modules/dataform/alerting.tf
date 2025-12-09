resource "google_monitoring_alert_policy" "workflow_run_failed" {
  for_each = var.slack_notification_channel_id == null ? {} : google_dataform_repository_workflow_config.main

  project               = local.project_id
  display_name          = "Dataform Workflow Failure Alert for ${local.github_repo_name} - ${each.value.name}"
  notification_channels = [local.notification_channel_id]
  combiner              = "OR"

  conditions {
    display_name = "Dataform Workflow Execution Failed for ${local.github_repo_name} - ${each.value.name}"

    condition_matched_log {
      filter = templatefile("${path.module}/templates/dataform_logging_metric.tftpl",
        {
          release_config_id      = google_dataform_repository_release_config.main.name
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
      release_config_id      = google_dataform_repository_release_config.main.name
      workflow_config_id     = each.value.name
      dataform_repository_id = each.value.repository
    })
  }
  user_labels = local.labels

}
