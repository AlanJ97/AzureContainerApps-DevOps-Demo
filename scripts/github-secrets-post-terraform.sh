#!/bin/bash
# =============================================================================
# GitHub Secrets - Post Terraform Setup
# =============================================================================
# Sets environment-specific secrets AFTER Terraform has created resources.
# These values come from Terraform outputs.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Terraform apply completed for the environment
#
# Usage:
#   ./scripts/github-secrets-post-terraform.sh dev
#   ./scripts/github-secrets-post-terraform.sh prod
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================
REPO="AlanJ97/AzureContainerApps-DevOps-Demo"

# =============================================================================
# Parse Arguments
# =============================================================================
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <environment>"
    echo "   Example: $0 dev"
    echo "   Example: $0 prod"
    exit 1
fi

ENV="$1"
TERRAFORM_DIR="terraform/environments/$ENV"

echo ""
echo "=========================================="
echo "  Post-Terraform Secrets: $ENV"
echo "=========================================="
echo ""

# =============================================================================
# Validate
# =============================================================================
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed."
    exit 1
fi

if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "❌ Terraform directory not found: $TERRAFORM_DIR"
    exit 1
fi

# =============================================================================
# Get Terraform Outputs
# =============================================================================
echo "[1/4] Getting Terraform outputs from $TERRAFORM_DIR..."
cd "$TERRAFORM_DIR"

ACR_NAME=$(terraform output -raw acr_name 2>/dev/null || echo "")
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "")
CONTAINER_APP=$(terraform output -raw container_app_name 2>/dev/null || echo "")

if [ -z "$ACR_NAME" ]; then
    echo "❌ Could not get outputs. Has Terraform been applied?"
    echo "   Run: cd $TERRAFORM_DIR && terraform apply"
    exit 1
fi

echo "✅ Terraform outputs:"
echo "   ACR_NAME:            $ACR_NAME"
echo "   RESOURCE_GROUP_NAME: $RESOURCE_GROUP"
echo "   CONTAINER_APP_NAME:  $CONTAINER_APP"
echo ""

# =============================================================================
# Set GitHub Secrets (use --body to avoid BOM issues)
# =============================================================================
echo "[2/4] Setting ACR_NAME..."
gh secret set ACR_NAME --env "$ENV" --repo "$REPO" --body "$ACR_NAME"

echo "[3/4] Setting RESOURCE_GROUP_NAME..."
gh secret set RESOURCE_GROUP_NAME --env "$ENV" --repo "$REPO" --body "$RESOURCE_GROUP"

echo "[4/4] Setting CONTAINER_APP_NAME..."
gh secret set CONTAINER_APP_NAME --env "$ENV" --repo "$REPO" --body "$CONTAINER_APP"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Environment: $ENV"
echo "Secrets set:"
echo "  - ACR_NAME"
echo "  - RESOURCE_GROUP_NAME"
echo "  - CONTAINER_APP_NAME"
echo ""
echo "The App CD workflow can now deploy to $ENV!"
