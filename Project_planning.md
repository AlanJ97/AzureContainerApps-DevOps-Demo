# Project Planning - Azure Container Apps DevOps Demo

> **Purpose:** Full DevOps lifecycle demonstration on Azure Container Apps.

---

## 📋 Project Checklist (Simple View)

| # | Phase | Task | Status |
|---|-------|------|--------|
| 1 | **App** | Create simple FastAPI app (health, info, metrics endpoints) | ✅ |
| 2 | **Docker** | Write multi-stage Dockerfile | ✅ |
| 3 | **IaC** | Create Terraform modules (ACR, ACA, Log Analytics, App Insights) | ✅ |
| 4 | **IaC** | Set up environment folders (dev, prod) with tfvars | ✅ |
| 5 | **Git** | Initialize GitHub repo with branch protection | ✅ |
| 6 | **CI** | GitHub Action: Lint, Test, Security Scan (PR trigger) | ✅ |
| 7 | **CD** | GitHub Action: Build, Push ACR, Deploy ACA (main trigger) | ✅ |
| 8 | **IaC** | Create Azure Storage for Terraform state (backend) | ✅ |
| 9 | **IaC** | Create Service Principal for GitHub Actions auth | ✅ |
| 10 | **IaC** | Configure GitHub Secrets for Azure authentication | ✅ |
| 11 | **IaC** | Terraform CI passing (fmt, validate, plan) | ✅ |
| 12 | **Deploy** | Run Terraform CD to deploy infrastructure (dev) | ✅ |
| 13 | **Deploy** | Run Terraform CD to deploy infrastructure (prod) | ✅ |
| 14 | **Deploy** | Run App CD to build/push/deploy container (dev) | ✅ |
| 15 | **HA** | Configure min_replicas=2, health probes | ✅ (in tfvars) |
| 16 | **Observability** | Configure Log Analytics + App Insights | ✅ (in module) |
| 17 | **Docs** | Write README with architecture diagram | ✅ |

---

## 🏗️ Architecture Summary

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           GITHUB REPOSITORY                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐          │
│  │ feature/ │───▶│   PR     │───▶│   dev    │───▶│   main   │          │
│  │  branch  │    │  (CI)    │    │ (CD Dev) │    │ (CD Prod)│          │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘          │
└─────────────────────────────────────────────────────────────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    ▼                                   ▼
            ┌───────────────┐                   ┌───────────────┐
            │   DEV ENV     │                   │   PROD ENV    │
            │ ┌───────────┐ │                   │ ┌───────────┐ │
            │ │VNet /27   │ │                   │ │VNet /27   │ │
            │ └───────────┘ │                   │ └───────────┘ │
            │ ┌───────────┐ │                   │ ┌───────────┐ │
            │ │ACR+Identity│◀────────────────────│ACR+Identity│ │
            │ └───────────┘ │   (same image)    │ └───────────┘ │
            │ ┌───────────┐ │                   │ ┌───────────┐ │
            │ │ACA Env    │ │                   │ │ACA Env    │ │
            │ │(Ingress)  │ │                   │ │Zone Redun.│ │
            │ │replicas=1 │ │                   │ │replicas=2+│ │
            │ └───────────┘ │                   │ └───────────┘ │
            └───────────────┘                   └───────────────┘
