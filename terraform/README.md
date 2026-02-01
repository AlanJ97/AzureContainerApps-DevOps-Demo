# Terraform Infrastructure for Azure Container Apps

This directory contains Terraform configurations for deploying the Azure Container Apps infrastructure.

## 📁 Structure

```
terraform/
├── modules/
│   └── aca-stack/           # Reusable ACA module
│       ├── main.tf          # Resource definitions
│       ├── variables.tf     # Input variables
│       ├── outputs.tf       # Output values
│       └── versions.tf      # Provider requirements
├── environments/
│   ├── dev/                 # Development environment
│   │   ├── providers.tf     # Provider & backend config
│   │   ├── main.tf          # Module instantiation
│   │   ├── variables.tf     # Input variables
│   │   ├── outputs.tf       # Output values
│   │   └── terraform.tfvars # Variable values
│   └── prod/                # Production environment
│       └── ...              # Same structure as dev
└── README.md
```

## 🏗️ Module: aca-stack

The `aca-stack` module creates a complete Azure Container Apps infrastructure:

| Resource | Description |
|----------|-------------|
| Resource Group | Container for all resources |
| Log Analytics Workspace | Centralized logging and monitoring |
| Azure Container Registry | Private container image storage |
| User Assigned Identity | Managed identity for ACR pull |
| Role Assignment | AcrPull permission |
| Container App Environment | Managed environment for apps |
| Container App | The application deployment |

## 🔧 Environment Differences

| Setting | Dev | Prod |
|---------|-----|------|
| ACR SKU | Basic | Standard |
| Log Retention | 30 days | 90 days |
| Min Replicas | 0 (scale to zero) | 2 (always on) |
| Max Replicas | 2 | 10 |
| Revision Mode | Single | Multiple (blue-green) |
| CPU | 0.25 | 0.5 |
| Memory | 0.5Gi | 1Gi |

## 🚀 Quick Start

### Prerequisites

1. [Terraform >= 1.5.0](https://developer.hashicorp.com/terraform/downloads)
2. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Azure subscription with appropriate permissions

### Deploy Development Environment

```bash
# Login to Azure
az login

# Navigate to dev environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### Deploy Production Environment

```bash
# Navigate to prod environment
cd terraform/environments/prod

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes (requires confirmation)
terraform apply
```

## 📤 Outputs

After deployment, these values are available:

| Output | Description |
|--------|-------------|
| `container_app_url` | HTTPS URL of the deployed app |
| `acr_login_server` | ACR server for docker push |
| `acr_name` | ACR name for CI/CD |
| `managed_identity_client_id` | Identity for OIDC auth |

## 🔐 State Management

For production use, configure remote state storage:

1. Create a storage account for state
2. Uncomment the backend configuration in `providers.tf`
3. Run `terraform init -migrate-state`

Example backend configuration:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "stterraformstate"
  container_name       = "tfstate"
  key                  = "dev.terraform.tfstate"
  use_oidc             = true
  use_azuread_auth     = true
}
```

## 🔄 CI/CD Integration

For GitHub Actions with OIDC authentication:

1. Create a federated identity credential
2. Configure GitHub secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
3. Use `azure/login` action with OIDC

## 📝 Customization

Edit `terraform.tfvars` in each environment:

```hcl
project_name = "my-app"
location     = "eastus2"
container_image = "myacr.azurecr.io/myapp:v1.0.0"
```

## ⚠️ Important Notes

- **Zone Redundancy**: Requires VNet integration (infrastructure_subnet_id). Not included in this basic setup for simplicity. Add VNet resources to enable.
- **ACR Admin**: Disabled by design; use managed identity instead
- **Scaling**: Dev scales to zero; prod maintains minimum replicas
- **Revisions**: Prod uses Multiple mode for blue-green deployments
- **State Storage**: Configure remote backend before production use
