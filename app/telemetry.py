"""
OpenTelemetry Configuration for Azure Application Insights

This module configures OpenTelemetry instrumentation for the FastAPI application,
sending traces, metrics, and logs to Azure Application Insights.

Architecture:
- Uses Azure Monitor OpenTelemetry Exporter for Python
- Automatic instrumentation for FastAPI, HTTP requests
- Custom metrics and spans can be added as needed
- Connection string loaded from environment variable
"""
import logging
import os
from typing import Optional

from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import Resource, SERVICE_NAME, SERVICE_VERSION, SERVICE_INSTANCE_ID
from azure.monitor.opentelemetry.exporter import (
    AzureMonitorTraceExporter,
    AzureMonitorMetricExporter,
)


logger = logging.getLogger(__name__)


def configure_telemetry(
    service_name: str,
    service_version: str,
    service_instance_id: Optional[str] = None,
) -> tuple[trace.Tracer, metrics.Meter]:
    """
    Configure OpenTelemetry with Azure Monitor (Application Insights).
    
    This function sets up:
    - Traces (distributed tracing)
    - Metrics (performance counters, custom metrics)
    
    Args:
        service_name: Name of the service (e.g., "aca-devops-demo")
        service_version: Version of the service (e.g., "1.0.0")
        service_instance_id: Unique instance identifier (e.g., hostname, pod name)
    
    Returns:
        tuple: (tracer, meter) for creating custom spans and metrics
    """
    # Get Application Insights connection string from environment
    connection_string = os.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING")
    
    if not connection_string:
        logger.warning(
            "APPLICATIONINSIGHTS_CONNECTION_STRING not set. "
            "Telemetry will not be exported to Azure Monitor."
        )
        # Return no-op tracer and meter (won't export but won't crash)
        return trace.get_tracer(__name__), metrics.get_meter(__name__)
    
    # Configure resource attributes (metadata about the service)
    resource_attributes = {
        SERVICE_NAME: service_name,
        SERVICE_VERSION: service_version,
    }
    
    if service_instance_id:
        resource_attributes[SERVICE_INSTANCE_ID] = service_instance_id
    
    resource = Resource.create(resource_attributes)
    
    try:
        # Configure Tracing
        trace_exporter = AzureMonitorTraceExporter(connection_string=connection_string)
        span_processor = BatchSpanProcessor(trace_exporter)
        tracer_provider = TracerProvider(resource=resource)
        tracer_provider.add_span_processor(span_processor)
        trace.set_tracer_provider(tracer_provider)
        
        # Configure Metrics
        metric_exporter = AzureMonitorMetricExporter(connection_string=connection_string)
        metric_reader = PeriodicExportingMetricReader(
            metric_exporter,
            export_interval_millis=60000,  # Export every 60 seconds
        )
        meter_provider = MeterProvider(
            resource=resource,
            metric_readers=[metric_reader],
        )
        metrics.set_meter_provider(meter_provider)
        
        logger.info(
            f"✅ OpenTelemetry configured for Azure Monitor: "
            f"service={service_name}, version={service_version}"
        )
        
    except Exception as e:
        logger.error(f"❌ Failed to configure Azure Monitor: {e}")
        # Continue without telemetry rather than crashing
    
    # Get tracer and meter for custom instrumentation
    tracer = trace.get_tracer(__name__, service_version)
    meter = metrics.get_meter(__name__, service_version)
    
    return tracer, meter


def create_custom_metrics(meter: metrics.Meter) -> dict:
    """
    Create custom metrics for business/application-specific measurements.
    
    Args:
        meter: OpenTelemetry meter instance
    
    Returns:
        dict: Dictionary of metric instruments
    """
    return {
        # Counter: Monotonically increasing value (e.g., total requests, errors)
        "items_created": meter.create_counter(
            name="app.items.created",
            description="Number of items created",
            unit="1",
        ),
        "items_deleted": meter.create_counter(
            name="app.items.deleted",
            description="Number of items deleted",
            unit="1",
        ),
        
        # Histogram: Distribution of values (e.g., request duration, payload size)
        "item_name_length": meter.create_histogram(
            name="app.item.name.length",
            description="Distribution of item name lengths",
            unit="characters",
        ),
        
        # UpDownCounter: Value that can increase or decrease (e.g., active connections, queue size)
        "items_in_db": meter.create_up_down_counter(
            name="app.items.count",
            description="Current number of items in database",
            unit="1",
        ),
    }