```

---

## 🔀 Git Branch Strategy (GitHub Flow)

| Branch | Purpose | Trigger |
|--------|---------|---------|
| `feature/*` | New features/fixes | Developer creates |
| `dev` | Integration branch for Dev environment | Merge from feature |
| `main` | Production-ready code | Merge from dev (with approval) |

**Rules:**
- No direct commits to `main` or `dev`
- All changes via Pull Request
- PR requires: passing CI checks + 1 approval

---

## 🐍 Python App (Simple but Professional)

**Framework:** FastAPI

| Endpoint | Purpose |
|----------|---------|
| `GET /health` | Returns `200 OK` (for ACA health probes) |
| `GET /info` | Returns hostname, environment name, version |
| `GET /` | Simple welcome message |

---

## 🏭 Terraform Strategy (Multi-Environment with Modules)

### Folder Structure
```
/terraform
  /modules
    /aca_stack           ← Reusable "blueprint"
      - main.tf
      - variables.tf
      - outputs.tf
  /environments
    /dev
      - main.tf          ← Calls module with dev values
      - terraform.tfvars ← replicas=1, sku=Consumption
      - backend.tf       ← Dev state in Storage Account
    /prod
      - main.tf          ← Calls module with prod values
      - terraform.tfvars ← replicas=2, sku=Dedicated
      - backend.tf       ← Prod state in Storage Account
```

### How Code Connects to Environment
**Principle:** "Build Once, Configure Everywhere" (12-Factor App)

1. **Docker Image** is built ONCE (no environment info inside)
2. **Terraform** injects environment variables at deploy time:
   ```hcl
   env {
     name  = "APP_ENVIRONMENT"
     value = var.environment_name  # "dev" or "prod"
   }
   ```
3. **Python** reads at runtime:
   ```python
   env = os.getenv("APP_ENVIRONMENT", "local")
   ```

---

## 🔒 CI/CD Pipeline (GitHub Actions)

### Official GitHub Action
Use Microsoft's official action: `azure/container-apps-deploy-action@v1`

### CI Pipeline (On Pull Request)
```yaml
Trigger: pull_request → dev, main

Jobs:
  1. Lint Python (flake8)
  2. Lint Terraform (terraform fmt -check)
  3. Security Scan Code (bandit)
  4. Security Scan IaC (checkov)
  5. Unit Tests (pytest)
```

### CD Pipeline (On Push to dev/main)
```yaml
Trigger: push → dev OR main

Jobs:
  1. Build Docker Image (use `az acr build` - cloud build, no local Docker needed)
  2. Scan Image for CVEs (trivy)
  3. Push to ACR (tag with ${{ github.sha }} - NEVER use 'latest')
  4. Terraform Init + Plan + Apply
     - dev branch → /environments/dev
     - main branch → /environments/prod
```

### Best Practices from Official Docs
- ✅ **Use commit SHA as image tag** (not `latest`) - ensures new revisions are created
- ✅ **Use Managed Identity** for ACR authentication (not admin credentials)
- ✅ **Use `az acr build`** for cloud-based builds (no local Docker required)
- ✅ **Use Deployment Labels** for blue-green/A/B testing

---

## 🛡️ Security Strategy (From Official Docs)

### Authentication & Identity
| Feature | Implementation |
|---------|----------------|
| **Managed Identity** | User-assigned for ACR pulls (AcrPull role) |
| **Secrets** | Reference from Azure Key Vault (not hardcoded) |
| **HTTPS** | Enforce via `allowInsecure: false` in ingress |

### Managed Identity for ACR (Recommended)
```bash
# Assign AcrPull role to managed identity
az role assignment create \
  --assignee <MANAGED_IDENTITY_PRINCIPAL_ID> \
  --role AcrPull \
  --scope <ACR_RESOURCE_ID>

# Configure container app to use managed identity
az containerapp registry set \
  --name my-container-app \
  --server <ACR_NAME>.azurecr.io \
  --identity system
```

### Secrets Best Practices
- ❌ **Don't** store secrets directly in Container Apps for production
- ✅ **Do** use Azure Key Vault integration
- ✅ **Do** reference secrets in env vars (not hardcode)
- ✅ **Do** mount secrets as files when appropriate

---

## 🛡️ Security Scanning Summary

| Tool | What it Scans | When |
|------|---------------|------|
| `flake8` | Python syntax/style | PR |
| `bandit` | Python security vulnerabilities | PR |
| `checkov` | Terraform misconfigurations | PR |
| `trivy` | Docker image CVEs | CD (before push) |

---

## 🌐 Networking & Ingress (From Official Docs)

### VNet Configuration
| Environment | Subnet Size | Notes |
|-------------|-------------|-------|
| Workload Profiles | `/27` minimum | Dedicated subnet for ACA |
| Zone Redundant | `/27` minimum | Required for zone redundancy |

**Subnet Reserved Ranges (Cannot Use):**
- `169.254.0.0/16`, `172.30.0.0/16`, `172.31.0.0/16`, `192.0.2.0/24`

### Ingress Configuration
| Setting | Value | Purpose |
|---------|-------|--------|
| `external` | `true` | Public internet access |
| `allowInsecure` | `false` | Force HTTPS redirect |
| `targetPort` | `8000` | FastAPI app port |
| `transport` | `auto` | HTTP/1.1 + HTTP/2 |

### Key Ingress Features
- ✅ **TLS Termination** at ingress proxy (HTTPS endpoints always TLS 1.2+)
- ✅ **Traffic Splitting** between revisions for A/B testing
- ✅ **Session Affinity** (sticky sessions) for stateful apps
- ✅ **Peer-to-peer encryption** within environment (optional)
- ✅ **CORS** configuration available

---

## 🔄 Revisions & Blue-Green Deployment (From Official Docs)

### Revision Modes
| Mode | Description | Use Case |
|------|-------------|----------|
| **Single** (default) | Auto-deactivates old revisions, zero-downtime | Simple deployments |
| **Multiple** | Keep multiple active, manual traffic control | Blue-green, A/B testing |

### Blue-Green Strategy (For Production)
```yaml
# Revision naming with commit SHA
revision-suffix: ${{ github.sha }}

# Labels for blue-green
blue: stable production
green: new version being tested
```

### Traffic Splitting Example
```json
{
  "traffic": [
    { "revisionName": "app--blue", "weight": 100, "label": "blue" },
    { "revisionName": "app--green", "weight": 0, "label": "green" }
  ]
}
```

### Rollback Strategy
- ✅ Use revision labels to quickly switch traffic back
- ✅ Keep up to 100 inactive revisions (configurable)
- ✅ Reactivate old revisions if needed

---

## 📈 High Availability & Reliability (From Official Docs)

### Zone Redundancy (Production)
| Setting | Dev | Prod |
|---------|-----|------|
| Zone Redundancy | ❌ Disabled | ✅ Enabled |
| `min_replicas` | 1 | 2+ (distributed across zones) |
| `max_replicas` | 3 | 10 |
| Health Probe | `/health` | `/health` |
| Probe Interval | 10s | 10s |

### Key Requirements for Zone Redundancy
- ✅ Must be enabled during **environment creation** (cannot change later)
- ✅ Requires **Virtual Network** with infrastructure subnet
- ✅ Set `min_replicas >= 2` to ensure distribution across zones
- ✅ No extra cost for zone redundancy

### Reliability Features (Automatic)
- **Automatic health monitoring**: Platform restarts failed containers
- **Traffic rerouting**: ~30 seconds failover during zone failure
- **Rolling updates**: During maintenance, updates applied in stages

### Terraform Configuration for Zone Redundancy
```hcl
resource "azurerm_container_app_environment" "main" {
  name                       = "env-demo-prod"
  zone_redundancy_enabled    = true  # Only for Prod!
  infrastructure_subnet_id   = azurerm_subnet.aca.id
}
```

### Application Lifecycle Management
| Phase | What Happens |
|-------|--------------|
| **Deployment** | First revision auto-created |
| **Update** | New revision created (revision-scope changes) |
| **Deactivate** | Containers shut down, revision dormant |
| **Shutdown** | SIGTERM → 30s grace → SIGKILL |

**Important:** Handle `SIGTERM` gracefully in your app for clean shutdown!

---

## 🔭 Observability Strategy

### What We Will Implement

| Layer | Tool | Purpose |
|-------|------|---------|
| **Logs** | Log Analytics Workspace | Store & query `stdout/stderr` and system logs |
| **Metrics** | Azure Monitor Metrics | CPU, Memory, Requests, Replicas |
| **Traces** | Application Insights | Request tracing, dependencies, failures |
| **Dashboards** | Grafana (built-in preview) | Visual monitoring |
| **Alerts** | Azure Monitor Alerts | Notify on error rates, latency |
| **Real-time** | Log Streaming | Live debugging via Portal/CLI |

### Implementation via Terraform

```hcl
# 1. Create Log Analytics Workspace (stores all logs)
resource "azurerm_log_analytics_workspace" "main" { ... }

# 2. Create Application Insights (connected to Log Analytics)
resource "azurerm_application_insights" "main" {
  workspace_id = azurerm_log_analytics_workspace.main.id
}

# 3. Create ACA Environment (linked to Log Analytics)
resource "azurerm_container_app_environment" "main" {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

# 4. Inject App Insights connection string into Container App
resource "azurerm_container_app" "main" {
  template {
    container {
      env {
        name        = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "appinsights-connection-string"
      }
    }
  }
}
```

### Log Categories Available
- **Container Console Logs:** Your app's `stdout`/`stderr`
- **System Logs:** ACA service events (revision created, scaling, errors)

### Viewing Options
1. **Portal → Log Analytics:** Run KQL queries
2. **Portal → Log Stream:** Real-time live tail
3. **Portal → Grafana Dashboard:** Pre-built visualizations
4. **CLI:** `az containerapp logs show --follow`

### Optional (Advanced)
- **Azure SRE Agent (Preview):** AI-powered troubleshooting assistant
- **Aspire Dashboard:** OpenTelemetry traces visualization (mainly for .NET)

---

## 📁 Final Project Structure

```
/AzureContainerApps
├── .github/
│   └── workflows/
│       ├── ci.yaml              # Lint + Test + Security (PR)
│       └── cd.yaml              # Build + Push + Deploy (push)
├── app/
│   ├── main.py                  # FastAPI application
│   ├── requirements.txt         # Dependencies
│   └── tests/
│       └── test_main.py         # Unit tests
├── docker/
│   └── Dockerfile               # Multi-stage build
├── terraform/
│   ├── modules/
│   │   └── aca_stack/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       ├── dev/
│       │   ├── main.tf
│       │   ├── terraform.tfvars
│       │   └── backend.tf
│       └── prod/
│           ├── main.tf
│           ├── terraform.tfvars
│           └── backend.tf
├── docs/
│   └── official_links.md        # Reference documentation
├── Project_planning.md          # This file
└── README.md                    # Project documentation
```

---

## 🚀 Next Steps (In Order)

1. **[ ] Create the Python FastAPI app** (`app/main.py`)
2. **[ ] Create the Dockerfile** (`docker/Dockerfile`)
3. **[ ] Create Terraform module** (`terraform/modules/aca_stack/`)
4. **[ ] Create environment configs** (`terraform/environments/dev/`, `prod/`)
5. **[ ] Create CI workflow** (`.github/workflows/ci.yaml`)
6. **[ ] Create CD workflow** (`.github/workflows/cd.yaml`)
7. **[ ] Initialize GitHub repo and test pipeline**
8. **[ ] Deploy to Azure and validate observability**
