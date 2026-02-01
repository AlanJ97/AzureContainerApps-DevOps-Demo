# Official Documentation Links

> Reference documentation for Azure Container Apps DevOps project.

---

## � Deployment & CI/CD

| Topic | Link |
|-------|------|
| Code-to-Cloud Options | https://learn.microsoft.com/en-us/azure/container-apps/code-to-cloud-options |
| `az containerapp up` Command | https://learn.microsoft.com/en-us/azure/container-apps/containerapp-up |
| Deploy First App (CLI) | https://learn.microsoft.com/en-us/azure/container-apps/tutorial-deploy-first-app-cli |
| Build & Deploy from Code | https://learn.microsoft.com/en-us/azure/container-apps/tutorial-deploy-from-code |
| Tutorial: Code to Cloud | https://learn.microsoft.com/en-us/azure/container-apps/tutorial-code-to-cloud |
| **GitHub Actions Deploy** | https://learn.microsoft.com/en-us/azure/container-apps/github-actions |
| Environment Variables | https://learn.microsoft.com/en-us/azure/container-apps/environment-variables |
| Deployment Labels (Blue-Green) | https://learn.microsoft.com/en-us/azure/container-apps/deployment-labels |
| Communication Between Apps | https://learn.microsoft.com/en-us/azure/container-apps/connect-apps |
| Microservices Tutorial | https://learn.microsoft.com/en-us/azure/container-apps/communicate-between-microservices |

---

## �🔭 Observability & Monitoring

| Topic | Link |
|-------|------|
| Observability Overview | https://learn.microsoft.com/en-us/azure/container-apps/observability |
| Application Logging | https://learn.microsoft.com/en-us/azure/container-apps/logging |
| Log Storage Options | https://learn.microsoft.com/en-us/azure/container-apps/log-options |
| Log Streaming (Real-time) | https://learn.microsoft.com/en-us/azure/container-apps/log-streaming |
| Grafana Dashboards | https://learn.microsoft.com/en-us/azure/container-apps/grafana-dashboards |
| Aspire Dashboard (OTel) | https://learn.microsoft.com/en-us/azure/container-apps/aspire-dashboard |
| Azure Monitor Metrics | https://learn.microsoft.com/en-us/azure/container-apps/metrics |
| Azure Monitor Alerts | https://learn.microsoft.com/en-us/azure/container-apps/alerts |

---

## 🤖 Azure SRE Agent (AI-Powered Troubleshooting)

| Topic | Link |
|-------|------|
| SRE Agent Overview | https://learn.microsoft.com/en-us/azure/sre-agent/overview |
| SRE Agent Usage | https://learn.microsoft.com/en-us/azure/sre-agent/usage |
| Troubleshoot Container Apps | https://learn.microsoft.com/en-us/azure/sre-agent/troubleshoot-azure-container-apps |

---

## 🌐 Networking & Ingress

| Topic | Link |
|-------|------|
| **Ingress Overview** | https://learn.microsoft.com/en-us/azure/container-apps/ingress-overview |
| Ingress Environment Config | https://learn.microsoft.com/en-us/azure/container-apps/ingress-environment-configuration |
| Configure Ingress (How-to) | https://learn.microsoft.com/en-us/azure/container-apps/ingress-how-to |
| **Blue-Green Deployment** | https://learn.microsoft.com/en-us/azure/container-apps/blue-green-deployment |
| **Traffic Splitting** | https://learn.microsoft.com/en-us/azure/container-apps/traffic-splitting |
| Virtual Network Configuration | https://learn.microsoft.com/en-us/azure/container-apps/custom-virtual-networks |
| VNet Custom Setup | https://learn.microsoft.com/en-us/azure/container-apps/vnet-custom |

---

## 🐳 Azure Container Apps (Core Concepts)

