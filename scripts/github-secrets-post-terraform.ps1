# =============================================================================
# GitHub Secrets - Post Terraform Setup (PowerShell)
# =============================================================================
# This script sets additional GitHub secrets AFTER Terraform has been applied.
# These secrets come from Terraform outputs (ACR name, Resource Group, etc.)
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Terraform has been applied (terraform apply completed)
#
# Usage:
#   cd terraform/environments/dev
#   ..\..\..\scripts\github-secrets-post-terraform.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

# =============================================================================
# Configuration
# =============================================================================
$REPO = "AlanJ97/AzureContainerApps-DevOps-Demo"  # Change to your repo

# =============================================================================
# Script Start
# =============================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Post-Terraform GitHub Secrets Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if gh is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] GitHub CLI (gh) is not installed." -ForegroundColor Red
    exit 1
}

# Check if terraform is installed
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Terraform is not installed." -ForegroundColor Red
    exit 1
}

# Check if we're in a terraform directory
if (-not (Test-Path "terraform.tfstate") -and -not (Test-Path ".terraform")) {
    Write-Host "[WARNING] Not in a Terraform directory. Make sure Terraform has been applied." -ForegroundColor Yellow
    Write-Host "          Run this from: terraform/environments/dev or terraform/environments/prod" -ForegroundColor Yellow
}

# =============================================================================
# Get Terraform Outputs
# =============================================================================
Write-Host "[1/4] Getting Terraform outputs..." -ForegroundColor Yellow

try {
    $ACR_NAME = terraform output -raw acr_name 2>$null
    $RESOURCE_GROUP = terraform output -raw resource_group_name 2>$null
    $CONTAINER_APP = terraform output -raw container_app_name 2>$null
    
    if ([string]::IsNullOrEmpty($ACR_NAME)) {
        Write-Host "[ERROR] Could not get acr_name from Terraform outputs" -ForegroundColor Red
        Write-Host "        Make sure Terraform has been applied successfully" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "[ERROR] Failed to get Terraform outputs: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Terraform outputs retrieved:" -ForegroundColor Green
Write-Host "     ACR_NAME:            $ACR_NAME" -ForegroundColor Gray
Write-Host "     RESOURCE_GROUP_NAME: $RESOURCE_GROUP" -ForegroundColor Gray
Write-Host "     CONTAINER_APP_NAME:  $CONTAINER_APP" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# Set GitHub Secrets
# =============================================================================
Write-Host "[2/4] Setting ACR_NAME..." -ForegroundColor Yellow
$ACR_NAME | gh secret set ACR_NAME --repo $REPO
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Failed to set ACR_NAME" -ForegroundColor Red; exit 1 }
Write-Host "[OK] ACR_NAME set" -ForegroundColor Green

Write-Host "[3/4] Setting RESOURCE_GROUP_NAME..." -ForegroundColor Yellow
$RESOURCE_GROUP | gh secret set RESOURCE_GROUP_NAME --repo $REPO
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Failed to set RESOURCE_GROUP_NAME" -ForegroundColor Red; exit 1 }
Write-Host "[OK] RESOURCE_GROUP_NAME set" -ForegroundColor Green

Write-Host "[4/4] Setting CONTAINER_APP_NAME..." -ForegroundColor Yellow
$CONTAINER_APP | gh secret set CONTAINER_APP_NAME --repo $REPO
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Failed to set CONTAINER_APP_NAME" -ForegroundColor Red; exit 1 }
Write-Host "[OK] CONTAINER_APP_NAME set" -ForegroundColor Green

# =============================================================================
# Summary
# =============================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Post-Terraform Secrets Configured!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Additional secrets set in repository: $REPO" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [x] ACR_NAME            = $ACR_NAME" -ForegroundColor Green
Write-Host "  [x] RESOURCE_GROUP_NAME = $RESOURCE_GROUP" -ForegroundColor Green
Write-Host "  [x] CONTAINER_APP_NAME  = $CONTAINER_APP" -ForegroundColor Green
Write-Host ""
Write-Host "The App CD workflow can now deploy to Azure Container Apps!" -ForegroundColor Cyan
Write-Host ""

# List all secrets
Write-Host "[INFO] All repository secrets:" -ForegroundColor Yellow
gh secret list --repo $REPO
Write-Host ""
