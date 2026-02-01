#!/bin/bash
# =============================================================================
# GitHub Secrets - Post Terraform Setup (Bash)
# =============================================================================
# This script sets additional GitHub secrets AFTER Terraform has been applied.
# These secrets come from Terraform outputs (ACR name, Resource Group, etc.)
#
# IMPORTANT: Uses --body flag to avoid UTF-8 BOM issues!
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Terraform has been applied (terraform apply completed)
#
# Usage:
#   cd terraform/environments/dev
#   ../../../scripts/github-secrets-post-terraform.sh
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================
REPO="AlanJ97/AzureContainerApps-DevOps-Demo"  # Change to your repo

# =============================================================================
# Script Start
# =============================================================================
echo ""
echo "=========================================="
echo "  Post-Terraform GitHub Secrets Setup"
echo "=========================================="
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "[ERROR] GitHub CLI (gh) is not installed."
    exit 1
fi

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "[ERROR] Terraform is not installed."
    exit 1
fi

# Check if we're in a terraform directory
if [ ! -f "terraform.tfstate" ] && [ ! -d ".terraform" ]; then
    echo "[WARNING] Not in a Terraform directory. Make sure Terraform has been applied."
    echo "          Run this from: terraform/environments/dev or terraform/environments/prod"
fi

# =============================================================================
# Get Terraform Outputs
# =============================================================================
echo "[1/4] Getting Terraform outputs..."

ACR_NAME=$(terraform output -raw acr_name 2>/dev/null || echo "")
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "")
CONTAINER_APP=$(terraform output -raw container_app_name 2>/dev/null || echo "")

if [ -z "$ACR_NAME" ]; then
    echo "[ERROR] Could not get acr_name from Terraform outputs"
    echo "        Make sure Terraform has been applied successfully"
    exit 1
fi

echo "[OK] Terraform outputs retrieved:"
echo "     ACR_NAME:            $ACR_NAME"
echo "     RESOURCE_GROUP_NAME: $RESOURCE_GROUP"
echo "     CONTAINER_APP_NAME:  $CONTAINER_APP"
echo ""

# =============================================================================
# Set GitHub Secrets
# IMPORTANT: Use --body flag to avoid UTF-8 BOM issues!
# =============================================================================
echo "[2/4] Setting ACR_NAME..."
gh secret set ACR_NAME --body "$ACR_NAME" --repo "$REPO"
echo "[OK] ACR_NAME set"

echo "[3/4] Setting RESOURCE_GROUP_NAME..."
gh secret set RESOURCE_GROUP_NAME --body "$RESOURCE_GROUP" --repo "$REPO"
echo "[OK] RESOURCE_GROUP_NAME set"

echo "[4/4] Setting CONTAINER_APP_NAME..."
gh secret set CONTAINER_APP_NAME --body "$CONTAINER_APP" --repo "$REPO"
echo "[OK] CONTAINER_APP_NAME set"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=========================================="
echo "  Post-Terraform Secrets Configured!"
echo "=========================================="
echo ""
echo "Secrets set in repository: $REPO"
echo ""
echo "  [x] ACR_NAME:            $ACR_NAME"
echo "  [x] RESOURCE_GROUP_NAME: $RESOURCE_GROUP"
echo "  [x] CONTAINER_APP_NAME:  $CONTAINER_APP"
echo ""
echo "View secrets at:"
echo "  https://github.com/$REPO/settings/secrets/actions"
echo ""
