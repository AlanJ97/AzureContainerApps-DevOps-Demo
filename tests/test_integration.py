"""
Integration Tests for the FastAPI Application.

These tests verify the application behavior in realistic scenarios,
testing complete user workflows and API interactions.

Integration tests differ from unit tests by:
- Testing complete request/response cycles
- Verifying data persistence across operations
- Testing error handling and edge cases
- Validating business logic workflows
"""
import pytest


@pytest.mark.integration
class TestItemsWorkflow:
    """
    Integration tests for the complete items CRUD workflow.
    
    Tests realistic user scenarios from creating items
    through updating, listing, and deleting them.
    """
    
    def test_complete_item_lifecycle(self, client):
        """Test the complete lifecycle of an item: create → read → delete."""
        # 1. Create an item
        item_data = {
            "name": "Lifecycle Test Item",
            "description": "Testing the full item lifecycle",
            "price": 49.99,
            "quantity": 5
        }
        create_response = client.post("/items", json=item_data)
        assert create_response.status_code == 201
        created_item = create_response.json()
        item_id = created_item["id"]
        
        # Verify created item has correct data
        assert created_item["name"] == item_data["name"]
        assert created_item["total_value"] == item_data["price"] * item_data["quantity"]
        
        # 2. Read the item back
        get_response = client.get(f"/items/{item_id}")
        assert get_response.status_code == 200
        fetched_item = get_response.json()
        assert fetched_item == created_item
        
        # 3. Verify item appears in list
        list_response = client.get("/items")
        assert list_response.status_code == 200
        items = list_response.json()
        assert any(item["id"] == item_id for item in items)
        
        # 4. Delete the item
        delete_response = client.delete(f"/items/{item_id}")
        assert delete_response.status_code == 204
        
        # 5. Verify item is gone
        get_deleted_response = client.get(f"/items/{item_id}")
        assert get_deleted_response.status_code == 404
    
    def test_bulk_operations(self, client, sample_items):
        """Test creating and managing multiple items."""
        created_ids = []
        
        # Create multiple items
        for item_data in sample_items:
            response = client.post("/items", json=item_data)
            assert response.status_code == 201
            created_ids.append(response.json()["id"])
        
        # Verify all items exist
        list_response = client.get("/items")
        assert list_response.status_code == 200
        items = list_response.json()
        assert len(items) == len(sample_items)
        
        # Delete all items
        for item_id in created_ids:
            delete_response = client.delete(f"/items/{item_id}")
            assert delete_response.status_code == 204
        
        # Verify database is empty
        empty_response = client.get("/items")
        assert empty_response.status_code == 200
        assert empty_response.json() == []
    
    def test_pagination_workflow(self, client):
        """Test pagination works correctly with real data."""
        # Create 10 items
        for i in range(10):
            client.post("/items", json={"name": f"Item {i:02d}", "price": 10.0 + i})
        
        # Test different pagination scenarios
        # Page 1: items 0-4
        page1 = client.get("/items?skip=0&limit=5")
        assert page1.status_code == 200
        assert len(page1.json()) == 5
        
        # Page 2: items 5-9
        page2 = client.get("/items?skip=5&limit=5")
        assert page2.status_code == 200
        assert len(page2.json()) == 5
        
        # Page 3: should be empty
        page3 = client.get("/items?skip=10&limit=5")
        assert page3.status_code == 200
        assert len(page3.json()) == 0
        
        # Verify no overlap between pages
        page1_ids = {item["id"] for item in page1.json()}
        page2_ids = {item["id"] for item in page2.json()}
        assert page1_ids.isdisjoint(page2_ids)


@pytest.mark.integration
class TestHealthEndpointsIntegration:
    """Integration tests for health check endpoints in various scenarios."""
    
    def test_all_health_endpoints_respond(self, client):
        """Verify all health endpoints respond correctly."""
        endpoints = [
            ("/health", "healthy"),
            ("/health/ready", "ready"),
            ("/health/live", "alive"),
        ]
        
        for endpoint, expected_status in endpoints:
            response = client.get(endpoint)
            assert response.status_code == 200, f"Endpoint {endpoint} failed"
            assert response.json()["status"] == expected_status
    
    def test_health_endpoints_under_load(self, client):
        """Test health endpoints respond consistently under repeated requests."""
        for _ in range(50):
            response = client.get("/health")
            assert response.status_code == 200
            assert response.json()["status"] == "healthy"


