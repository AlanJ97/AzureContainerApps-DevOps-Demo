# Monitoring & Alerting Configuration

## Overview

This module provides comprehensive monitoring and alerting for Azure Container Apps using:
- **Azure Portal Dashboard** - Real-time metrics visualization
- **Metric Alerts** - Proactive notifications for resource issues
- **Application Insights Alerts** - Application-level error detection
- **Email Notifications** - Action groups for alert delivery

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Azure Container App                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Container Instances (Replicas)                      │   │
│  │  - CPU, Memory, HTTP metrics                         │   │
│  │  - OpenTelemetry instrumentation                     │   │
│  └──────────────────────────────────────────────────────┘   │
└───────────────────┬─────────────────────────────────────────┘
                    │
          ┌─────────┴──────────┐
          │                    │
          ▼                    ▼
┌──────────────────┐  ┌────────────────────┐
│ Azure Monitor    │  │ App Insights       │
│ - Metrics        │  │ - Traces           │
│ - Alerts         │  │ - Metrics          │
│ - Action Groups  │  │ - Logs             │
└────────┬─────────┘  └──────┬─────────────┘
         │                   │
         └─────────┬─────────┘
                   │
         ┌─────────┴──────────┐
         │                    │
         ▼                    ▼
┌──────────────────┐  ┌────────────────────┐
│ Portal Dashboard │  │ Email Notifications │
│ - 6 metric tiles │  │ - Action Group      │
│ - Resource info  │  │ - 5 alert rules     │
└──────────────────┘  └────────────────────┘
```

## Dashboard Components

The Azure Portal dashboard includes the following tiles:

### 1. **Information Banner** (Markdown)
- Project name and environment
- Dashboard description

### 2. **Resource Cards**
- Container App resource overview
- Log Analytics workspace link

### 3. **HTTP Requests Chart**
- Total request count over time
- Metric: `Requests`
- Aggregation: Total
- Time range: Last 1 hour

### 4. **CPU Usage Chart**
- CPU consumption in nanocores
- Metric: `UsageNanoCores`
- Aggregation: Average
- Time range: Last 1 hour

### 5. **Memory Usage Chart**
- Working set memory in bytes
- Metric: `WorkingSetBytes`
- Aggregation: Average
- Time range: Last 1 hour

### 6. **Active Replicas Chart**
- Number of running container instances
- Metric: `Replicas`
- Aggregation: Average
- Time range: Last 1 hour

## Alert Rules

### Metric Alerts (Container Apps)

#### 1. **High CPU Usage**
- **Condition**: CPU usage > threshold (default: 80%)
- **Severity**: 2 (Warning)
- **Frequency**: Every 1 minute
- **Window**: 5 minutes
- **Metric**: `UsageNanoCores`

#### 2. **High Memory Usage**
- **Condition**: Memory usage > threshold (default: 80%)
- **Severity**: 2 (Warning)
- **Frequency**: Every 1 minute
- **Window**: 5 minutes
- **Metric**: `WorkingSetBytes`

#### 3. **HTTP 5xx Errors**
- **Condition**: 5xx errors > threshold (default: 10/min)
- **Severity**: 1 (Error)
- **Frequency**: Every 1 minute
- **Window**: 5 minutes
- **Metric**: `Requests` (filtered by statusCode=5xx)

#### 4. **Container Restarts**
- **Condition**: Restart count > 3 in 15 minutes
- **Severity**: 2 (Warning)
- **Frequency**: Every 5 minutes
- **Window**: 15 minutes
- **Metric**: `RestartCount`

### Log Alerts (Application Insights)

#### 5. **Application Errors**
- **Condition**: Error-level logs > 5 per 5 minutes
- **Severity**: 2 (Warning)
- **Frequency**: Every 5 minutes
- **Window**: 15 minutes
- **Query**: Kusto query on `traces` table filtering `severityLevel >= 3`

## Configuration

### Variables

Add to your environment configuration (e.g., `dev/terraform.tfvars`):

```hcl
# Enable/disable features
enable_monitoring_dashboard = true
enable_alerts               = true

# Alert notification emails
alert_email_addresses = [
  "devops@example.com",
  "team-lead@example.com"
]

# Alert thresholds (customize as needed)
alert_cpu_threshold        = 80  # percentage
alert_memory_threshold     = 80  # percentage
alert_http_error_threshold = 10  # errors per minute
```

### Example Usage

```hcl
module "aca_stack" {
  source = "../../modules/aca-stack"

