# =============================================================================
# GitHub Secrets Setup Script (PowerShell)
# =============================================================================
# This script sets GitHub repository secrets using the GitHub CLI.
# Run this AFTER creating the Service Principal.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Service Principal created (run azure-service-principal.ps1 first)
#   - Secrets file exists: scripts/.azure-secrets.json
#
# Usage:
#   .\scripts\github-secrets.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

# =============================================================================
# Configuration
# =============================================================================
$SECRETS_FILE = "scripts/.azure-secrets.json"
$REPO = "AlanJ97/AzureContainerApps-DevOps-Demo"  # Change to your repo

# =============================================================================
# Script Start
# =============================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  GitHub Secrets Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if gh is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] GitHub CLI (gh) is not installed. Please install it first." -ForegroundColor Red
    Write-Host "   https://cli.github.com/manual/installation"
    exit 1
}

# Check if authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Not authenticated with GitHub CLI. Please run: gh auth login" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] GitHub CLI is authenticated" -ForegroundColor Green

# Check if secrets file exists
if (-not (Test-Path $SECRETS_FILE)) {
    Write-Host "[ERROR] Secrets file not found: $SECRETS_FILE" -ForegroundColor Red
    Write-Host "        Run azure-service-principal.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Load secrets
$secrets = Get-Content $SECRETS_FILE | ConvertFrom-Json
Write-Host "[OK] Loaded secrets from: $SECRETS_FILE" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Set GitHub Secrets
# =============================================================================
Write-Host "[1/4] Setting AZURE_CLIENT_ID..." -ForegroundColor Yellow
$secrets.AZURE_CLIENT_ID | gh secret set AZURE_CLIENT_ID --repo $REPO
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Failed to set AZURE_CLIENT_ID" -ForegroundColor Red; exit 1 }
Write-Host "[OK] AZURE_CLIENT_ID set" -ForegroundColor Green

Write-Host "[2/4] Setting AZURE_CLIENT_SECRET..." -ForegroundColor Yellow
$secrets.AZURE_CLIENT_SECRET | gh secret set AZURE_CLIENT_SECRET --repo $REPO
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Failed to set AZURE_CLIENT_SECRET" -ForegroundColor Red; exit 1 }
Write-Host "[OK] AZURE_CLIENT_SECRET set" -ForegroundColor Green

Write-Host "[3/4] Setting AZURE_SUBSCRIPTION_ID..." -ForegroundColor Yellow
$secrets.AZURE_SUBSCRIPTION_ID | gh secret set AZURE_SUBSCRIPTION_ID --repo $REPO
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Failed to set AZURE_SUBSCRIPTION_ID" -ForegroundColor Red; exit 1 }
Write-Host "[OK] AZURE_SUBSCRIPTION_ID set" -ForegroundColor Green

Write-Host "[4/4] Setting AZURE_TENANT_ID..." -ForegroundColor Yellow
$secrets.AZURE_TENANT_ID | gh secret set AZURE_TENANT_ID --repo $REPO
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Failed to set AZURE_TENANT_ID" -ForegroundColor Red; exit 1 }
Write-Host "[OK] AZURE_TENANT_ID set" -ForegroundColor Green

# =============================================================================
# Summary
# =============================================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  GitHub Secrets Configured!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Secrets set in repository: $REPO" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [x] AZURE_CLIENT_ID" -ForegroundColor Green
Write-Host "  [x] AZURE_CLIENT_SECRET" -ForegroundColor Green
Write-Host "  [x] AZURE_SUBSCRIPTION_ID" -ForegroundColor Green
Write-Host "  [x] AZURE_TENANT_ID" -ForegroundColor Green
Write-Host ""
Write-Host "View secrets at:" -ForegroundColor Cyan
Write-Host "  https://github.com/$REPO/settings/secrets/actions" -ForegroundColor Gray
Write-Host ""

# List all secrets to verify
Write-Host "[INFO] Current repository secrets:" -ForegroundColor Yellow
gh secret list --repo $REPO
Write-Host ""
