# Scripts

Utility scripts for project setup. Run in order.

## ⚠️ Important: Use Bash + `--body` Flag

PowerShell pipes add UTF-8 BOM that corrupts secrets. All scripts use:
```bash
gh secret set NAME --body "$VALUE"  # ✅ Correct
```

---

## 📋 Setup Order

### Step 1: Create GitHub Repository (one-time)
```bash
# Create repo (already done)
gh repo create AzureContainerApps-DevOps-Demo --public --source=. --push
```

### Step 2: Create Terraform State Storage (one-time)
```powershell
.\scripts\azure-terraform-backend.ps1
```
Creates:
- Resource Group: `rg-terraform-state`
- Storage Account: `stterraformacademo`
- Containers: `tfstate-dev`, `tfstate-prod`

### Step 3: Register Azure Provider (one-time)
```bash
az provider register --namespace Microsoft.App
```

### Step 4: Create Service Principal
```bash
./scripts/azure-service-principal.sh
```
Creates SP with roles:
- **Contributor** - Create/manage resources
- **User Access Administrator** - Assign roles to managed identities

Output: `scripts/.azure-secrets.json`

### Step 5: Set GitHub Auth Secrets
```bash
./scripts/github-secrets.sh
```
Sets secrets for **both** `dev` and `prod` environments:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

### Step 6: Deploy Infrastructure (via GitHub Actions)
```bash
# Push to dev → triggers Terraform CD
git push origin dev

# Or manually trigger
gh workflow run "Terraform CD" --ref dev -f environment=dev
```

### Step 7: Set Post-Terraform Secrets
```bash
# For dev environment
./scripts/github-secrets-post-terraform.sh dev

# For prod environment (after prod infra deployed)
./scripts/github-secrets-post-terraform.sh prod
```
Sets environment-specific secrets:
- `ACR_NAME`
- `RESOURCE_GROUP_NAME`
- `CONTAINER_APP_NAME`

### Step 8: Deploy Application (via GitHub Actions)
```bash
# Push app changes → triggers App CD
git push origin dev

# Or manually trigger
gh workflow run "App CD" --ref dev -f environment=dev
```

---

## 📁 Files

| File | Purpose |
|------|---------|
| `azure-terraform-backend.ps1` | Create Storage Account for TF state |
| `azure-service-principal.sh` | Create SP with required roles |
| `github-secrets.sh` | Set Azure auth secrets (both envs) |
| `github-secrets-post-terraform.sh` | Set resource secrets per environment |
| `.azure-secrets.json` | SP credentials (DO NOT COMMIT) |

---

## 🔐 Secrets Reference

### Per Environment (dev, prod)

| Secret | Source | Purpose |
|--------|--------|---------|
| `AZURE_CLIENT_ID` | Service Principal | Azure authentication |
| `AZURE_CLIENT_SECRET` | Service Principal | Azure authentication |
| `AZURE_SUBSCRIPTION_ID` | Azure account | Azure authentication |
| `AZURE_TENANT_ID` | Azure account | Azure authentication |
| `ACR_NAME` | Terraform output | Container registry name |
| `RESOURCE_GROUP_NAME` | Terraform output | Resource group for deployment |
| `CONTAINER_APP_NAME` | Terraform output | Container app to update |

---

## 🐛 Troubleshooting

### AADSTS900023: Invalid tenant identifier
**Cause:** UTF-8 BOM in secret value
**Solution:** Use `--body` flag, not pipe:
```bash
# ❌ Wrong
echo "$value" | gh secret set NAME

# ✅ Correct  
gh secret set NAME --body "$value"
```

### MissingSubscriptionRegistration: Microsoft.App
**Cause:** Provider not registered
**Solution:**
```bash
az provider register --namespace Microsoft.App
```

### AuthorizationFailed: roleAssignments/write
**Cause:** SP missing User Access Administrator role
**Solution:**
```bash
az role assignment create \
  --assignee <SP_OBJECT_ID> \
  --role "User Access Administrator" \
  --scope /subscriptions/<SUB_ID>
```

### Job output is empty (secret masking)
**Cause:** GitHub masks outputs containing secrets
**Solution:** Construct values in consuming job:
```yaml
# Instead of using needs.job.outputs.value
IMAGE="${{ secrets.ACR_NAME }}.azurecr.io/app:tag"
```
