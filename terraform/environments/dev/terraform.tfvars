# -----------------------------------------------------------------------------
# Dev Environment - Variable Values
# -----------------------------------------------------------------------------
# Customize these values for your deployment
# -----------------------------------------------------------------------------

project_name = "aca-devops-demo"
location     = "eastus2"

tags = {
  CostCenter = "Development"
  Owner      = "DevOps-Team"
}

# Container configuration (update after building your image)
# container_image = "acrdevopsdev.azurecr.io/aca-devops-demo:latest"
container_port = 8000
