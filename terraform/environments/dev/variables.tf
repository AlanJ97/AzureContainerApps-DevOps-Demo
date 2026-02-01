# -----------------------------------------------------------------------------
# Input Variables - Dev Environment
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
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

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8000
}
