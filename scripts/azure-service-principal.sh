#!/bin/bash
# =============================================================================
# Azure Service Principal Setup Script
# =============================================================================
# Creates a Service Principal for GitHub Actions with the required roles:
# - Contributor: To create/manage Azure resources
# - User Access Administrator: To assign roles (e.g., AcrPull to managed identity)
#
# Prerequisites:
#   - Azure CLI installed and authenticated (az login)
#   - Sufficient permissions to create Service Principals
#
# Usage:
#   ./scripts/azure-service-principal.sh
#
# Output:
#   - scripts/.azure-secrets.json (contains credentials)
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================
SP_NAME="sp-github-aca-demo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="$SCRIPT_DIR/.azure-secrets.json"

# =============================================================================
# Script Start
# =============================================================================
echo ""
echo "=========================================="
echo "  Azure Service Principal Setup"
echo "=========================================="
echo ""

# Check if az is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI (az) is not installed."
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure. Run: az login"
    exit 1
fi

SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
TENANT_ID=$(az account show --query "tenantId" -o tsv)
ACCOUNT_NAME=$(az account show --query "name" -o tsv)

echo "✅ Logged in to: $ACCOUNT_NAME"
echo "   Subscription: $SUBSCRIPTION_ID"
echo ""

# =============================================================================
# Step 1: Create Service Principal with Contributor role
# =============================================================================
echo "[1/3] Creating Service Principal: $SP_NAME"
echo "      Role: Contributor"
echo "      Scope: /subscriptions/$SUBSCRIPTION_ID"
echo ""

SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role "Contributor" \
    --scopes "/subscriptions/$SUBSCRIPTION_ID" \
    --output json)

CLIENT_ID=$(echo "$SP_OUTPUT" | grep -o '"appId": "[^"]*"' | cut -d'"' -f4)
CLIENT_SECRET=$(echo "$SP_OUTPUT" | grep -o '"password": "[^"]*"' | cut -d'"' -f4)

echo "✅ Service Principal created"
echo "   Client ID: $CLIENT_ID"
echo ""

# =============================================================================
# Step 2: Add User Access Administrator role (required for role assignments)
# =============================================================================
echo "[2/3] Adding 'User Access Administrator' role..."
echo "      (Required for Terraform to create role assignments)"
echo ""

# Get SP Object ID
SP_OBJECT_ID=$(az ad sp show --id "$CLIENT_ID" --query "id" -o tsv)

az role assignment create \
    --assignee "$SP_OBJECT_ID" \
    --role "User Access Administrator" \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --output none

echo "✅ User Access Administrator role assigned"
echo ""

# =============================================================================
# Step 3: Save credentials to file
# =============================================================================
echo "[3/3] Saving credentials to: $SECRETS_FILE"

cat > "$SECRETS_FILE" << EOF
{
    "_note": "DO NOT COMMIT THIS FILE! Add to .gitignore",
    "_created": "$(date '+%Y-%m-%d %H:%M:%S')",
    "_service_principal_name": "$SP_NAME",
    "AZURE_CLIENT_ID": "$CLIENT_ID",
    "AZURE_CLIENT_SECRET": "$CLIENT_SECRET",
    "AZURE_SUBSCRIPTION_ID": "$SUBSCRIPTION_ID",
    "AZURE_TENANT_ID": "$TENANT_ID"
}
EOF

echo "✅ Credentials saved"
echo ""

# =============================================================================
# Summary
# =============================================================================
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Service Principal: $SP_NAME"
echo "Client ID:         $CLIENT_ID"
echo "Roles:             Contributor, User Access Administrator"
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/github-secrets.sh"
echo ""
echo "⚠️  Keep $SECRETS_FILE secure and never commit it!"
