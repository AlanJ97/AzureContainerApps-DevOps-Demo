#!/bin/bash
# =============================================================================
# GitHub Secrets Setup Script (Environment-based)
# =============================================================================
# Sets GitHub environment secrets for Azure authentication.
# Uses --body flag to avoid UTF-8 BOM issues.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Service Principal created (scripts/.azure-secrets.json exists)
#   - GitHub environments created (dev, prod)
#
# Usage:
#   ./scripts/github-secrets.sh
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================
REPO="AlanJ97/AzureContainerApps-DevOps-Demo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="$SCRIPT_DIR/.azure-secrets.json"
ENVIRONMENTS=("dev" "prod")

# =============================================================================
# Script Start
# =============================================================================
echo ""
echo "=========================================="
echo "  GitHub Environment Secrets Setup"
echo "=========================================="
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI. Run: gh auth login"
    exit 1
fi
echo "✅ GitHub CLI authenticated"

# Check secrets file
if [ ! -f "$SECRETS_FILE" ]; then
    echo "❌ Secrets file not found: $SECRETS_FILE"
    echo "   Run ./scripts/azure-service-principal.sh first"
    exit 1
fi

# Parse secrets (using grep for portability)
AZURE_CLIENT_ID=$(grep -o '"AZURE_CLIENT_ID": "[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)
AZURE_CLIENT_SECRET=$(grep -o '"AZURE_CLIENT_SECRET": "[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)
AZURE_SUBSCRIPTION_ID=$(grep -o '"AZURE_SUBSCRIPTION_ID": "[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)
AZURE_TENANT_ID=$(grep -o '"AZURE_TENANT_ID": "[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)

echo "✅ Loaded secrets from: $SECRETS_FILE"
echo ""

# =============================================================================
# Create Environments and Set Secrets
# =============================================================================
for ENV in "${ENVIRONMENTS[@]}"; do
    echo "----------------------------------------"
    echo "Setting up environment: $ENV"
    echo "----------------------------------------"
    
    # Create environment (if not exists)
    echo "[1/5] Creating GitHub environment: $ENV"
    gh api --method PUT "repos/$REPO/environments/$ENV" --silent || true
    echo "✅ Environment ready"
    
    # Set secrets using --body flag (avoids BOM issues)
    echo "[2/5] Setting AZURE_CLIENT_ID..."
    gh secret set AZURE_CLIENT_ID --env "$ENV" --repo "$REPO" --body "$AZURE_CLIENT_ID"
    
    echo "[3/5] Setting AZURE_CLIENT_SECRET..."
    gh secret set AZURE_CLIENT_SECRET --env "$ENV" --repo "$REPO" --body "$AZURE_CLIENT_SECRET"
    
    echo "[4/5] Setting AZURE_SUBSCRIPTION_ID..."
    gh secret set AZURE_SUBSCRIPTION_ID --env "$ENV" --repo "$REPO" --body "$AZURE_SUBSCRIPTION_ID"
    
    echo "[5/5] Setting AZURE_TENANT_ID..."
    gh secret set AZURE_TENANT_ID --env "$ENV" --repo "$REPO" --body "$AZURE_TENANT_ID"
    
    echo "✅ Environment $ENV configured"
    echo ""
done

# =============================================================================
# Summary
# =============================================================================
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Secrets set for environments: ${ENVIRONMENTS[*]}"
echo ""
echo "Next steps:"
echo "  1. Run Terraform CD to create infrastructure"
echo "  2. Run ./scripts/github-secrets-post-terraform.sh dev"
echo "  3. Run ./scripts/github-secrets-post-terraform.sh prod"
