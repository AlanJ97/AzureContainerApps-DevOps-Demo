# =============================================================================
# Monitoring Resources: Dashboards and Alerts
# =============================================================================
# This file contains Azure Monitor dashboard and alert configurations
# =============================================================================

# =============================================================================
# Action Group for Alert Notifications
# =============================================================================

resource "azurerm_monitor_action_group" "email" {
  count = var.enable_alerts && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "ag-${local.resource_prefix}-email"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = substr("aca-alert", 0, 12) # Max 12 characters

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name                    = "Email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  tags = local.tags
}

# =============================================================================
# Metric Alert Rules
# =============================================================================

# Alert: High CPU Usage
resource "azurerm_monitor_metric_alert" "cpu_usage" {
  count = var.enable_alerts && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "alert-${local.resource_prefix}-cpu-high"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_container_app.main.id]
  description         = "Alert when CPU usage exceeds ${var.alert_cpu_threshold}%"
  severity            = 2
  frequency           = "PT1M"  # Check every 1 minute
  window_size         = "PT5M"  # Over 5 minute window
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "UsageNanoCores"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.alert_cpu_threshold * 10000000 # Convert percentage to nanocores (assuming 1 CPU = 1B nanocores)
  }

  action {
    action_group_id = azurerm_monitor_action_group.email[0].id
  }

  tags = local.tags
}

# Alert: High Memory Usage
resource "azurerm_monitor_metric_alert" "memory_usage" {
  count = var.enable_alerts && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "alert-${local.resource_prefix}-memory-high"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_container_app.main.id]
  description         = "Alert when memory usage exceeds ${var.alert_memory_threshold}%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "WorkingSetBytes"
    aggregation      = "Average"
    operator         = "GreaterThan"
    # Assuming 512MB memory allocation, threshold is percentage of that
    threshold        = (var.alert_memory_threshold / 100) * 512 * 1024 * 1024
  }

  action {
    action_group_id = azurerm_monitor_action_group.email[0].id
  }

  tags = local.tags
}

# Alert: HTTP 5xx Errors
resource "azurerm_monitor_metric_alert" "http_errors" {
  count = var.enable_alerts && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "alert-${local.resource_prefix}-http-errors"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_container_app.main.id]
  description         = "Alert when HTTP 5xx errors exceed ${var.alert_http_error_threshold} per minute"
  severity            = 1 # Higher severity for errors
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.alert_http_error_threshold

    dimension {
      name     = "statusCode"
      operator = "Include"
      values   = ["5xx"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.email[0].id
  }

  tags = local.tags
}

# Alert: Container Restart
resource "azurerm_monitor_metric_alert" "container_restart" {
  count = var.enable_alerts && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "alert-${local.resource_prefix}-restart"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_container_app.main.id]
  description         = "Alert when container restarts detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "RestartCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 3 # More than 3 restarts in 15 minutes
  }

  action {
    action_group_id = azurerm_monitor_action_group.email[0].id
  }

  tags = local.tags
}

# =============================================================================
# Application Insights Alert Rules
# =============================================================================

# Alert: Application Errors (from logs)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "app_errors" {
  count = var.enable_alerts && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "alert-${local.resource_prefix}-app-errors"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when application errors are detected in logs"
  severity            = 2
  enabled             = true
  
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  
  criteria {
    query                   = <<-QUERY
      traces
      | where severityLevel >= 3  // Error or Critical
      | summarize ErrorCount = count() by bin(timestamp, 5m)
      | where ErrorCount > 5
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.email[0].id]
  }

  tags = local.tags
}

# =============================================================================
# Azure Portal Dashboard
# =============================================================================

resource "azurerm_portal_dashboard" "monitoring" {
  count = var.enable_monitoring_dashboard ? 1 : 0

  name                = "dashboard-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = merge(
    local.tags,
    {
      "hidden-title" = "Container Apps DevOps Demo - ${title(var.environment)}"
    }
  )

  dashboard_properties = templatefile("${path.module}/dashboard.tpl", {
    subscription_id        = data.azurerm_client_config.current.subscription_id
    resource_group_name    = azurerm_resource_group.main.name
    container_app_id       = azurerm_container_app.main.id
    container_app_name     = azurerm_container_app.main.name
    app_insights_id        = var.enable_key_vault ? azurerm_application_insights.main[0].id : ""
    app_insights_name      = var.enable_key_vault ? azurerm_application_insights.main[0].name : ""
    log_analytics_id       = azurerm_log_analytics_workspace.main.id
    environment_name       = var.environment
    project_name           = var.project_name
  })
}
