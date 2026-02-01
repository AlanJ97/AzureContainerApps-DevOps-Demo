# -----------------------------------------------------------------------------
# Outputs - Dev Environment
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.aca_stack.resource_group_name
}

output "acr_login_server" {
  description = "ACR login server for docker push"
  value       = module.aca_stack.acr_login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = module.aca_stack.acr_name
}

output "container_app_url" {
  description = "URL of the deployed Container App"
  value       = module.aca_stack.container_app_url
}

output "container_app_name" {
  description = "Name of the Container App"
  value       = module.aca_stack.container_app_name
}

output "managed_identity_client_id" {
  description = "Client ID of the managed identity for CI/CD"
  value       = module.aca_stack.managed_identity_client_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace for monitoring"
  value       = module.aca_stack.log_analytics_workspace_name
}