| Topic | Link |
|-------|------|
| ACA Overview | https://learn.microsoft.com/en-us/azure/container-apps/overview |
| **Compare Container Options** | https://learn.microsoft.com/en-us/azure/container-apps/compare-options |
| **Plan Types** (Consumption vs Dedicated) | https://learn.microsoft.com/en-us/azure/container-apps/plans |
| **Environments** | https://learn.microsoft.com/en-us/azure/container-apps/environment |
| **Revisions** (Update & Deploy) | https://learn.microsoft.com/en-us/azure/container-apps/revisions |
| **Application Lifecycle** | https://learn.microsoft.com/en-us/azure/container-apps/application-lifecycle-management |
| **Microservices** | https://learn.microsoft.com/en-us/azure/container-apps/microservices |
| Quickstart | https://learn.microsoft.com/en-us/azure/container-apps/quickstart-portal |
| Health Probes | https://learn.microsoft.com/en-us/azure/container-apps/health-probes |
| Scaling | https://learn.microsoft.com/en-us/azure/container-apps/scale-app |
| Environment Variables | https://learn.microsoft.com/en-us/azure/container-apps/environment-variables |
| Secrets | https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets |

---

## 🏗️ Terraform - AzureRM Provider

### Core Provider & Backend

| Topic | Link |
|-------|------|
| AzureRM Provider Docs | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs |
| **Azure Backend (State)** | https://developer.hashicorp.com/terraform/language/backend/azurerm |
| Storage Account (State) | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account |

### Container Apps Resources

| Topic | Link |
|-------|------|
| **Container App** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app |
| **Container App Environment** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment |
| Container App Custom Domain | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_custom_domain |
| Container App Environment Certificate | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_certificate |
| Container App Environment Storage | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_storage |
| Container App Environment Dapr Component | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_dapr_component |
| Container App Job | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_job |

### Container Registry & Identity

| Topic | Link |
|-------|------|
| **Container Registry** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry |
| **User Assigned Identity** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity |
| **Role Assignment (AcrPull)** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment |
| Federated Identity Credential (OIDC) | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential |

### Monitoring & Logging

| Topic | Link |
|-------|------|
| **Log Analytics Workspace** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace |
| Application Insights | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights |

---

## 🏗️ Terraform - Language & Modules

| Topic | Link |
|-------|------|
| **Module Structure** | https://developer.hashicorp.com/terraform/language/modules/develop/structure |
| **Module Composition** | https://developer.hashicorp.com/terraform/language/modules/develop/composition |
| **Providers in Modules** | https://developer.hashicorp.com/terraform/language/modules/develop/providers |
| **Sensitive Data Management** | https://developer.hashicorp.com/terraform/language/manage-sensitive-data

---

## 🔄 GitHub Actions & CI/CD

| Topic | Link |
|-------|------|
| GitHub Actions Docs | https://docs.github.com/en/actions |
| Azure Login Action | https://github.com/Azure/login |
| Docker Build/Push Action | https://github.com/docker/build-push-action |
| Terraform Setup Action | https://github.com/hashicorp/setup-terraform |

---

## 🔒 Security Scanning Tools

| Tool | Link |
|------|------|
| Trivy (Image Scanner) | https://aquasecurity.github.io/trivy/ |
| Bandit (Python SAST) | https://bandit.readthedocs.io/ |
| Checkov (IaC Scanner) | https://www.checkov.io/1.Welcome/Quick%20Start.html |
| Flake8 (Python Linter) | https://flake8.pycqa.org/ |

---

## � Security & Reliability

| Topic | Link |
|-------|------|
| **Security Overview** | https://learn.microsoft.com/en-us/azure/container-apps/security |
| **Manage Secrets** | https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets |
| Managed Identity Overview | https://learn.microsoft.com/en-us/azure/container-apps/managed-identity |
| **Image Pull with Managed Identity** | https://learn.microsoft.com/en-us/azure/container-apps/managed-identity-image-pull |
| Token Store (Easy Auth) | https://learn.microsoft.com/en-us/azure/container-apps/token-store |
| Secure Deployment | https://learn.microsoft.com/en-us/azure/container-apps/deployment-authentication |
| **Reliability Architecture** | https://learn.microsoft.com/en-us/azure/reliability/reliability-azure-container-apps |
| **Zone Redundancy** | https://learn.microsoft.com/en-us/azure/reliability/migrate-container-apps |

---

## �📚 Best Practices & Learning

| Topic | Link |
|-------|------|
| 12-Factor App | https://12factor.net/ |
| Azure Well-Architected Framework | https://learn.microsoft.com/en-us/azure/well-architected/ |
| DevOps at Microsoft | https://learn.microsoft.com/en-us/devops/what-is-devops |

---

*Last updated: February 2026*
