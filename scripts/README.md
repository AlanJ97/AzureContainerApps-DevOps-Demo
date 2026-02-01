# Scripts

This folder contains utility scripts for project setup and maintenance.

## 📋 Available Scripts

| Script | Description | Run Order |
|--------|-------------|-----------|
| `github-setup.ps1` | Create and configure GitHub repository | 1 |
| `azure-terraform-backend.ps1` | Create Storage Account for Terraform state | 2 |
| `azure-service-principal.ps1` | Create Azure Service Principal for CI/CD | 3 |
| `github-secrets.ps1` | Set GitHub Secrets from Service Principal | 4 |
| `github-secrets-post-terraform.ps1` | Set additional secrets after Terraform apply | 5 |

---

## 🚀 Setup Order

### Step 1: GitHub Repository (Already Done)
```powershell
.\scripts\github-setup.ps1
```

### Step 2: Terraform Backend Storage
```powershell
.\scripts\azure-terraform-backend.ps1
```
Creates Azure Storage Account for remote Terraform state.

### Step 3: Azure Service Principal
```powershell
.\scripts\azure-service-principal.ps1
```
Creates Service Principal and saves credentials to `scripts/.azure-secrets.json`.

### Step 4: GitHub Secrets
```powershell
.\scripts\github-secrets.ps1
```
Reads `.azure-secrets.json` and sets GitHub repository secrets automatically.

### Step 5: Post-Terraform Secrets (After First Deploy)
```powershell
cd terraform/environments/dev
..\..\..\scripts\github-secrets-post-terraform.ps1
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

## ⚠️ Security Notes

- **Never commit** `scripts/.azure-secrets.json` (already in `.gitignore`)
- Service Principal has **Contributor** role on subscription
- Rotate credentials periodically
- Consider using **OIDC/Federated Credentials** for production
