# -----------------------------------------------------------------------------
# Output Values for ACA Stack Module
# -----------------------------------------------------------------------------
# These outputs expose important information about the created resources
# for use in CI/CD pipelines and other configurations
# -----------------------------------------------------------------------------

# =============================================================================
# Resource Group
# =============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

# =============================================================================
# Container Registry
# =============================================================================

output "acr_login_server" {
  description = "Login server URL for Azure Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "acr_id" {
  description = "Resource ID of the Azure Container Registry"
  value       = azurerm_container_registry.main.id
}

# =============================================================================
# Managed Identity
# =============================================================================

output "managed_identity_id" {
  description = "Resource ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.aca.id
}

output "managed_identity_client_id" {
  description = "Client ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.aca.client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.aca.principal_id
}

# =============================================================================
# Container App Environment
# =============================================================================

output "container_app_environment_id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.main.id
}

output "container_app_environment_name" {
  description = "Name of the Container App Environment"
  value       = azurerm_container_app_environment.main.name
}

output "container_app_environment_default_domain" {
  description = "Default domain of the Container App Environment"
  value       = azurerm_container_app_environment.main.default_domain
}

# =============================================================================
# Container App
# =============================================================================

output "container_app_id" {
  description = "ID of the Container App"
  value       = azurerm_container_app.main.id
}

output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.main.name
}

output "container_app_fqdn" {
  description = "Fully qualified domain name of the Container App"
  value       = azurerm_container_app.main.ingress[0].fqdn
}

output "container_app_url" {
  description = "HTTPS URL of the Container App"
  value       = "https://${azurerm_container_app.main.ingress[0].fqdn}"
}

output "container_app_latest_revision_name" {
  description = "Name of the latest revision"
  value       = azurerm_container_app.main.latest_revision_name
}

# =============================================================================
# Log Analytics
# =============================================================================

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

# =============================================================================
# Key Vault (when enabled)
# =============================================================================

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.main[0].id : null
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.main[0].name : null
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.main[0].vault_uri : null
}

# =============================================================================
# Application Insights (when enabled)
# =============================================================================

output "application_insights_id" {
  description = "ID of Application Insights"
  value       = var.enable_key_vault ? azurerm_application_insights.main[0].id : null
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights (sensitive)"
  value       = var.enable_key_vault ? azurerm_application_insights.main[0].connection_string : null
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights (sensitive)"
  value       = var.enable_key_vault ? azurerm_application_insights.main[0].instrumentation_key : null
  sensitive   = true
}

# =============================================================================
# Monitoring & Alerting
# =============================================================================

output "dashboard_id" {
  description = "ID of the Azure Portal dashboard"
  value       = var.enable_monitoring_dashboard ? azurerm_portal_dashboard.monitoring[0].id : null
}

output "action_group_id" {
  description = "ID of the monitoring action group"
  value       = var.enable_alerts && length(var.alert_email_addresses) > 0 ? azurerm_monitor_action_group.email[0].id : null
}

output "alert_rules" {
  description = "Map of created alert rules"
  value = var.enable_alerts && length(var.alert_email_addresses) > 0 ? {
    cpu_usage        = azurerm_monitor_metric_alert.cpu_usage[0].id
    memory_usage     = azurerm_monitor_metric_alert.memory_usage[0].id
    http_errors      = azurerm_monitor_metric_alert.http_errors[0].id
    container_restart = azurerm_monitor_metric_alert.container_restart[0].id
    app_errors       = var.enable_key_vault ? azurerm_monitor_scheduled_query_rules_alert_v2.app_errors[0].id : null
  } : {}
}
