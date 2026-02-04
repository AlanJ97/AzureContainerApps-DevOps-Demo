# Setup Scripts

Utility scripts for Azure and GitHub configuration. Execute in order.

> **⚠️ Important**: Use Bash and the `--body` flag with `gh secret set` to avoid UTF-8 BOM corruption that breaks Azure authentication.

---

## 📋 Setup Workflow

### 1. Create Terraform State Storage
```powershell
.\scripts\azure-terraform-backend.ps1
```
Creates: `rg-terraform-state`, `stterraformacademo`, containers for dev/prod

### 2. Register Azure Provider
```bash
az provider register --namespace Microsoft.App
```

### 3. Create Service Principal
```bash
./scripts/azure-service-principal.sh
```
Creates SP with **Contributor** + **User Access Administrator** roles

### 4. Set GitHub Secrets (Pre-Terraform)
```bash
./scripts/github-secrets.sh
```
Sets Azure auth secrets for both `dev` and `prod` environments

### 5. Deploy Infrastructure
```bash
gh workflow run "Terraform CD" -f environment=dev
```
Or push to `dev` branch to trigger automatically

### 6. Set GitHub Secrets (Post-Terraform)
```bash
./scripts/github-secrets-post-terraform.sh dev
./scripts/github-secrets-post-terraform.sh prod
```
Sets ACR and resource names per environment

### 7. Deploy Application
```bash
gh workflow run "App CD" -f environment=dev
```
Or push app changes to `dev` branch

---

## 📁 Script Files

| File | Purpose |
|------|---------|  
| `azure-terraform-backend.ps1` | Creates Azure Storage for Terraform state |
| `azure-service-principal.sh` | Creates Service Principal with required roles |
| `github-secrets.sh` | Sets Azure authentication secrets |
| `github-secrets-post-terraform.sh` | Sets resource-specific secrets after deployment |
| `.azure-secrets.json` | SP credentials (⚠️ gitignored, do not commit) |

---

## 🔐 GitHub Secrets

**Set by `github-secrets.sh`** (both environments):
- `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`

**Set by `github-secrets-post-terraform.sh`** (per environment):
- `ACR_NAME`, `RESOURCE_GROUP_NAME`, `CONTAINER_APP_NAME`

---

## 🐛 Common Issues

**AADSTS900023: Invalid tenant identifier**
- Cause: UTF-8 BOM in secret
- Fix: Use `gh secret set NAME --body "$value"` (not pipe)

**MissingSubscriptionRegistration: Microsoft.App**
- Fix: `az provider register --namespace Microsoft.App`

**AuthorizationFailed: roleAssignments/write**  
- Cause: SP missing User Access Administrator role
- Fix: Add role to SP:
  ```bash
  az role assignment create \
    --assignee <SP_OBJECT_ID> \
    --role "User Access Administrator" \
    --scope /subscriptions/<SUB_ID>
  ```

**GitHub job output is empty**
- Cause: GitHub masks outputs containing secrets
- Fix: Construct values in consuming job instead of passing outputs
