# Monitoring & Observability

Comprehensive monitoring for Azure Container Apps using OpenTelemetry, Azure Monitor, and Application Insights.

## Components

- **OpenTelemetry** - Automatic instrumentation + custom metrics
- **Application Insights** - APM, distributed tracing, telemetry collection
- **Azure Portal Dashboard** - Real-time metrics visualization (6 tiles)
- **Alert Rules** - 5 automated notifications via email
- **Log Analytics** - Centralized log storage and querying

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

## Dashboard Tiles

1. **Information Banner** - Project name and environment
2. **Resource Cards** - Container App and Log Analytics links
3. **HTTP Requests** - Request count over time (1 hour)
4. **CPU Usage** - Average CPU consumption in nanocores (1 hour)
5. **Memory Usage** - Average working set memory in bytes (1 hour)
6. **Active Replicas** - Number of running containers (1 hour)

## Alert Rules

| Alert | Condition | Severity | Window |
|-------|-----------|----------|--------|
| **CPU Usage** | > 80% (configurable) | Warning | 5 min |
| **Memory Usage** | > 80% (configurable) | Warning | 5 min |
| **HTTP 5xx Errors** | > 10/min (configurable) | Error | 5 min |
| **Container Restarts** | > 3 in 15 min | Warning | 15 min |
| **Application Errors** | > 5 errors in 5 min | Warning | 15 min |

## Configuration

Add to `terraform.tfvars`:

```hcl
# Monitoring
enable_monitoring_dashboard = true
enable_alerts               = true
alert_email_addresses       = ["ops@example.com"]

# Thresholds (optional)
alert_cpu_threshold        = 80
alert_memory_threshold     = 80
alert_http_error_threshold = 10
```

## OpenTelemetry Metrics

Custom application metrics:
- `items_created` - Counter for created items
- `items_deleted` - Counter for deleted items
- `item_name_length` - Histogram of item name lengths
- `items_in_db` - UpDownCounter tracking database size

## Access

**Azure Portal**: Dashboard → `Container Apps DevOps Demo - {env}`

**Terraform Output**:
```bash
terraform output dashboard_id
```

**Azure CLI**:
```bash
az portal dashboard show \
  --name dashboard-<project>-<env> \
  --resource-group rg-<project>-<env>
```

**Email Alerts**: Recipients must confirm subscription by clicking "Activate this action group" in the initial email from Azure Monitor.

## Testing Alerts

```bash
# CPU: Generate load with concurrent requests
for i in {1..1000}; do curl https://<app-url>/items & done

# HTTP Errors: Request non-existent items
for i in {1..20}; do curl https://<app-url>/items/999999; done
```

## Best Practices

- Start with conservative thresholds and adjust based on actual usage
- Use appropriate severity levels (0-1: critical, 2-3: warnings)
- Avoid alert fatigue - too many alerts lead to ignoring them
- Test alerts regularly to ensure they trigger correctly
- Review dashboard metrics to identify trends

## Troubleshooting

**Alerts not triggering**
- Confirm email subscriptions in action group
- Verify metrics are flowing to Azure Monitor
- Check threshold values match workload patterns

**Dashboard shows no data**
- Verify metrics in Azure Monitor Metrics Explorer
- Check time range selection
- Ensure resources are deployed and active

**Metrics delayed**
- Container Apps metrics take 1-2 minutes to appear
- Application Insights telemetry requires OpenTelemetry SDK

## Cost

- Dashboard: Free
- Metric Alerts: First 10 free, then ~$0.10/rule/month
- Log Alerts: Based on query frequency and data volume
- Action Groups: Email notifications free
- Application Insights: First 5GB/month free, then ~$2.30/GB

**Estimated**: $2-5/month depending on data volume
