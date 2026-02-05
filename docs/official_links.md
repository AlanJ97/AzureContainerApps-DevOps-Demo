# Documentation Reference

Curated links to official documentation for this Azure Container Apps DevOps project.

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

## 📊 Observability & Monitoring

| Topic | Link |
|-------|------|
| **Azure Monitor Alerts** | https://learn.microsoft.com/en-us/azure/container-apps/alerts |
| **Azure Monitor Metrics** | https://learn.microsoft.com/en-us/azure/container-apps/metrics |
| Observability Overview | https://learn.microsoft.com/en-us/azure/container-apps/observability |
| Application Logging | https://learn.microsoft.com/en-us/azure/container-apps/logging |
| Log Streaming | https://learn.microsoft.com/en-us/azure/container-apps/log-streaming |

---

## 🌐 Azure Container Apps (Core)

| Topic | Link |
|-------|------|
| **ACA Overview** | https://learn.microsoft.com/en-us/azure/container-apps/overview |
| **Compare Container Options** | https://learn.microsoft.com/en-us/azure/container-apps/compare-options |
| **Environments** | https://learn.microsoft.com/en-us/azure/container-apps/environment |
| **Revisions** | https://learn.microsoft.com/en-us/azure/container-apps/revisions |
| **Plans** (Consumption vs Dedicated) | https://learn.microsoft.com/en-us/azure/container-apps/plans |
| Health Probes | https://learn.microsoft.com/en-us/azure/container-apps/health-probes |
| Scaling | https://learn.microsoft.com/en-us/azure/container-apps/scale-app |
| Secrets Management | https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets |

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

### Key Vault Resources

| Topic | Link |
|-------|------|
| **Key Vault** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault |
| **Key Vault Secret** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret |
| Key Vault Access Policy | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy |
| Key Vault Key | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key |
| Quick Create Key Vault (Tutorial) | https://learn.microsoft.com/en-us/azure/key-vault/keys/quick-create-terraform?tabs=azure-cli |

### Managed Identity & Authentication

| Topic | Link |
|-------|------|
| **Managed Identity Guide** | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity |
| AzureAD Managed Identity | https://registry.terraform.io/providers/hashicorp/azuread/3.1.0/docs/guides/managed_service_identity |
| Authenticate with Managed Identity | https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure-with-managed-identity-for-azure-services |
| **ACR Auth with Managed Identity** | https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication-managed-identity?tabs=azure-cli |

---

## 🔄 GitHub Actions

### Core Documentation

| Topic | Link |
|-------|------|
| **GitHub Actions Overview** | https://docs.github.com/en/actions |
| **Understanding GitHub Actions** | https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions |
| **Workflow Syntax Reference** | https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions |
| Creating Example Workflow | https://docs.github.com/en/actions/tutorials/create-an-example-workflow |
| Choosing What Workflows Do | https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do |
| Choose When Workflows Run | https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run |
| Choose Where Workflows Run | https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run |
| Use Workflow Templates | https://docs.github.com/en/actions/how-tos/write-workflows/use-workflow-templates |
| **Manage Environments (Deployments)** | https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments |
| **Deployments & Environments (Reference)** | https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments |
| **Create Custom Protection Rules** | https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/create-custom-protection-rules |
| Manual Approvals (Community Article) | https://meijer.works/articles/manual-approvals-in-github-actions/ |

### Python CI/CD

| Topic | Link |
|-------|------|
| **Building and Testing Python** | https://docs.github.com/en/actions/tutorials/build-and-test-code/python |
| Setup Python Action | https://github.com/actions/setup-python |
| Checkout Action | https://github.com/actions/checkout |
| Upload Artifact Action | https://github.com/actions/upload-artifact |

### Docker & Container Registry

| Topic | Link |
|-------|------|
| **Publishing Docker Images** | https://docs.github.com/en/actions/publishing-packages/publishing-docker-images |
| Docker Login Action | https://github.com/docker/login-action |
| Docker Build/Push Action | https://github.com/docker/build-push-action |
| Docker Metadata Action | https://github.com/docker/metadata-action |

### Azure Integration

| Topic | Link |
|-------|------|
| Azure Login Action | https://github.com/Azure/login |
| Azure Container Apps Deploy | https://github.com/Azure/container-apps-deploy-action |
| Terraform Setup Action | https://github.com/hashicorp/setup-terraform |
| Azure CLI Action | https://github.com/Azure/cli |

### Security & Best Practices

| Topic | Link |
|-------|------|
| Using Secrets | https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets |
| GITHUB_TOKEN Authentication | https://docs.github.com/en/actions/security-guides/automatic-token-authentication |
| Secure Use Reference | https://docs.github.com/en/actions/reference/secure-use-reference |
| Starter Workflows Repository | https://github.com/actions/starter-workflows |

---

## 🔒 Security & Scanning

| Tool/Topic | Link |
|------------|------|
| **Security Overview** | https://learn.microsoft.com/en-us/azure/container-apps/security |
| Trivy (Container Scanner) | https://aquasecurity.github.io/trivy/ |
| Bandit (Python SAST) | https://bandit.readthedocs.io/ |
| Checkov (IaC Scanner) | https://www.checkov.io/ |
| **CodeQL** | https://docs.github.com/en/code-security/how-tos/scan-code-for-vulnerabilities/configure-code-scanning/configuring-default-setup-for-code-scanning |

---
## 🧪 Testing & Coverage

### pytest-cov (Code Coverage)

| Topic | Link |
|-------|------|
| **pytest-cov Overview** | https://pytest-cov.readthedocs.io/en/latest/readme.html |
| **Installation & Usage** | https://pytest-cov.readthedocs.io/en/latest/readme.html#installation |
| **Configuration Options** | https://pytest-cov.readthedocs.io/en/latest/config.html |
| Reporting Options | https://pytest-cov.readthedocs.io/en/latest/reporting.html |
| Coverage with Debuggers | https://pytest-cov.readthedocs.io/en/latest/debuggers.html |
| Distributed Testing (xdist) | https://pytest-cov.readthedocs.io/en/latest/xdist.html |
| Markers and Fixtures | https://pytest-cov.readthedocs.io/en/latest/markers-fixtures.html |

### pytest (Testing Framework)

| Topic | Link |
|-------|------|
| **How to use pytest** | https://docs.pytest.org/en/stable/how-to/usage.html |
| **How to use fixtures** | https://docs.pytest.org/en/stable/how-to/fixtures.html |
| **Assertions** | https://docs.pytest.org/en/stable/how-to/assert.html |
| **Parametrize Tests** | https://docs.pytest.org/en/stable/how-to/parametrize.html |
| Test Markers | https://docs.pytest.org/en/stable/how-to/mark.html |
| Temporary Directories | https://docs.pytest.org/en/stable/how-to/tmp_path.html |
| Capture stdout/stderr | https://docs.pytest.org/en/stable/how-to/capture-stdout-stderr.html |
| Handle Test Failures | https://docs.pytest.org/en/stable/how-to/failures.html |

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
| Azure Container Apps (WAF Service Guide) | https://learn.microsoft.com/en-us/azure/well-architected/service-guides/azure-container-apps |
| DevOps at Microsoft | https://learn.microsoft.com/en-us/devops/what-is-devops |

---

*Last updated: February 2026*
