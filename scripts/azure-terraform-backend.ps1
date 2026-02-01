# =============================================================================
# Azure Terraform Backend Setup Script (PowerShell)
# =============================================================================
# This script creates the Azure Storage Account for Terraform remote state.
# Run this ONCE before running Terraform for the first time.
#
# Prerequisites:
#   - Azure CLI (az) installed and authenticated
#   - Sufficient permissions to create resources
#
# Usage:
#   .\scripts\azure-terraform-backend.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

# =============================================================================
# Configuration - MODIFY THESE VALUES
# =============================================================================
$RESOURCE_GROUP_NAME = "rg-terraform-state"
$LOCATION = "eastus2"
$STORAGE_ACCOUNT_NAME = "stterraformacademo"  # Must be globally unique, 3-24 chars, lowercase
$CONTAINER_NAME_DEV = "tfstate-dev"
$CONTAINER_NAME_PROD = "tfstate-prod"

# =============================================================================
# Script Start
# =============================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Terraform Backend Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if az is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Azure CLI (az) is not installed. Please install it first." -ForegroundColor Red
    Write-Host "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

# Check if logged in
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "[ERROR] Not logged in to Azure. Please run: az login" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Logged in as: $($account.user.name)" -ForegroundColor Green
Write-Host "[OK] Subscription: $($account.name) ($($account.id))" -ForegroundColor Green
Write-Host ""

# Create Resource Group
Write-Host "[1/4] Creating Resource Group: $RESOURCE_GROUP_NAME" -ForegroundColor Yellow
az group create `
    --name $RESOURCE_GROUP_NAME `
    --location $LOCATION `
    --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to create resource group" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Resource Group created" -ForegroundColor Green

# Create Storage Account
Write-Host "[2/4] Creating Storage Account: $STORAGE_ACCOUNT_NAME" -ForegroundColor Yellow
az storage account create `
    --name $STORAGE_ACCOUNT_NAME `
    --resource-group $RESOURCE_GROUP_NAME `
    --location $LOCATION `
    --sku Standard_LRS `
    --kind StorageV2 `
    --min-tls-version TLS1_2 `
    --allow-blob-public-access false `
    --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to create storage account (name might not be unique)" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Storage Account created" -ForegroundColor Green

# Get Storage Account Key
Write-Host "[3/4] Getting Storage Account Key..." -ForegroundColor Yellow
$ACCOUNT_KEY = az storage account keys list `
    --resource-group $RESOURCE_GROUP_NAME `
    --account-name $STORAGE_ACCOUNT_NAME `
    --query "[0].value" `
    --output tsv

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to get storage account key" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Storage Account Key retrieved" -ForegroundColor Green

# Create Blob Containers
Write-Host "[4/4] Creating Blob Containers..." -ForegroundColor Yellow

az storage container create `
    --name $CONTAINER_NAME_DEV `
    --account-name $STORAGE_ACCOUNT_NAME `
    --account-key $ACCOUNT_KEY `
    --output none

az storage container create `
    --name $CONTAINER_NAME_PROD `
    --account-name $STORAGE_ACCOUNT_NAME `
    --account-key $ACCOUNT_KEY `
    --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to create blob containers" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Blob Containers created" -ForegroundColor Green

# =============================================================================
# Output Summary
# =============================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Terraform Backend Created Successfully!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Use these values in your backend.tf files:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  resource_group_name  = `"$RESOURCE_GROUP_NAME`"" -ForegroundColor White
Write-Host "  storage_account_name = `"$STORAGE_ACCOUNT_NAME`"" -ForegroundColor White
Write-Host "  container_name       = `"$CONTAINER_NAME_DEV`" (dev) or `"$CONTAINER_NAME_PROD`" (prod)" -ForegroundColor White
Write-Host "  key                  = `"terraform.tfstate`"" -ForegroundColor White
Write-Host ""
Write-Host "Example backend.tf:" -ForegroundColor Yellow
Write-Host @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP_NAME"
    storage_account_name = "$STORAGE_ACCOUNT_NAME"
    container_name       = "$CONTAINER_NAME_DEV"
    key                  = "terraform.tfstate"
  }
}
"@ -ForegroundColor Gray
Write-Host ""
