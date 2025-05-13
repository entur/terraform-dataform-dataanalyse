
resource "google_logging_metric" "dataform_failed_workflows" {
  project     = local.project_id
  name        = "dataform_failed_workflows"
  description = "Log-based metric for failed Dataform workflows"
  filter = templatefile("${path.module}/templates/dataform_logging_metric.tftpl", {
    release_config_id      = google_dataform_repository_release_config.main.name
    workflow_config_id     = google_dataform_repository_workflow_config.main.name
    dataform_repository_id = resource.google_dataform_repository.main.name
  })

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "workflow_run_failed" {
  count                 = var.slack_notification_channel_id == null ? 0 : 1
  project               = local.project_id
  display_name          = "Dataform Workflow Failure Alert"
  notification_channels = [var.slack_notification_channel_id]
  combiner              = "OR"


  conditions {
    display_name = "Dataform Workflow Execution Failed"
    condition_threshold {
      filter     = "resource.type = \"dataform.googleapis.com/Repository\" AND metric.type = \"logging.googleapis.com/user/dataform_failed_workflows\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      trigger {
        count = 1
      }
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  alert_strategy {
    notification_prompts = ["OPENED"] # Only notify once when the alert is opened
    auto_close           = "604800s"  # 7 days
  }

  documentation {
    content = <<EOF
    Dataform release config ${resource.google_dataform_repository_release_config.main.name}  workflow failed.
    EOF
  }
  user_labels = local.labels
}