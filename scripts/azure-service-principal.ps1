# =============================================================================
# Azure Service Principal Setup Script (PowerShell)
# =============================================================================
# This script creates a Service Principal for GitHub Actions to authenticate
# with Azure. The credentials will be displayed for manual GitHub Secrets setup.
#
# Prerequisites:
#   - Azure CLI (az) installed and authenticated
#   - Sufficient permissions to create Service Principals (Azure AD)
#
# Usage:
#   .\scripts\azure-service-principal.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

# =============================================================================
# Configuration - MODIFY THESE VALUES
# =============================================================================
$SP_NAME = "sp-github-aca-demo"
$ROLE = "Contributor"  # Or "Owner" if you need to assign roles

# =============================================================================
# Script Start
# =============================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Azure Service Principal Setup" -ForegroundColor Cyan
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

$SUBSCRIPTION_ID = $account.id
$TENANT_ID = $account.tenantId

Write-Host "[OK] Logged in as: $($account.user.name)" -ForegroundColor Green
Write-Host "[OK] Subscription: $($account.name)" -ForegroundColor Green
Write-Host "[OK] Subscription ID: $SUBSCRIPTION_ID" -ForegroundColor Green
Write-Host ""

# Create Service Principal
Write-Host "[1/2] Creating Service Principal: $SP_NAME" -ForegroundColor Yellow
Write-Host "      Role: $ROLE" -ForegroundColor Gray
Write-Host "      Scope: /subscriptions/$SUBSCRIPTION_ID" -ForegroundColor Gray
Write-Host ""

$spOutput = az ad sp create-for-rbac `
    --name $SP_NAME `
    --role $ROLE `
    --scopes "/subscriptions/$SUBSCRIPTION_ID" `
    --output json

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to create Service Principal" -ForegroundColor Red
    exit 1
}

$sp = $spOutput | ConvertFrom-Json

Write-Host "[OK] Service Principal created!" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Output - GitHub Secrets
# =============================================================================
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  GitHub Secrets (Add these manually)" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Go to: GitHub Repo > Settings > Secrets and variables > Actions" -ForegroundColor Cyan
Write-Host "Add the following secrets:" -ForegroundColor Cyan
Write-Host ""
Write-Host "┌──────────────────────────────────────────────────────────────┐" -ForegroundColor White
Write-Host "│ Secret Name              │ Value                             │" -ForegroundColor White
Write-Host "├──────────────────────────────────────────────────────────────┤" -ForegroundColor White
Write-Host "│ AZURE_CLIENT_ID          │ $($sp.appId)" -ForegroundColor Yellow
Write-Host "│ AZURE_CLIENT_SECRET      │ $($sp.password)" -ForegroundColor Yellow
Write-Host "│ AZURE_SUBSCRIPTION_ID    │ $SUBSCRIPTION_ID" -ForegroundColor Yellow
Write-Host "│ AZURE_TENANT_ID          │ $($sp.tenant)" -ForegroundColor Yellow
Write-Host "└──────────────────────────────────────────────────────────────┘" -ForegroundColor White
Write-Host ""

# =============================================================================
# Save to file (optional, for reference)
# =============================================================================
$secretsFile = "scripts/.azure-secrets.json"
$secretsContent = @{
    AZURE_CLIENT_ID = $sp.appId
    AZURE_CLIENT_SECRET = $sp.password
    AZURE_SUBSCRIPTION_ID = $SUBSCRIPTION_ID
    AZURE_TENANT_ID = $sp.tenant
    _note = "DO NOT COMMIT THIS FILE! Add to .gitignore"
    _created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    _service_principal_name = $SP_NAME
} | ConvertTo-Json

$secretsContent | Out-File -FilePath $secretsFile -Encoding utf8

Write-Host "[INFO] Secrets saved to: $secretsFile" -ForegroundColor Gray
Write-Host "[WARNING] DO NOT COMMIT THIS FILE! It's already in .gitignore" -ForegroundColor Red
Write-Host ""

# =============================================================================
# Additional Secrets Needed After Terraform Apply
# =============================================================================
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "  Additional Secrets (After Terraform)" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "After running Terraform, add these secrets from Terraform outputs:" -ForegroundColor Cyan
Write-Host ""
Write-Host "│ ACR_NAME               │ From: terraform output acr_name" -ForegroundColor Gray
Write-Host "│ RESOURCE_GROUP_NAME    │ From: terraform output resource_group_name" -ForegroundColor Gray
Write-Host "│ CONTAINER_APP_NAME     │ From: terraform output container_app_name" -ForegroundColor Gray
Write-Host ""
Write-Host "Or run this after Terraform apply:" -ForegroundColor Cyan
Write-Host '  cd terraform/environments/dev && terraform output' -ForegroundColor Gray
Write-Host ""