@pytest.mark.integration
class TestErrorHandling:
    """Integration tests for error handling scenarios."""
    
    def test_not_found_errors(self, client):
        """Test 404 errors are handled correctly."""
        # Non-existent item
        response = client.get("/items/99999")
        assert response.status_code == 404
        assert "detail" in response.json()
        
        # Non-existent endpoint
        response = client.get("/nonexistent")
        assert response.status_code == 404
    
    def test_validation_errors(self, client):
        """Test validation errors return proper responses."""
        invalid_items = [
            {"price": 10.0},  # Missing required 'name'
            {"name": "", "price": 10.0},  # Empty name
            {"name": "Test", "price": -1},  # Negative price
            {"name": "Test", "price": 10.0, "quantity": -5},  # Negative quantity
        ]
        
        for invalid_item in invalid_items:
            response = client.post("/items", json=invalid_item)
            assert response.status_code == 422, f"Expected 422 for {invalid_item}"
    
    def test_method_not_allowed(self, client):
        """Test that unsupported HTTP methods return 405."""
        # PUT on root endpoint (not supported)
        response = client.put("/")
        assert response.status_code == 405
    
    def test_double_delete(self, client, created_item):
        """Test that deleting an already deleted item returns 404."""
        item_id = created_item["id"]
        
        # First delete should succeed
        response1 = client.delete(f"/items/{item_id}")
        assert response1.status_code == 204
        
        # Second delete should return 404
        response2 = client.delete(f"/items/{item_id}")
        assert response2.status_code == 404


@pytest.mark.integration
class TestAPIDocumentation:
    """Integration tests for API documentation endpoints."""
    
    def test_openapi_schema_completeness(self, client):
        """Test that OpenAPI schema contains all expected endpoints."""
        response = client.get("/openapi.json")
        assert response.status_code == 200
        
        schema = response.json()
        paths = schema.get("paths", {})
        
        # Verify essential endpoints are documented
        expected_paths = ["/", "/health", "/health/ready", "/health/live", "/info", "/items"]
        for path in expected_paths:
            assert path in paths, f"Missing path: {path}"
    
    def test_docs_endpoints_accessible(self, client):
        """Test that documentation UIs are accessible."""
        # Swagger UI
        swagger_response = client.get("/docs")
        assert swagger_response.status_code == 200
        
        # ReDoc
        redoc_response = client.get("/redoc")
        assert redoc_response.status_code == 200


@pytest.mark.integration
class TestDataIntegrity:
    """Integration tests for data integrity and consistency."""
    
    def test_item_total_value_calculation(self, client):
        """Test that total_value is calculated correctly."""
        test_cases = [
            {"name": "Test", "price": 10.00, "quantity": 1, "expected_total": 10.00},
            {"name": "Test", "price": 25.50, "quantity": 4, "expected_total": 102.00},
            {"name": "Test", "price": 0.01, "quantity": 100, "expected_total": 1.00},
        ]
        
        for case in test_cases:
            item_data = {
                "name": case["name"],
                "price": case["price"],
                "quantity": case["quantity"]
            }
            response = client.post("/items", json=item_data)
            assert response.status_code == 201
            assert response.json()["total_value"] == case["expected_total"]
    
    def test_item_default_values(self, client):
        """Test that default values are applied correctly."""
        # Create item with minimal data
        response = client.post("/items", json={"name": "Minimal", "price": 5.00})
        assert response.status_code == 201
        
        item = response.json()
        assert item["description"] is None  # Optional field
        assert item["quantity"] == 1  # Default value
        assert item["total_value"] == 5.00  # price * default quantity
    
    def test_item_ids_are_unique(self, client, sample_items):
        """Test that each created item gets a unique ID."""
        ids = set()
        
        for item_data in sample_items:
            response = client.post("/items", json=item_data)
            assert response.status_code == 201
            item_id = response.json()["id"]
            assert item_id not in ids, f"Duplicate ID: {item_id}"
            ids.add(item_id)
