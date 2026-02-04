# FastAPI Application

Production-ready FastAPI application with OpenTelemetry instrumentation, health checks, and comprehensive testing.

## 📁 Structure

```
app/
├── __init__.py              # Package marker
├── config.py                # Configuration management
├── main.py                  # FastAPI application & routes
├── models.py                # Pydantic data models
├── telemetry.py             # OpenTelemetry setup
└── .env.example             # Environment variables template
```

---

## 📄 Files

### `main.py` (410 lines)
**Purpose**: Core FastAPI application with REST API endpoints

**Features**:
- **Lifespan Management** - Startup/shutdown hooks for telemetry
- **Health Checks** - `/health`, `/health/live`, `/health/ready`
- **CRUD Operations** - Create, read, update, delete items
- **OpenAPI Docs** - Auto-generated at `/docs`
- **CORS Support** - Configured for cross-origin requests
- **Error Handling** - HTTP exceptions with proper status codes

**Endpoints**:
| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Welcome message |
| GET | `/health` | Health status + timestamp |
| GET | `/health/live` | Liveness probe |
| GET | `/health/ready` | Readiness probe |
| GET | `/info` | App metadata (name, version, environment) |
| GET | `/items` | List all items (paginated) |
| POST | `/items` | Create new item |
| GET | `/items/{id}` | Get item by ID |
| PUT | `/items/{id}` | Update item |
| DELETE | `/items/{id}` | Delete item |

**OpenTelemetry Integration**:
- Automatic FastAPI instrumentation
- Custom metrics for CRUD operations
- Distributed tracing support

### `telemetry.py` (141 lines)
**Purpose**: OpenTelemetry configuration for Azure Monitor

**Components**:
- **Trace Exporter** - Sends traces to Application Insights
- **Metric Exporter** - Sends metrics to Application Insights
- **Resource Attributes** - Service name, version, instance ID

**Custom Metrics**:
```python
items_created        # Counter - total items created
items_deleted        # Counter - total items deleted
item_name_length     # Histogram - distribution of name lengths
items_in_db          # UpDownCounter - current database size
```

**Configuration**:
- Reads `APPLICATIONINSIGHTS_CONNECTION_STRING` from environment
- Gracefully degrades if connection string unavailable
- 60-second export interval for metrics

### `models.py` (50 lines)
**Purpose**: Pydantic models for request/response validation

**Models**:
```python
ItemBase        # Base schema with name, description, price
ItemCreate      # For POST requests
ItemUpdate      # For PUT requests (all fields optional)
ItemResponse    # For GET responses (includes id)
ItemsListResponse  # Paginated list response
```

**Validation**:
- Name: 1-100 characters
- Description: Optional, max 500 characters
- Price: Positive decimal number

### `config.py` (40 lines)
**Purpose**: Centralized configuration using Pydantic Settings

**Environment Variables**:
```python
APP_NAME                                # Default: "aca-devops-demo"
APP_VERSION                             # Default: "1.0.0"
ENVIRONMENT                             # Default: "development"
LOG_LEVEL                               # Default: "INFO"
APPLICATIONINSIGHTS_CONNECTION_STRING   # Optional: App Insights
```

**Features**:
- Loads from `.env` file
- Type validation
- Default values
- Case-insensitive environment variables

### `.env.example`
Template for environment variables:
```bash
APP_NAME=aca-devops-demo
APP_VERSION=1.0.0
ENVIRONMENT=development
LOG_LEVEL=DEBUG
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...
```

---

## 🚀 Local Development

### Prerequisites
- Python 3.11+
- pip or poetry

### Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
.\venv\Scripts\Activate   # Windows

# Install dependencies
pip install -r requirements.txt

# For development (includes testing tools)
pip install -r requirements-dev.txt

# Copy environment template
cp app/.env.example app/.env

# Edit .env with your values (optional)
# Leave APPLICATIONINSIGHTS_CONNECTION_STRING blank for local dev
```

### Run Application

```bash
# Development mode with auto-reload
uvicorn app.main:app --reload --port 8000

# Production mode
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

**Access**:
- API: http://localhost:8000
- OpenAPI Docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Run with Docker

```bash
# Build image
docker build -t aca-demo .

# Run container
docker run -p 8000:8000 \
  -e ENVIRONMENT=local \
  -e LOG_LEVEL=DEBUG \
  aca-demo
```

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
pytest tests/ -v

# With coverage report
pytest tests/ --cov=app --cov-report=html --cov-report=term

# Run specific test file
pytest tests/test_main.py -v

# Run specific test
pytest tests/test_main.py::test_root -v
```

### Coverage Report
```bash
# Generate HTML coverage report
pytest --cov=app --cov-report=html

