# Scripts

This folder contains utility scripts for project setup and maintenance.

## ⚠️ Important: Use Bash Scripts

**PowerShell scripts have been replaced with Bash scripts** to avoid UTF-8 BOM (Byte Order Mark) issues that corrupt GitHub secrets when piping values.

## 📋 Available Scripts

| Script | Description | Run Order |
|--------|-------------|-----------|
| `github-setup.sh` | Create and configure GitHub repository | 1 |
| `azure-terraform-backend.ps1` | Create Storage Account for Terraform state | 2 |
| `azure-service-principal.sh` | Create Azure Service Principal for CI/CD | 3 |
| `github-secrets.sh` | Set GitHub Secrets from Service Principal | 4 |
| `github-secrets-post-terraform.sh` | Set additional secrets after Terraform apply | 5 |

---

## 🚀 Setup Order

### Step 1: GitHub Repository (Already Done)
```bash
./scripts/github-setup.sh
```

### Step 2: Terraform Backend Storage
```powershell
# PowerShell is OK here - no secrets piped
.\scripts\azure-terraform-backend.ps1
```
Creates Azure Storage Account for remote Terraform state.

### Step 3: Azure Service Principal
```bash
./scripts/azure-service-principal.sh
```
Creates Service Principal and saves credentials to `scripts/.azure-secrets.json`.

### Step 4: GitHub Secrets
```bash
./scripts/github-secrets.sh
```
Reads `.azure-secrets.json` and sets GitHub repository secrets automatically.

**Key fix:** Uses `gh secret set NAME --body "$VALUE"` instead of piping to avoid BOM issues.

### Step 5: Post-Terraform Secrets (After First Deploy)
```bash
cd terraform/environments/dev
../../../scripts/github-secrets-post-terraform.sh
```
Sets ACR_NAME, RESOURCE_GROUP_NAME, CONTAINER_APP_NAME from Terraform outputs.

---

## 🔐 GitHub Secrets Reference

| Secret | Source | Used By |
|--------|--------|---------|
| `AZURE_CLIENT_ID` | Service Principal | Terraform CD, App CD |
| `AZURE_CLIENT_SECRET` | Service Principal | Terraform CD, App CD |
| `AZURE_SUBSCRIPTION_ID` | Service Principal | Terraform CD, App CD |
| `AZURE_TENANT_ID` | Service Principal | Terraform CD, App CD |
| `ACR_NAME` | Terraform output | App CD |
| `RESOURCE_GROUP_NAME` | Terraform output | App CD |
| `CONTAINER_APP_NAME` | Terraform output | App CD |

---

## 🐛 Known Issue: UTF-8 BOM in PowerShell

PowerShell adds a UTF-8 BOM (Byte Order Mark: `EF BB BF`) when piping strings. This causes secrets to be stored as:
```
<BOM>6a0954ea-f636-4829-a565-cd32cafbbb9e
```
Instead of:
```
6a0954ea-f636-4829-a565-cd32cafbbb9e
```

This results in Azure AD error:
```
AADSTS900023: Specified tenant identifier '***' is neither a valid DNS name, nor a valid external domain.
```

**Solution:** Use `--body` flag instead of piping:
```bash
# ❌ WRONG - adds BOM
$value | gh secret set SECRET_NAME

# ✅ CORRECT - no BOM
gh secret set SECRET_NAME --body "$value"
```

---

## ⚠️ Security Notes

- **Never commit** `scripts/.azure-secrets.json` (already in `.gitignore`)
- Service Principal has **Contributor** role on subscription
- Rotate credentials periodically
- Consider using **OIDC/Federated Credentials** for production
- **Delete `.azure-secrets.json` after setting secrets**
