"""
Application configuration using environment variables.
Follows 12-Factor App methodology: configuration from environment.
"""
from functools import lru_cache
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Application Info
    app_name: str = "ACA DevOps Demo"
    app_version: str = "1.0.0"
    environment: str = "development"
    debug: bool = False
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8000
    
    # Azure Container Apps injects these automatically
    container_app_name: str | None = None
    container_app_revision: str | None = None
    container_app_replica_name: str | None = None
    
    # Application Insights (optional)
    applicationinsights_connection_string: str | None = None
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


@lru_cache
def get_settings() -> Settings:
    """
    Returns cached settings instance.
    Using lru_cache ensures settings are only loaded once.
    """
    return Settings()