# Open in browser
open htmlcov/index.html  # Mac
xdg-open htmlcov/index.html  # Linux
start htmlcov/index.html  # Windows
```

**Current Coverage**: 95%+ (see `htmlcov/` after running)

### Test Structure
```
tests/
├── __init__.py
└── test_main.py          # API endpoint tests
    ├── test_root()
    ├── test_health()
    ├── test_create_item()
    ├── test_get_items()
    ├── test_get_item()
    ├── test_update_item()
    ├── test_delete_item()
    └── ... (18 total tests)
```

---

## 📊 OpenTelemetry Metrics

### Automatic Metrics
FastAPI instrumentation provides:
- HTTP request count
- Request duration
- Response status codes
- Active requests

### Custom Metrics

**Items Created**:
```python
metrics["items_created"].add(1)
```
Increments on successful POST to `/items`

**Items Deleted**:
```python
metrics["items_deleted"].add(1)
```
Increments on successful DELETE to `/items/{id}`

**Item Name Length**:
```python
metrics["item_name_length"].record(len(item.name))
```
Records distribution of name lengths

**Items in Database**:
```python
metrics["items_in_db"].add(1)   # On create
metrics["items_in_db"].add(-1)  # On delete
```
Tracks current item count

### Viewing Metrics

**Local Development**: Metrics are created but not exported (no connection string)

**Production**: 
- View in Application Insights → Metrics Explorer
- Select namespace: `azure.applicationinsights`
- Metric names: `items_created`, `items_deleted`, etc.

---

## 🔧 Configuration

### Environment-Specific Settings

**Development** (`.env` file):
```bash
ENVIRONMENT=development
LOG_LEVEL=DEBUG
# No Application Insights
```

**Azure Container Apps** (set via Terraform):
```bash
ENVIRONMENT=dev|prod
LOG_LEVEL=INFO|DEBUG
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...
```

### Health Check Configuration

**Liveness Probe**: `/health/live`
- Initial delay: 10 seconds
- Interval: 30 seconds
- Timeout: 5 seconds
- Failure threshold: 3

**Readiness Probe**: `/health/ready`
- Interval: 10 seconds
- Timeout: 3 seconds
- Failure threshold: 3

**Startup Probe**: `/health`
- Interval: 10 seconds
- Timeout: 3 seconds
- Failure threshold: 30 (5 minutes total)

Configured in `terraform/modules/aca-stack/main.tf`

---

## 🔒 Security

### Input Validation
- **Pydantic Models** - Automatic validation and type checking
- **Length Limits** - Name max 100 chars, description max 500 chars
- **Type Safety** - Price must be positive decimal

### CORS Configuration
```python
origins = ["*"]  # Adjust for production
allow_credentials = True
allow_methods = ["*"]
allow_headers = ["*"]
```

**Production**: Restrict `origins` to specific domains

### Dependencies
- No known vulnerabilities (scanned with `bandit` in CI)
- Regular updates via Dependabot
- Security scanning in CI/CD pipeline

---

## 📦 Dependencies

### Production (`requirements.txt`)
```
fastapi==0.115.6
uvicorn[standard]==0.34.0
pydantic==2.10.4
pydantic-settings==2.7.1
python-dotenv==1.0.1
opentelemetry-api==1.39.0
opentelemetry-sdk==1.39.0
opentelemetry-semantic-conventions==0.60b0
opentelemetry-instrumentation-fastapi==0.60b0
azure-monitor-opentelemetry-exporter==1.0.0b47
```

### Development (`requirements-dev.txt`)
```
pytest==8.3.4
pytest-cov==6.0.0
httpx==0.28.1
flake8==7.1.1
bandit==1.8.0
```

---

## 🌐 API Examples

### Create Item
```bash
curl -X POST http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Example Item",
    "description": "Test item",
    "price": 19.99
  }'
```

### Get All Items
```bash
curl http://localhost:8000/items?skip=0&limit=10
```

### Get Item by ID
```bash
curl http://localhost:8000/items/1
```

### Update Item
```bash
curl -X PUT http://localhost:8000/items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Item",
    "price": 29.99
  }'
```

### Delete Item
```bash
curl -X DELETE http://localhost:8000/items/1
```

---

## 🐛 Troubleshooting

**App won't start**
- Check Python version (3.11+ required)
- Verify all dependencies installed: `pip install -r requirements.txt`
- Check port 8000 is not in use

**Tests failing**
- Ensure dev dependencies installed: `pip install -r requirements-dev.txt`
- Check you're in the project root directory
- Run: `pytest tests/ -v` for detailed output

**OpenTelemetry not working**
- Verify `APPLICATIONINSIGHTS_CONNECTION_STRING` is set
- Check connection string format is correct
- Logs will show "Connection string not set" warning if missing
- Telemetry is optional - app works without it

**404 errors**
- Check endpoint path is correct (e.g., `/items` not `/api/items`)
- View available routes at `/docs`

---

## 📚 Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [OpenTelemetry Python](https://opentelemetry.io/docs/languages/python/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [pytest Documentation](https://docs.pytest.org/)

---

*See also: [Project README](../README.md) | [CI/CD Workflows](../.github/workflows/README.md)*
