# -----------------------------------------------------------------------------
# Terraform and Provider Configuration - Prod Environment
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }

  # Backend configuration - uncomment after creating storage account
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstateprod"
  #   container_name       = "tfstate"
  #   key                  = "prod.terraform.tfstate"
  #   use_oidc             = true
  #   use_azuread_auth     = true
  # }
}

provider "azurerm" {
  features {
    resource_group {
      # Prevent accidental deletion of resources in production
      prevent_deletion_if_contains_resources = true
    }
  }

  # For GitHub Actions OIDC authentication
  # use_oidc = true
}
