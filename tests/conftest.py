"""
Pytest configuration and shared fixtures for all tests.

This module provides:
- Shared fixtures for TestClient setup
- Database reset fixtures
- Async event loop configuration
- Test markers configuration
"""
import os
import pytest
from typing import Generator
from fastapi.testclient import TestClient

# Set test environment before importing app
os.environ["ENVIRONMENT"] = "test"
os.environ["APP_NAME"] = "ACA DevOps Demo - Test"


@pytest.fixture(scope="session")
def app():
    """
    Create the FastAPI app instance for testing.
    Session-scoped to avoid recreating the app for each test.
    """
    from app.main import app as fastapi_app
    return fastapi_app


@pytest.fixture
def client(app) -> Generator[TestClient, None, None]:
    """
    Create a test client for each test.
    
    This fixture provides a fresh TestClient instance for each test,
    ensuring isolation between tests.
    """
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture(autouse=True)
def reset_items_db():
    """
    Reset the in-memory items database before each test.
    
    This ensures test isolation by clearing all items
    created during previous tests.
    """
    from app.main import items_db
    items_db.clear()
    yield
    # Cleanup after test (if needed)
    items_db.clear()


@pytest.fixture
def sample_item() -> dict:
    """Fixture providing a sample item data for testing."""
    return {
        "name": "Test Product",
        "description": "A sample product for testing",
        "price": 29.99,
        "quantity": 10
    }


@pytest.fixture
def sample_items() -> list[dict]:
    """Fixture providing multiple sample items for testing."""
    return [
        {"name": "Item A", "description": "First item", "price": 10.00, "quantity": 5},
        {"name": "Item B", "description": "Second item", "price": 20.00, "quantity": 3},
        {"name": "Item C", "description": "Third item", "price": 30.00, "quantity": 1},
    ]


@pytest.fixture
def created_item(client, sample_item) -> dict:
    """
    Fixture that creates an item and returns the response.
    
    Useful for tests that need a pre-existing item in the database.
    """
    response = client.post("/items", json=sample_item)
    assert response.status_code == 201
    return response.json()


@pytest.fixture
def created_items(client, sample_items) -> list[dict]:
    """
    Fixture that creates multiple items and returns the responses.
    
    Useful for tests that need multiple pre-existing items.
    """
    created = []
    for item in sample_items:
        response = client.post("/items", json=item)
        assert response.status_code == 201
        created.append(response.json())
    return created


# =============================================================================
# Test Markers Configuration
# =============================================================================
def pytest_configure(config):
    """Register custom markers."""
    config.addinivalue_line(
        "markers", "unit: mark test as a unit test"
    )
    config.addinivalue_line(
        "markers", "integration: mark test as an integration test"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )
