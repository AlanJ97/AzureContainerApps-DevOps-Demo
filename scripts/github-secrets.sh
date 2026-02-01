#!/bin/bash
# =============================================================================
# GitHub Secrets Setup Script (Bash)
# =============================================================================
# This script sets GitHub repository secrets using the GitHub CLI.
# Run this AFTER creating the Service Principal.
#
# IMPORTANT: Uses --body flag to avoid UTF-8 BOM issues that occur with piping
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Service Principal created (run azure-service-principal.sh first)
#   - Secrets file exists: scripts/.azure-secrets.json
#
# Usage:
#   ./scripts/github-secrets.sh
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================
SECRETS_FILE="scripts/.azure-secrets.json"
REPO="AlanJ97/AzureContainerApps-DevOps-Demo"  # Change to your repo

# =============================================================================
# Script Start
# =============================================================================
echo ""
echo "=========================================="
echo "  GitHub Secrets Setup"
echo "=========================================="
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "[ERROR] GitHub CLI (gh) is not installed. Please install it first."
    echo "   https://cli.github.com/manual/installation"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "[ERROR] Not authenticated with GitHub CLI. Please run: gh auth login"
    exit 1
fi
echo "[OK] GitHub CLI is authenticated"

# Check if secrets file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "[ERROR] Secrets file not found: $SECRETS_FILE"
    echo "        Run azure-service-principal.sh first"
    exit 1
fi

# Load secrets using proper JSON parsing
# Using grep/sed for portability (no jq dependency)
AZURE_CLIENT_ID=$(grep -o '"AZURE_CLIENT_ID": "[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)
AZURE_CLIENT_SECRET=$(grep -o '"AZURE_CLIENT_SECRET": "[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)
AZURE_SUBSCRIPTION_ID=$(grep -o '"AZURE_SUBSCRIPTION_ID": "[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)
AZURE_TENANT_ID=$(grep -o '"AZURE_TENANT_ID": "[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)

echo "[OK] Loaded secrets from: $SECRETS_FILE"
echo ""

# Verify secrets were loaded
if [ -z "$AZURE_CLIENT_ID" ] || [ -z "$AZURE_TENANT_ID" ]; then
    echo "[ERROR] Failed to parse secrets from file"
    exit 1
fi

# =============================================================================
# Set GitHub Secrets
# IMPORTANT: Use --body flag to avoid UTF-8 BOM issues!
# =============================================================================
echo "[1/4] Setting AZURE_CLIENT_ID..."
gh secret set AZURE_CLIENT_ID --body "$AZURE_CLIENT_ID" --repo "$REPO"
echo "[OK] AZURE_CLIENT_ID set"

echo "[2/4] Setting AZURE_CLIENT_SECRET..."
gh secret set AZURE_CLIENT_SECRET --body "$AZURE_CLIENT_SECRET" --repo "$REPO"
echo "[OK] AZURE_CLIENT_SECRET set"

echo "[3/4] Setting AZURE_SUBSCRIPTION_ID..."
gh secret set AZURE_SUBSCRIPTION_ID --body "$AZURE_SUBSCRIPTION_ID" --repo "$REPO"
echo "[OK] AZURE_SUBSCRIPTION_ID set"

echo "[4/4] Setting AZURE_TENANT_ID..."
gh secret set AZURE_TENANT_ID --body "$AZURE_TENANT_ID" --repo "$REPO"
echo "[OK] AZURE_TENANT_ID set"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=========================================="
echo "  GitHub Secrets Configured!"
echo "=========================================="
echo ""
echo "Secrets set in repository: $REPO"
echo ""
echo "  [x] AZURE_CLIENT_ID"
echo "  [x] AZURE_CLIENT_SECRET"
echo "  [x] AZURE_SUBSCRIPTION_ID"
echo "  [x] AZURE_TENANT_ID"
echo ""
echo "View secrets at:"
echo "  https://github.com/$REPO/settings/secrets/actions"
echo ""
echo "=========================================="
echo "  CLEANUP: Delete the secrets file!"
echo "=========================================="
echo ""
echo "  rm $SECRETS_FILE"
echo ""
