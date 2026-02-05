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

### Core Resources

| Resource | Description |
|----------|-------------|
| Resource Group | Container for all resources |
| Log Analytics Workspace | Centralized logging and monitoring |
| Azure Container Registry | Private container image storage |
| User Assigned Identity | Managed identity for ACR pull |
| Role Assignment | AcrPull permission |
| Container App Environment | Managed environment for apps |
| Container App | The application deployment |

### Monitoring Resources

| Resource | Description |
|----------|-------------|
| Application Insights | APM with OpenTelemetry integration |
| Portal Dashboard | 6 metric tiles (HTTP, CPU, Memory, Replicas) |
| Action Group | Email notification channel |
| Metric Alerts | CPU, Memory, HTTP errors, Container restarts |
| Log Alert | Application exceptions and errors |

## 🔧 Environment Differences

| Setting | Dev | Prod |
|---------|-----|------|
| ACR SKU | Basic | Standard |
| Log Retention | 30 days | 90 days |
| Min Replicas | 0 | 2 |
| Max Replicas | 2 | 10 |
| Revision Mode | Single | Multiple |
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

After deployment, access these values:

### Application
- `container_app_url` - HTTPS URL of the deployed app
- `container_app_name` - Container App resource name

### Registry
- `acr_login_server` - ACR server for docker push
- `acr_name` - ACR name for CI/CD

### Monitoring
- `application_insights_id` - App Insights resource ID
- `dashboard_id` - Portal dashboard resource ID

### Authentication  
- `managed_identity_client_id` - Identity for OIDC auth

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
# Basic Configuration
project_name    = "my-app"
location        = "eastus2"
container_image = "myacr.azurecr.io/myapp:v1.0.0"

# Monitoring (optional)
enable_key_vault          = true
alert_email_addresses     = ["ops@company.com"]
alert_cpu_threshold       = 80
alert_memory_threshold    = 80
enable_monitoring_dashboard = true
```

## ⚠️ Important Notes

- **State Storage**: Configure remote backend for production (see State Management section)
- **ACR Authentication**: Uses managed identity (admin user disabled)
- **Scaling**: Dev can scale to zero; prod maintains minimum replicas  
- **Monitoring**: Application Insights and dashboard are always created
- **Key Vault**: Optional; if disabled, App Insights connection string passed directly
- **Alerts**: Configure `alert_email_addresses` to receive notifications
