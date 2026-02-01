"""
Pydantic models for API request/response schemas.
"""
from pydantic import BaseModel, Field
from datetime import datetime


class HealthResponse(BaseModel):
    """Health check response model."""
    status: str = Field(default="healthy", description="Health status of the application")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="Current UTC timestamp")


class InfoResponse(BaseModel):
    """Application info response model."""
    app_name: str = Field(description="Application name")
    version: str = Field(description="Application version")
    environment: str = Field(description="Deployment environment (dev/prod)")
    hostname: str | None = Field(default=None, description="Container hostname")
    container_app_name: str | None = Field(default=None, description="Azure Container App name")
    container_app_revision: str | None = Field(default=None, description="Azure Container App revision")
    replica_name: str | None = Field(default=None, description="Azure Container App replica name")


class WelcomeResponse(BaseModel):
    """Welcome message response model."""
    message: str = Field(description="Welcome message")
    docs_url: str = Field(description="URL to API documentation")


class ItemCreate(BaseModel):
    """Model for creating an item (demo POST endpoint)."""
    name: str = Field(min_length=1, max_length=100, description="Item name")
    description: str | None = Field(default=None, max_length=500, description="Item description")
    price: float = Field(gt=0, description="Item price (must be greater than 0)")
    quantity: int = Field(ge=0, default=1, description="Item quantity")


class ItemResponse(BaseModel):
    """Model for item response."""
    id: int = Field(description="Item ID")
    name: str = Field(description="Item name")
    description: str | None = Field(description="Item description")
    price: float = Field(description="Item price")
    quantity: int = Field(description="Item quantity")
    total_value: float = Field(description="Total value (price * quantity)")


class ErrorResponse(BaseModel):
    """Standard error response model."""
    error: str = Field(description="Error type")
    message: str = Field(description="Error message")
    detail: str | None = Field(default=None, description="Additional error details")
