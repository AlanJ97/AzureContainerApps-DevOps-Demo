# CI/CD Workflows

Automated pipelines for continuous integration and deployment using GitHub Actions.

## 🎯 Strategy

**GitHub Flow** with environment-based deployment:
- **Pull Requests** → Run CI checks (lint, test, security scan)
- **Push to `dev`** → Deploy to dev environment
- **Push to `main`** → Deploy to prod environment

## 📋 Workflows

| Workflow | File | Trigger | Purpose |
|----------|------|---------|---------|
| **App CI** | `app-ci.yaml` | PR to dev/main | Lint, test, security scan Python code |
| **App CD** | `app-cd.yaml` | Push to dev/main | Build Docker image, push to ACR, deploy to ACA |
| **Terraform CI** | `terraform-ci.yaml` | PR to dev/main | Validate, format check, plan Terraform |
| **Terraform CD** | `terraform-cd.yaml` | Push to dev/main | Apply infrastructure changes |
| **CodeQL** | `codeql.yml` | Push to main, PR, schedule | Security scanning for vulnerabilities |

---

## 🔄 App CI (`app-ci.yaml`)

**Purpose**: Validate application code quality and security

**Triggers**:
- Pull requests modifying: `app/**`, `tests/**`, `requirements*.txt`, `Dockerfile`
- Manual dispatch

**Jobs**:
1. **Lint** - flake8 code style checking
2. **Test** - pytest with coverage report
3. **Security Scan** - bandit for Python vulnerabilities

**Path Filters**: Only runs when app-related files change

---

## 🚀 App CD (`app-cd.yaml`)

**Purpose**: Build and deploy containerized application

**Triggers**:
- Push to `dev` or `main` branches
- Changes to: `app/**`, `requirements*.txt`, `Dockerfile`
- Manual dispatch with environment selection

**Workflow**:

```
┌─────────────────┐
│  Setup          │  Determine environment (dev/main)
│  - Set env vars │  Generate image tag (SHA + timestamp)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Build & Push   │  Build Docker image
│  - Login to ACR │  Tag with commit SHA
│  - Build image  │  Push to Azure Container Registry
│  - Scan (Trivy) │  Security scan for CVEs
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Deploy         │  Update Container App
│  - Azure login  │  Deploy new image
│  - Update ACA   │  Health check validation
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Health Check   │  Verify deployment
│  - Test /health │  Ensure app is responsive
└─────────────────┘
```

**Environment Variables**:
- `dev` branch → `ENVIRONMENT=dev`
- `main` branch → `ENVIRONMENT=prod`

**Image Tag Format**: `{environment}-{short-sha}-{timestamp}`

**Secrets Required** (per environment):
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`
- `ACR_NAME`
- `RESOURCE_GROUP_NAME`
- `CONTAINER_APP_NAME`

---

## 🏗️ Terraform CI (`terraform-ci.yaml`)

**Purpose**: Validate infrastructure as code

**Triggers**:
- Pull requests modifying: `terraform/**`
- Manual dispatch

**Jobs**:
1. **Format Check** - `terraform fmt -check`
2. **Validate** - `terraform validate`
3. **Security Scan** - checkov for IaC misconfigurations
4. **Plan** - Generate and display execution plan

**Environments Checked**: Both dev and prod

**Path Filters**: Only runs when Terraform files change

---

## ⚙️ Terraform CD (`terraform-cd.yaml`)

**Purpose**: Apply infrastructure changes

**Triggers**:
- Push to `dev` or `main` branches
- Changes to: `terraform/**`
- Manual dispatch with environment selection

**Workflow**:

```
┌──────────────────┐
│  Terraform Init  │  Initialize backend
│  - Azure login   │  Configure state storage
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Terraform Plan  │  Generate execution plan
│  - Review changes│  Show what will be created/modified
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Terraform Apply │  Apply changes
│  - Auto-approve  │  Create/update resources
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Output Values   │  Display resource IDs
│  - ACR name      │  For verification
│  - App URL       │
└──────────────────┘
```

**State Storage**: Azure Blob Storage (configured in backend)

**Secrets Required**:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

---

## 🔒 CodeQL (`codeql.yml`)

**Purpose**: Automated security vulnerability scanning

**Triggers**:
- Push to `main` branch
- Pull requests to `main`
- Weekly schedule (Monday 6 AM UTC)

**Languages Scanned**: Python

**Features**:
- Identifies security vulnerabilities
- Detects coding errors
- Provides remediation suggestions
- Results visible in Security tab

---

## 🔐 Required Secrets

### Repository Secrets (Global)
Set these at the repository level for all workflows:

```bash
# Azure Service Principal
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
```

### Environment Secrets
Set these per environment (`dev`, `prod`):

```bash
# Container Registry
ACR_NAME                  # e.g., "acracadevopsdemodev"

# Resource Names
RESOURCE_GROUP_NAME       # e.g., "rg-aca-devops-demo-dev"
CONTAINER_APP_NAME        # e.g., "ca-aca-devops-demo-dev"
```

**Setup**: See [scripts/README.md](../../scripts/README.md) for configuration instructions.

---

## 🎛️ Manual Triggers

All workflows support manual execution:

```bash
# Deploy app to dev
gh workflow run "App CD" -f environment=dev

# Deploy app to prod
gh workflow run "App CD" -f environment=prod

# Apply Terraform to dev
gh workflow run "Terraform CD" -f environment=dev

# Run CI checks
gh workflow run "App CI"
gh workflow run "Terraform CI"
```

---

## 🔍 Path Filtering

Workflows use path filters to run only when relevant files change:

**App Workflows**:
- `app/**`
- `tests/**`
- `requirements.txt`
- `requirements-dev.txt`
- `Dockerfile`

**Terraform Workflows**:
- `terraform/**`

This prevents unnecessary workflow runs and saves compute time.

---

## 🐛 Troubleshooting

**Workflow not triggering**
- Check path filters match changed files
- Verify branch protection rules allow workflows
- Ensure secrets are configured for the environment

**Azure login fails**
- Verify Service Principal credentials are valid
- Check SP has required permissions (Contributor + User Access Administrator)
- Ensure tenant ID and subscription ID are correct

**Deployment fails**
- Check resource group exists
- Verify ACR name matches actual registry
- Ensure Container App name is correct
- Review Azure Activity Log for detailed errors

**Image pull fails**
- Verify managed identity has AcrPull role
- Check ACR is accessible from Container App
- Ensure image tag exists in registry

---

## 📊 Workflow Status

View workflow runs:
- GitHub Actions tab in repository
- Commit page shows check status
- PR page displays CI results

**Badges** in main README show current status for each workflow.

---

## 🔄 Deployment Flow

Complete deployment process:

1. **Feature Development**
   ```bash
   git checkout -b feature/new-feature
   # Make changes
   git push origin feature/new-feature
   ```

2. **Pull Request**
   - Creates PR to `dev`
   - Triggers App CI + Terraform CI
   - Review checks and approve

3. **Merge to Dev**
   - Merge PR to `dev`
   - Triggers App CD + Terraform CD for dev environment
   - Automatic deployment to dev

4. **Promote to Production**
   - Create PR from `dev` to `main`
   - CI checks run again
   - Merge triggers deployment to prod

**Result**: Automated, tested deployments with environment promotion.

---

*See also: [Project Documentation](../../README.md) | [Scripts Setup](../../scripts/README.md)*
