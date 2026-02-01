#!/bin/bash
# =============================================================================
# Azure Service Principal Setup Script (Bash)
# =============================================================================
# This script creates a Service Principal for GitHub Actions to authenticate
# with Azure. The credentials are saved to a JSON file for the secrets script.
#
# Prerequisites:
#   - Azure CLI (az) installed and authenticated
#   - Sufficient permissions to create Service Principals (Azure AD)
#
# Usage:
#   ./scripts/azure-service-principal.sh
# =============================================================================

set -e

# =============================================================================
# Configuration - MODIFY THESE VALUES
# =============================================================================
SP_NAME="sp-github-aca-demo"
ROLE="Contributor"  # Or "Owner" if you need to assign roles

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
    echo "[ERROR] Azure CLI (az) is not installed. Please install it first."
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo "[ERROR] Not logged in to Azure. Please run: az login"
    exit 1
fi

SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
TENANT_ID=$(az account show --query "tenantId" -o tsv)
ACCOUNT_NAME=$(az account show --query "name" -o tsv)
USER_NAME=$(az account show --query "user.name" -o tsv)

echo "[OK] Logged in as: $USER_NAME"
echo "[OK] Subscription: $ACCOUNT_NAME"
echo "[OK] Subscription ID: $SUBSCRIPTION_ID"
echo ""

# Create Service Principal
echo "[1/2] Creating Service Principal: $SP_NAME"
echo "      Role: $ROLE"
echo "      Scope: /subscriptions/$SUBSCRIPTION_ID"
echo ""

SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role "$ROLE" \
    --scopes "/subscriptions/$SUBSCRIPTION_ID" \
    --output json)

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to create Service Principal"
    exit 1
fi

# Parse output
CLIENT_ID=$(echo "$SP_OUTPUT" | grep -o '"appId": "[^"]*"' | cut -d'"' -f4)
CLIENT_SECRET=$(echo "$SP_OUTPUT" | grep -o '"password": "[^"]*"' | cut -d'"' -f4)
SP_TENANT=$(echo "$SP_OUTPUT" | grep -o '"tenant": "[^"]*"' | cut -d'"' -f4)

echo "[OK] Service Principal created!"
echo ""

# =============================================================================
# Output - GitHub Secrets
# =============================================================================
echo "=========================================="
echo "  GitHub Secrets (Add these manually)"
echo "=========================================="
echo ""
echo "Go to: GitHub Repo > Settings > Secrets and variables > Actions"
echo "Add the following secrets:"
echo ""
echo "┌──────────────────────────────────────────────────────────────┐"
echo "│ Secret Name              │ Value                             │"
echo "├──────────────────────────────────────────────────────────────┤"
echo "│ AZURE_CLIENT_ID          │ $CLIENT_ID"
echo "│ AZURE_CLIENT_SECRET      │ $CLIENT_SECRET"
echo "│ AZURE_SUBSCRIPTION_ID    │ $SUBSCRIPTION_ID"
echo "│ AZURE_TENANT_ID          │ $SP_TENANT"
echo "└──────────────────────────────────────────────────────────────┘"
echo ""

# =============================================================================
# Save to file for the secrets script
# =============================================================================
SECRETS_FILE="scripts/.azure-secrets.json"

cat > "$SECRETS_FILE" << EOF
{
  "AZURE_CLIENT_ID": "$CLIENT_ID",
  "AZURE_CLIENT_SECRET": "$CLIENT_SECRET",
  "AZURE_SUBSCRIPTION_ID": "$SUBSCRIPTION_ID",
  "AZURE_TENANT_ID": "$SP_TENANT"
}
EOF

echo "[2/2] Credentials saved to: $SECRETS_FILE"
echo ""
echo "=========================================="
echo "  IMPORTANT: Security Notice"
echo "=========================================="
echo ""
echo "1. The file '$SECRETS_FILE' contains sensitive credentials"
echo "2. It is already in .gitignore - NEVER commit it"
echo "3. Run './scripts/github-secrets.sh' to set GitHub secrets"
echo "4. Delete the file after setting secrets: rm $SECRETS_FILE"
echo ""
echo "Next step:"
echo "  ./scripts/github-secrets.sh"
echo ""
