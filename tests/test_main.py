"""
Unit Tests for the FastAPI application endpoints.

These tests focus on individual endpoint functionality
with isolated test cases for each feature.
"""
import pytest


@pytest.mark.unit
class TestHealthEndpoints:
    """Tests for health check endpoints."""
    
    @pytest.mark.smoke
    def test_health_check(self, client):
        """Test the main health endpoint."""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "timestamp" in data
    
    @pytest.mark.smoke
    def test_readiness_check(self, client):
        """Test the readiness probe endpoint."""
        response = client.get("/health/ready")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ready"
    
    @pytest.mark.smoke
    def test_liveness_check(self, client):
        """Test the liveness probe endpoint."""
        response = client.get("/health/live")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "alive"


@pytest.mark.unit
class TestInfoEndpoint:
    """Tests for the info endpoint."""
    
    @pytest.mark.smoke
    def test_get_info(self, client):
        """Test the application info endpoint."""
        response = client.get("/info")
        assert response.status_code == 200
        data = response.json()
        assert "app_name" in data
        assert "version" in data
        assert "environment" in data
        assert "hostname" in data


@pytest.mark.unit
class TestRootEndpoint:
    """Tests for the root endpoint."""
    
    @pytest.mark.smoke
    def test_root(self, client):
        """Test the root welcome endpoint."""
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "docs_url" in data
        assert data["docs_url"] == "/docs"


@pytest.mark.unit
class TestItemsEndpoints:
    """Tests for the items CRUD endpoints."""
    
    @pytest.mark.smoke
    def test_create_item(self, client):
        """Test creating a new item."""
        item_data = {
            "name": "Test Item",
            "description": "A test item",
            "price": 29.99,
            "quantity": 5
        }
        response = client.post("/items", json=item_data)
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == item_data["name"]
        assert data["description"] == item_data["description"]
        assert data["price"] == item_data["price"]
        assert data["quantity"] == item_data["quantity"]
        assert data["total_value"] == item_data["price"] * item_data["quantity"]
        assert "id" in data
    
    def test_create_item_minimal(self, client):
        """Test creating an item with minimal required fields."""
        item_data = {
            "name": "Minimal Item",
            "price": 9.99
        }
        response = client.post("/items", json=item_data)
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == item_data["name"]
        assert data["description"] is None
        assert data["quantity"] == 1  # default value
    
    def test_create_item_validation_error(self, client):
        """Test validation error when creating invalid item."""
        item_data = {
            "name": "",  # Empty name should fail
            "price": -10  # Negative price should fail
        }
        response = client.post("/items", json=item_data)
        assert response.status_code == 422
    
    def test_list_items_empty(self, client):
        """Test listing items when database is empty."""
        response = client.get("/items")
        assert response.status_code == 200
        assert response.json() == []
    
    def test_list_items_with_data(self, client):
        """Test listing items with data."""
        # Create some items first
        for i in range(3):
            client.post("/items", json={"name": f"Item {i}", "price": 10.0 + i})
        
        response = client.get("/items")
        assert response.status_code == 200
        items = response.json()
        assert len(items) == 3
    
    def test_list_items_pagination(self, client):
        """Test pagination in list items."""
        # Create 5 items
        for i in range(5):
            client.post("/items", json={"name": f"Item {i}", "price": 10.0})
        
        # Get first 2 items
        response = client.get("/items?skip=0&limit=2")
        assert response.status_code == 200
        assert len(response.json()) == 2
        
        # Skip first 2, get next 2
        response = client.get("/items?skip=2&limit=2")
        assert response.status_code == 200
        assert len(response.json()) == 2
    
    def test_get_item(self, client):
        """Test getting a specific item."""
        # Create an item first
        create_response = client.post(
            "/items", 
            json={"name": "Test Item", "price": 15.0}
        )
        item_id = create_response.json()["id"]
        
        # Get the item
        response = client.get(f"/items/{item_id}")
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == item_id
        assert data["name"] == "Test Item"
    
    def test_get_item_not_found(self, client):
        """Test getting a non-existent item."""
        response = client.get("/items/99999")
        assert response.status_code == 404
    
    def test_delete_item(self, client):
        """Test deleting an item."""
        # Create an item first
        create_response = client.post(
            "/items",
            json={"name": "To Delete", "price": 5.0}
        )
        item_id = create_response.json()["id"]
        
        # Delete the item
        response = client.delete(f"/items/{item_id}")
        assert response.status_code == 204
        
        # Verify it's deleted
        response = client.get(f"/items/{item_id}")
        assert response.status_code == 404
    
    def test_delete_item_not_found(self, client):
        """Test deleting a non-existent item."""
        response = client.delete("/items/99999")
        assert response.status_code == 404


@pytest.mark.unit
class TestOpenAPI:
    """Tests for OpenAPI documentation."""
    
    def test_openapi_schema(self, client):
        """Test that OpenAPI schema is accessible."""
        response = client.get("/openapi.json")
        assert response.status_code == 200
        schema = response.json()
        assert "openapi" in schema
        assert "info" in schema
        assert "paths" in schema
    
    def test_docs_available(self, client):
        """Test that Swagger UI is accessible."""
        response = client.get("/docs")
        assert response.status_code == 200
    
    def test_redoc_available(self, client):
        """Test that ReDoc is accessible."""
        response = client.get("/redoc")
        assert response.status_code == 200
