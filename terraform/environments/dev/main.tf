# -----------------------------------------------------------------------------
# Dev Environment - Main Configuration
# -----------------------------------------------------------------------------
# This configuration deploys the ACA stack for the development environment
# with cost-optimized settings (no zone redundancy, minimal resources)
# -----------------------------------------------------------------------------

module "aca_stack" {
  source = "../../modules/aca-stack"

  # General Configuration
  project_name = var.project_name
  environment  = "dev"
  location     = var.location
  tags         = var.tags

  # Container Registry (Basic for dev)
  acr_sku = "Basic"

  # Container App Environment
  log_retention_days = 30

  # Container App Configuration
  container_image  = var.container_image
  container_port   = var.container_port
  container_cpu    = 0.25
  container_memory = "0.5Gi"
  min_replicas     = 0  # Scale to zero when idle (cost saving)
  max_replicas     = 2
  revision_mode    = "Single"

  # Health Probes
  health_probe_path    = "/health"
  readiness_probe_path = "/health/ready"
  liveness_probe_path  = "/health/live"

  # Environment Variables
  environment_variables = [
    { name = "APP_NAME", value = var.project_name },
    { name = "DEBUG", value = "true" }
  ]

  # Monitoring & Alerting
  enable_monitoring_dashboard = true
  enable_alerts              = true
  alert_email_addresses      = var.alert_email_addresses
  alert_cpu_threshold        = 80
  alert_memory_threshold     = 80
  alert_http_error_threshold = 10
}
