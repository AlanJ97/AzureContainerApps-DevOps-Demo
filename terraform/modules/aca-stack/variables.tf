# -----------------------------------------------------------------------------
# Input Variables for ACA Stack Module
# -----------------------------------------------------------------------------
# These variables allow customization of the Azure Container Apps stack
# for different environments (dev, staging, prod)
# -----------------------------------------------------------------------------

# ================================
# General Configuration
# ================================

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus2"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ================================
# Container Registry Configuration
# ================================

variable "acr_sku" {
  description = "SKU for Azure Container Registry (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be one of: Basic, Standard, Premium."
  }
}

# ================================
# Container App Environment
# ================================

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for the Container App Environment (only settable at creation)"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Log Analytics workspace retention in days (30-730)"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

# ================================
# Key Vault Configuration
# ================================

variable "enable_key_vault" {
  description = "Enable Azure Key Vault for secure secret storage"
  type        = bool
  default     = false
}

# ================================
# Container App Configuration
# ================================

variable "container_image" {
  description = "Container image to deploy (format: registry/image:tag)"
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "CPU allocation for the container (e.g., 0.25, 0.5, 1.0)"
  type        = number
  default     = 0.25

  validation {
    condition     = contains([0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], var.container_cpu)
    error_message = "CPU must be one of: 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0"
  }
}

variable "container_memory" {
  description = "Memory allocation for the container (e.g., 0.5Gi, 1Gi)"
  type        = string
  default     = "0.5Gi"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?Gi$", var.container_memory))
    error_message = "Memory must be in format like '0.5Gi' or '1Gi'."
  }
}

variable "min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum number of container replicas"
  type        = number
  default     = 3
}

variable "revision_mode" {
  description = "Revision mode for the Container App (Single or Multiple)"
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "Revision mode must be 'Single' or 'Multiple'."
  }
}

# ================================
# Environment Variables
# ================================

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ================================
# Health Probes Configuration
# ================================

variable "health_probe_path" {
  description = "Path for health check endpoints"
  type        = string
  default     = "/health"
}

variable "readiness_probe_path" {
  description = "Path for readiness probe"
  type        = string
  default     = "/health/ready"
}

variable "liveness_probe_path" {
  description = "Path for liveness probe"
  type        = string
  default     = "/health/live"
}

# ================================
# Monitoring & Alerting Configuration
# ================================

variable "enable_monitoring_dashboard" {
  description = "Enable Azure Portal dashboard for monitoring"
  type        = bool
  default     = true
}

variable "enable_alerts" {
  description = "Enable monitoring alerts"
  type        = bool
  default     = true
}

variable "alert_email_addresses" {
  description = "Email addresses to receive alerts"
  type        = list(string)
  default     = []
}

variable "alert_cpu_threshold" {
  description = "CPU threshold percentage for alerts"
  type        = number
  default     = 80
}

variable "alert_memory_threshold" {
  description = "Memory threshold percentage for alerts"
  type        = number
  default     = 80
}

variable "alert_http_error_threshold" {
  description = "HTTP 5xx error count threshold per minute"
  type        = number
  default     = 10
}
