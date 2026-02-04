# -----------------------------------------------------------------------------
# Azure Container Apps Stack Module
# -----------------------------------------------------------------------------
# This module creates a complete ACA stack including:
# - Resource Group
# - Log Analytics Workspace (observability)
# - Azure Container Registry (ACR)
# - User Assigned Managed Identity
# - Role Assignment (AcrPull)
# - Container App Environment
# - Container App
# -----------------------------------------------------------------------------

locals {
  # Resource naming convention: {project}-{resource}-{environment}
  resource_prefix = "${var.project_name}-${var.environment}"

  # Merge default tags with user-provided tags
  default_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  tags = merge(local.default_tags, var.tags)
}

# =============================================================================
# Resource Group
# =============================================================================

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}"
  location = var.location
  tags     = local.tags
}

# =============================================================================
# Log Analytics Workspace (Observability)
# =============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}

# =============================================================================
# Azure Container Registry
# =============================================================================

resource "azurerm_container_registry" "main" {
  # ACR names must be globally unique, alphanumeric only
  name                = replace("acr${var.project_name}${var.environment}", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = false # Security: Use managed identity instead

  tags = local.tags
}

# =============================================================================
# User Assigned Managed Identity
# =============================================================================
# Used by Container App to pull images from ACR without admin credentials

resource "azurerm_user_assigned_identity" "aca" {
  name                = "id-${local.resource_prefix}-aca"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# =============================================================================
# Role Assignment: AcrPull
# =============================================================================
# Grant the managed identity permission to pull images from ACR

resource "azurerm_role_assignment" "acr_pull" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_user_assigned_identity.aca.principal_id
  skip_service_principal_aad_check = true
}

# =============================================================================
# Azure Key Vault
# =============================================================================
# Secure storage for secrets (connection strings, API keys, etc.)
# The managed identity is granted access to read secrets

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  count = var.enable_key_vault ? 1 : 0

  name                        = "kv-${replace(local.resource_prefix, "-", "")}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # Set to true for production
  enable_rbac_authorization   = false # Using access policies

  # Access policy for Terraform (current client) - to manage secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }

  # Access policy for Container App Managed Identity - to read secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.aca.principal_id

    secret_permissions = [
      "Get", "List"
    ]
  }

  tags = local.tags
}

# =============================================================================
# Application Insights (for APM)
# =============================================================================

resource "azurerm_application_insights" "main" {
  name                = "appi-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = local.tags
}

# =============================================================================
# Key Vault Secrets
# =============================================================================
# Store sensitive values in Key Vault instead of environment variables

resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  count = var.enable_key_vault ? 1 : 0

  name         = "appinsights-connection-string"
  value        = azurerm_application_insights.main[0].connection_string
  key_vault_id = azurerm_key_vault.main[0].id

  depends_on = [azurerm_key_vault.main]
}

# =============================================================================
# Container App Environment
# =============================================================================
# Note: Zone redundancy requires infrastructure_subnet_id
# For simplicity, this module creates a non-VNet integrated environment
# To enable zone redundancy, you would need to add VNet/Subnet resources

resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${local.resource_prefix}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  # Zone redundancy requires VNet integration (infrastructure_subnet_id)
  # Uncomment below when using VNet integration:
  # zone_redundancy_enabled    = var.zone_redundancy_enabled
  # infrastructure_subnet_id   = var.infrastructure_subnet_id

  tags = local.tags
}

# =============================================================================
# Container App
# =============================================================================

resource "azurerm_container_app" "main" {
  name                         = "ca-${local.resource_prefix}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = var.revision_mode

  tags = local.tags

  # Managed Identity for ACR pull
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca.id]
  }

  # Registry configuration using managed identity
  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.aca.id
  }

  # Secrets from Key Vault (when enabled)
  dynamic "secret" {
    for_each = var.enable_key_vault ? [1] : []
    content {
      name                = "appinsights-connection-string"
      key_vault_secret_id = azurerm_key_vault_secret.appinsights_connection_string[0].versionless_id
      identity            = azurerm_user_assigned_identity.aca.id
    }
  }

  # Ingress configuration
  ingress {
    external_enabled = true
    target_port      = var.container_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  # Container template
  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.project_name
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      # Environment variables
      dynamic "env" {
        for_each = concat(
          var.environment_variables,
          [
            { name = "ENVIRONMENT", value = var.environment },
            { name = "LOG_LEVEL", value = var.environment == "prod" ? "INFO" : "DEBUG" }
          ]
        )
        content {
          name  = env.value.name
          value = env.value.value
        }
      }

# Secret-backed environment variable for Application Insights
  dynamic "env" {
    for_each = var.enable_key_vault ? [1] : []
    content {
      name        = "APPLICATIONINSIGHTS_CONNECTION_STRING"
      secret_name = "appinsights-connection-string"
    }
  }

  # Direct environment variable for Application Insights (when Key Vault is not enabled)
  dynamic "env" {
    for_each = var.enable_key_vault ? [] : [1]
    content {
      name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
      value = azurerm_application_insights.main.connection_string
        }
      }

      # Liveness probe - checks if the container is running
      liveness_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = var.liveness_probe_path

        initial_delay           = 10
        interval_seconds        = 30
        timeout                 = 5
        failure_count_threshold = 3
      }

      # Readiness probe - checks if the container is ready to receive traffic
      readiness_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = var.readiness_probe_path

        interval_seconds        = 10
        timeout                 = 3
        failure_count_threshold = 3
        success_count_threshold = 1
      }

      # Startup probe - checks if the container has started
      startup_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = var.health_probe_path

        interval_seconds        = 10
        timeout                 = 3
        failure_count_threshold = 30
      }
    }
  }

  # Ensure dependencies are complete before deploying
  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_application_insights.main
  ]
}
