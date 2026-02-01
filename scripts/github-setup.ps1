# =============================================================================
# GitHub Repository Setup Script (PowerShell)
# =============================================================================
# This script creates and configures the GitHub repository for the project.
# Run this script once to initialize the remote repository.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Git repository initialized locally with commits
#
# Usage:
#   .\scripts\github-setup.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

# Configuration
$REPO_NAME = "AzureContainerApps-DevOps-Demo"
$REPO_DESCRIPTION = "Full lifecycle DevOps demo on Azure Container Apps - FastAPI, Terraform, GitHub Actions, ACR"
$VISIBILITY = "public"  # or "private"

Write-Host "🚀 Setting up GitHub repository..." -ForegroundColor Cyan

# Check if gh is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI (gh) is not installed. Please install it first." -ForegroundColor Red
    Write-Host "   https://cli.github.com/manual/installation"
    exit 1
}

# Check if authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not authenticated with GitHub CLI. Please run: gh auth login" -ForegroundColor Red
    exit 1
}

Write-Host "✅ GitHub CLI is installed and authenticated" -ForegroundColor Green

# Create the repository
Write-Host "📦 Creating repository: $REPO_NAME" -ForegroundColor Yellow
gh repo create $REPO_NAME `
    --$VISIBILITY `
    --source=. `
    --remote=origin `
    --push `
    --description $REPO_DESCRIPTION

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create repository" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Repository created and code pushed!" -ForegroundColor Green

# Add repository topics for discoverability
Write-Host "🏷️  Adding repository topics..." -ForegroundColor Yellow
gh repo edit `
    --add-topic "azure" `
    --add-topic "azure-container-apps" `
    --add-topic "devops" `
    --add-topic "fastapi" `
    --add-topic "terraform" `
    --add-topic "github-actions" `
    --add-topic "docker" `
    --add-topic "python" `
    --add-topic "ci-cd"

Write-Host "✅ Topics added!" -ForegroundColor Green

# Enable features
Write-Host "⚙️  Configuring repository settings..." -ForegroundColor Yellow
gh repo edit `
    --enable-issues `
    --enable-projects `
    --enable-wiki=false `
    --delete-branch-on-merge

Write-Host "✅ Repository settings configured!" -ForegroundColor Green

# Display repository info
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🎉 Repository setup complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
gh repo view --web
