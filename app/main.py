"""
Azure Container Apps DevOps Demo - FastAPI Application

A professional but simple FastAPI application demonstrating:
- Health endpoints for Azure Container Apps probes
- Environment-based configuration (12-Factor App)
- Pydantic models for request/response validation
- Graceful shutdown handling (SIGTERM)
- OpenAPI documentation
- OpenTelemetry observability (traces, metrics, logs)
"""
import signal
import socket
import sys
from contextlib import asynccontextmanager
from datetime import datetime
from typing import Annotated

from fastapi import FastAPI, Path, Query, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

from app.config import get_settings
from app.models import (
    HealthResponse,
    InfoResponse,
    WelcomeResponse,
    ItemCreate,
    ItemResponse,
    ErrorResponse,
)
from app.telemetry import configure_telemetry, create_custom_metrics


# In-memory storage for demo purposes
items_db: dict[int, dict] = {}
item_id_counter = 0

# Graceful shutdown flag
shutdown_event = False

# OpenTelemetry instrumentation
tracer = None
meter = None
custom_metrics = None


def handle_sigterm(signum, frame):
    """
    Handle SIGTERM signal for graceful shutdown.
    Azure Container Apps sends SIGTERM before stopping containers.
    """
    global shutdown_event
    print("Received SIGTERM signal. Starting graceful shutdown...")
    shutdown_event = True
    # Give time for in-flight requests to complete
    sys.exit(0)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan context manager for startup and shutdown events.
    """
    global tracer, meter, custom_metrics
    
    # Startup
    settings = get_settings()
    print(f"🚀 Starting {settings.app_name} v{settings.app_version}")
    print(f"📍 Environment: {settings.environment}")
    
    # Configure OpenTelemetry
    tracer, meter = configure_telemetry(
        service_name=settings.app_name,
        service_version=settings.app_version,
        service_instance_id=socket.gethostname(),
    )
    
    # Create custom metrics
    custom_metrics = create_custom_metrics(meter)
    print("📊 OpenTelemetry instrumentation configured")
    
    # Register SIGTERM handler for graceful shutdown
    # Note: signal.signal() only works in the main thread, so we catch
    # ValueError when running in test environments (TestClient uses threads)
    try:
        signal.signal(signal.SIGTERM, handle_sigterm)
    except ValueError:
        # Not in main thread (e.g., during testing) - skip signal handler
        pass
    
    yield
    
    # Shutdown
    print("👋 Application shutting down gracefully...")


# Initialize FastAPI app
settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    description="Azure Container Apps DevOps Demo API - A professional demo showcasing CI/CD, IaC, and cloud-native practices.",
    version=settings.app_version,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan,
)

# Auto-instrument FastAPI with OpenTelemetry
# This automatically creates spans for all HTTP requests
FastAPIInstrumentor.instrument_app(app)

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =============================================================================
# Health & Info Endpoints (Required for Azure Container Apps)
# =============================================================================

@app.get(
    "/health",
    response_model=HealthResponse,
    tags=["Health"],
    summary="Health check endpoint",
    description="Returns the health status of the application. Used by Azure Container Apps for liveness and readiness probes.",
)
async def health_check() -> HealthResponse:
    """
    Health check endpoint for Azure Container Apps probes.
    
    Returns:
        HealthResponse: Current health status and timestamp
    """
    return HealthResponse(
        status="healthy",
        timestamp=datetime.utcnow()
    )


@app.get(
    "/health/ready",
    response_model=HealthResponse,
    tags=["Health"],
    summary="Readiness probe endpoint",
    description="Indicates if the application is ready to receive traffic.",
)
async def readiness_check() -> HealthResponse:
    """
    Readiness probe endpoint.
    
    In a real application, this would check dependencies (DB, cache, etc.)
    """
    if shutdown_event:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Application is shutting down"
        )
    return HealthResponse(
        status="ready",
        timestamp=datetime.utcnow()
    )


@app.get(
    "/health/live",
    response_model=HealthResponse,
    tags=["Health"],
    summary="Liveness probe endpoint",
    description="Indicates if the application is alive and running.",
)
async def liveness_check() -> HealthResponse:
    """
    Liveness probe endpoint.
    
    Returns healthy as long as the app is running.
    """
    return HealthResponse(
        status="alive",
        timestamp=datetime.utcnow()
    )


@app.get(
    "/info",
    response_model=InfoResponse,
    tags=["Info"],
    summary="Application information",
    description="Returns detailed information about the application and its runtime environment.",
)
async def get_info() -> InfoResponse:
    """
    Returns application information including environment and container details.
    
    Demonstrates:
    - Reading environment variables at runtime (12-Factor)
    - Azure Container Apps metadata injection
    """
    config = get_settings()
    
    return InfoResponse(
        app_name=config.app_name,
        version=config.app_version,
        environment=config.environment,
        hostname=socket.gethostname(),
        container_app_name=config.container_app_name,
        container_app_revision=config.container_app_revision,
        replica_name=config.container_app_replica_name,
    )


# =============================================================================
# Root Endpoint
# =============================================================================

@app.get(
    "/",
    response_model=WelcomeResponse,
    tags=["Root"],
    summary="Welcome endpoint",
    description="Returns a welcome message and link to API documentation.",
)
async def root() -> WelcomeResponse:
    """
    Root endpoint with welcome message.
    """
    return WelcomeResponse(
        message=f"Welcome to {settings.app_name}! 🚀",
        docs_url="/docs"
    )


# =============================================================================
# Demo CRUD Endpoints (Items)
# =============================================================================

@app.post(
    "/items",
    response_model=ItemResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Items"],
    summary="Create a new item",
    description="Creates a new item in the in-memory store.",
    responses={
        201: {"description": "Item created successfully"},
        422: {"description": "Validation error", "model": ErrorResponse},
    },
)
async def create_item(item: ItemCreate) -> ItemResponse:
    """
    Create a new item.
    
    Demonstrates:
    - Request body validation with Pydantic
    - POST request handling
    - Auto-generated ID
    - Custom OpenTelemetry metrics
    """
    global item_id_counter
    item_id_counter += 1
    
    item_data = {
        "id": item_id_counter,
        "name": item.name,
        "description": item.description,
        "price": item.price,
        "quantity": item.quantity,
    }
    items_db[item_id_counter] = item_data
    
    # Custom metrics: Record item creation
    if custom_metrics:
        custom_metrics["items_created"].add(1, {"item_name": item.name})
        custom_metrics["item_name_length"].record(len(item.name))
        custom_metrics["items_in_db"].add(1)
    
    # Custom span attributes
    current_span = trace.get_current_span()
    if current_span:
        current_span.set_attribute("item.id", item_id_counter)
        current_span.set_attribute("item.name", item.name)
        current_span.set_attribute("item.price", float(item.price))
    
    return ItemResponse(
        **item_data,
        total_value=item.price * item.quantity
    )


@app.get(
    "/items",
    response_model=list[ItemResponse],
    tags=["Items"],
    summary="List all items",
    description="Returns a paginated list of all items.",
)
async def list_items(
    skip: Annotated[int, Query(ge=0, description="Number of items to skip")] = 0,
    limit: Annotated[int, Query(ge=1, le=100, description="Maximum number of items to return")] = 10,
) -> list[ItemResponse]:
    """
    List all items with pagination.
    
    Demonstrates:
    - Query parameter validation
    - Pagination pattern
    """
    items = list(items_db.values())[skip : skip + limit]
    return [
        ItemResponse(**item, total_value=item["price"] * item["quantity"])
        for item in items
    ]


@app.get(
    "/items/{item_id}",
    response_model=ItemResponse,
    tags=["Items"],
    summary="Get item by ID",
    description="Returns a specific item by its ID.",
    responses={
        200: {"description": "Item found"},
        404: {"description": "Item not found", "model": ErrorResponse},
    },
)
async def get_item(
    item_id: Annotated[int, Path(ge=1, description="The ID of the item to retrieve")]
) -> ItemResponse:
    """
    Get a specific item by ID.
    
    Demonstrates:
    - Path parameter validation
    - 404 error handling
    """
    if item_id not in items_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item with ID {item_id} not found"
        )
    
    item = items_db[item_id]
    return ItemResponse(
        **item,
        total_value=item["price"] * item["quantity"]
    )


@app.delete(
    "/items/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["Items"],
    summary="Delete an item",
    description="Deletes an item by its ID.",
    responses={
        204: {"description": "Item deleted successfully"},
        404: {"description": "Item not found", "model": ErrorResponse},
    },
)
async def delete_item(
    item_id: Annotated[int, Path(ge=1, description="The ID of the item to delete")]
) -> None:
    """
    Delete an item by ID.
    
    Demonstrates:
    - DELETE request handling
    - 204 No Content response
    - Custom OpenTelemetry metrics
    """
    if item_id not in items_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item with ID {item_id} not found"
        )
    
    # Get item name before deletion for metrics
    item_name = items_db[item_id].get("name", "unknown")
    
    del items_db[item_id]
    
    # Custom metrics: Record item deletion
    if custom_metrics:
        custom_metrics["items_deleted"].add(1, {"item_name": item_name})
        custom_metrics["items_in_db"].add(-1)
    
    # Custom span attribute
    current_span = trace.get_current_span()
    if current_span:
        current_span.set_attribute("item.id", item_id)
        current_span.set_attribute("item.deleted", True)


# =============================================================================
# Main Entry Point
# =============================================================================

if __name__ == "__main__":
    import uvicorn
    
    config = get_settings()
    uvicorn.run(
        "app.main:app",
        host=config.host,
        port=config.port,
        reload=config.debug,
    )
