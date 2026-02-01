# -----------------------------------------------------------------------------
# Terraform and Provider Version Constraints
# -----------------------------------------------------------------------------
# This module requires Terraform 1.5+ for improved variable validation
# and the AzureRM provider 4.0+ for Container Apps API 2025-07-01
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}
