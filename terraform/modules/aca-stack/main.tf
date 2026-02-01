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

  # Ensure ACR role assignment is complete before deploying
  depends_on = [azurerm_role_assignment.acr_pull]
}
