# -----------------------------------------------------------------------------
# Terraform and Provider Configuration - Dev Environment
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }

  # Backend configuration for remote state
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformacademo"
    container_name       = "tfstate-dev"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # For GitHub Actions OIDC authentication
  # use_oidc = true
}