  project_name = "my-app"
  environment  = "dev"
  
  # ... other configuration ...

  # Monitoring configuration
  enable_monitoring_dashboard = true
  enable_alerts              = true
  alert_email_addresses      = ["ops@mycompany.com"]
  alert_cpu_threshold        = 75
  alert_memory_threshold     = 85
  alert_http_error_threshold = 20
}
```

## Accessing the Dashboard

After deployment, the dashboard is created in the same resource group as the container app.

### Via Azure Portal:
1. Navigate to the Azure Portal
2. Go to **Dashboard** (left sidebar)
3. Find dashboard named: `Container Apps DevOps Demo - <Environment>`

### Via Terraform Output:
```bash
terraform output dashboard_id
```

### Via Azure CLI:
```bash
az portal dashboard show \
  --name "dashboard-<project>-<env>" \
  --resource-group "rg-<project>-<env>"
```

## Email Notifications

### Setup
Alert emails are sent via Azure Monitor Action Groups. Configure email addresses in the `alert_email_addresses` variable.

### Email Format
Emails include:
- Alert name and description
- Severity level
- Triggered condition
- Resource details
- Link to Azure Portal for investigation

### Confirming Subscription
When first configured, recipients will receive an email from Azure to confirm their subscription to the action group. They must click "Activate this action group" to start receiving alerts.

## Testing Alerts

### Test CPU Alert
Generate CPU load:
```bash
# Make many concurrent requests
for i in {1..1000}; do
  curl https://<app-url>/items &
done
```

### Test Memory Alert
Create many large items to consume memory.

### Test HTTP Error Alert
Trigger application errors:
```bash
# Request non-existent items
for i in {1..20}; do
  curl https://<app-url>/items/999999
done
```

### Test Application Error Alert
Check Application Insights logs for error entries.

## Customization

### Adding Custom Metrics to Dashboard

1. Edit `dashboard.tpl`
2. Add new part to the `parts` object
3. Configure metric visualization
4. Update Terraform to redeploy

### Adding Custom Alert Rules

1. Add new `azurerm_monitor_metric_alert` resource in `monitoring.tf`
2. Configure condition and threshold
3. Add to action group
4. Apply Terraform changes

### Modifying Thresholds

Update variables in environment config:
```hcl
alert_cpu_threshold        = 90  # Increase to reduce noise
alert_http_error_threshold = 5   # Decrease for stricter monitoring
```

## Monitoring Best Practices

1. **Start Conservative**: Begin with higher thresholds and adjust based on actual usage patterns
2. **Use Severity Appropriately**: 
   - Severity 0-1: Critical issues requiring immediate action
   - Severity 2-3: Warnings for investigation
   - Severity 4: Informational
3. **Avoid Alert Fatigue**: Too many alerts lead to ignoring them
4. **Test Regularly**: Validate alerts trigger correctly
5. **Document Runbooks**: Create procedures for responding to each alert type
6. **Review Metrics**: Use dashboard to identify trends and optimize

## Troubleshooting

### Alerts Not Triggering
- Verify action group email subscriptions are confirmed
- Check metric data is flowing to Azure Monitor
- Validate threshold values are appropriate for workload
- Review alert rule enabled status

### Dashboard Not Showing Data
- Verify metrics are available in Azure Monitor Metrics Explorer
- Check time range selection on dashboard
- Ensure resources are deployed and active
- Verify Application Insights connection (if enabled)

### Missing Metrics
- Container Apps metrics may take 1-2 minutes to appear
- Application Insights telemetry requires app deployment with SDK
- Some metrics only appear under load

## Cost Considerations

- **Dashboard**: No additional cost
- **Metric Alerts**: First 10 rules free per subscription, then ~$0.10/rule/month
- **Log Alerts**: Based on query frequency and data volume
- **Action Groups**: Email notifications are free (SMS/voice have costs)
- **Application Insights**: Included in first 5GB/month, then ~$2.30/GB

Estimated cost for this configuration: **~$2-5/month** depending on data volume.

## Resources

- [Azure Monitor Alerts Overview](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)
- [Container Apps Metrics](https://learn.microsoft.com/en-us/azure/container-apps/metrics)
- [Azure Portal Dashboards](https://learn.microsoft.com/en-us/azure/azure-portal/azure-portal-dashboards)
- [Application Insights Alerting](https://learn.microsoft.com/en-us/azure/azure-monitor/app/alerts)
