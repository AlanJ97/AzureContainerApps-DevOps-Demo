#!/bin/bash
# =============================================================================
# GitHub Repository Setup Script
# =============================================================================
# This script creates and configures the GitHub repository for the project.
# Run this script once to initialize the remote repository.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Git repository initialized locally with commits
#
# Usage:
#   chmod +x scripts/github-setup.sh
#   ./scripts/github-setup.sh
# =============================================================================

set -e  # Exit on error

# Configuration
REPO_NAME="AzureContainerApps-DevOps-Demo"
REPO_DESCRIPTION="Full lifecycle DevOps demo on Azure Container Apps - FastAPI, Terraform, GitHub Actions, ACR"
VISIBILITY="public"  # or "private"

echo "🚀 Setting up GitHub repository..."

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first."
    echo "   https://cli.github.com/manual/installation"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI. Please run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated"

# Create the repository
echo "📦 Creating repository: $REPO_NAME"
gh repo create "$REPO_NAME" \
    --"$VISIBILITY" \
    --source=. \
    --remote=origin \
    --push \
    --description "$REPO_DESCRIPTION"

echo "✅ Repository created and code pushed!"

# Add repository topics for discoverability
echo "🏷️  Adding repository topics..."
gh repo edit --add-topic "azure" \
             --add-topic "azure-container-apps" \
             --add-topic "devops" \
             --add-topic "fastapi" \
             --add-topic "terraform" \
             --add-topic "github-actions" \
             --add-topic "docker" \
             --add-topic "python" \
             --add-topic "ci-cd"

echo "✅ Topics added!"

# Enable features
echo "⚙️  Configuring repository settings..."
gh repo edit --enable-issues \
             --enable-projects \
             --enable-wiki=false \
             --delete-branch-on-merge

echo "✅ Repository settings configured!"

# Set default branch protection (optional - uncomment if needed)
# echo "🔒 Setting up branch protection for main..."
# gh api repos/{owner}/{repo}/branches/main/protection \
#     --method PUT \
#     --field required_status_checks='{"strict":true,"contexts":["test","lint"]}' \
#     --field enforce_admins=false \
#     --field required_pull_request_reviews='{"required_approving_review_count":1}'

# Display repository info
echo ""
echo "=========================================="
echo "🎉 Repository setup complete!"
echo "=========================================="
gh repo view --web
