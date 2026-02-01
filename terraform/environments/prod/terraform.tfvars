# -----------------------------------------------------------------------------
# Prod Environment - Variable Values
# -----------------------------------------------------------------------------
# Production configuration with higher resources and HA settings
# -----------------------------------------------------------------------------

project_name = "aca-devops-demo"
location     = "eastus2"

tags = {
  CostCenter  = "Production"
  Owner       = "DevOps-Team"
  Criticality = "High"
}

# Container configuration (update after building your image)
# container_image = "acrdevopsprod.azurecr.io/aca-devops-demo:v1.0.0"
container_port = 8000
