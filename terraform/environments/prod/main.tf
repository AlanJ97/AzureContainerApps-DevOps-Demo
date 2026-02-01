# -----------------------------------------------------------------------------
# Prod Environment - Main Configuration
# -----------------------------------------------------------------------------
# This configuration deploys the ACA stack for production with:
# - Zone redundancy enabled for high availability
# - Premium ACR for better performance
# - Higher resource allocation
# - Always-on replicas
# -----------------------------------------------------------------------------

module "aca_stack" {
  source = "../../modules/aca-stack"

  # General Configuration
  project_name = var.project_name
  environment  = "prod"
  location     = var.location
  tags         = var.tags

  # Container Registry (Standard for prod - Premium if geo-replication needed)
  acr_sku = "Standard"

  # Container App Environment
  # Note: Zone redundancy requires VNet integration (infrastructure_subnet_id)
  log_retention_days = 90  # Longer retention for compliance

  # Container App Configuration (production-grade)
  container_image  = var.container_image
  container_port   = var.container_port
  container_cpu    = 0.5
  container_memory = "1Gi"
  min_replicas     = 2  # Always-on for availability
  max_replicas     = 10
  revision_mode    = "Multiple"  # Enable blue-green deployments

  # Health Probes
  health_probe_path    = "/health"
  readiness_probe_path = "/health/ready"
  liveness_probe_path  = "/health/live"

  # Environment Variables
  environment_variables = [
    { name = "APP_NAME", value = var.project_name },
    { name = "DEBUG", value = "false" }
  ]
}
