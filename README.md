# Product Catalog API

A robust Rails API for managing products and categories with advanced features including filtering, pagination, and featuring functionality.

## 🚀 Features

- **RESTful API** with proper versioning (`/api/v1/`)
- **Product Management** - Full CRUD operations
- **Category Management** - Organize products by categories
- **Advanced Filtering** - Filter products by category
- **Pagination** - Efficient data pagination with metadata
- **Product Featuring** - Mark products as featured (admin only)
- **Security** - Strong parameters, mass assignment protection, admin authorization
- **Performance** - N+1 query prevention, caching
- **Testing** - Comprehensive test suite with 47 tests
- **Documentation** - Interactive Swagger/OpenAPI documentation

## 🔐 Authorization

### Admin Endpoints
The following endpoints require admin authorization:
- `PATCH /api/v1/products/:id/feature` - Mark a product as featured
- `PATCH /api/v1/products/:id/unfeature` - Remove featured status from a product

### Authorization Methods
You can provide admin authorization in two ways:

1. **HTTP Header** (Recommended):
   ```bash
   curl -X PATCH \
     -H "X-Admin-Token: admin-secret-token" \
     http://localhost:3000/api/v1/products/1/feature
   ```

2. **Query Parameter**:
   ```bash
   curl -X PATCH \
     "http://localhost:3000/api/v1/products/1/feature?admin_token=admin-secret-token"
   ```

### Example Usage
```bash
# Feature a product
curl -X PATCH \
  -H "X-Admin-Token: admin-secret-token" \
  -H "Content-Type: application/json" \
  http://localhost:3000/api/v1/products/1/feature

# Unfeature a product
curl -X PATCH \
  -H "X-Admin-Token: admin-secret-token" \
  -H "Content-Type: application/json" \
  http://localhost:3000/api/v1/products/1/unfeature
```

## 🛠️ Setup & Installation

### Prerequisites

- Ruby 3.4.4
- Rails 8.0.2
- SQLite3 (development) / PostgreSQL (production)
- Docker (optional)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd product_catalog_api
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Run tests**
   ```bash
   rails test
   ```

### Docker Setup

1. **Build and start containers**
   ```bash
   docker-compose build
   docker-compose up -d
   ```

2. **Setup database in container**
   ```bash
   docker-compose run --rm web rails db:prepare db:seed
   ```

3. **Access the API**
   ```bash
   curl http://localhost:3000/api/v1/products
   ```

## 📚 API Documentation

### Interactive Swagger Documentation
- **Web Interface**: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
- **JSON Specification**: [http://localhost:3000/swagger/v1/swagger.json](http://localhost:3000/swagger/v1/swagger.json)

### Documentation Guides
- [Quick Start Guide](docs/QUICK_START.md) - Get started in 3 steps
- [API Documentation Guide](docs/API_DOCUMENTATION.md) - Comprehensive documentation

## 🧪 Testing

### Running Tests

```bash
# Run all tests
rails test

# Run specific test types
rails test test/models/
rails test test/controllers/

# Run specific test file
rails test test/controllers/api/v1/products_controller_test.rb

# Run specific test method
rails test test/models/product_test.rb -n test_should_require_name
```

### Test Coverage

- **47 tests, 141 assertions**
- **Model Tests**: 22 tests covering validations, associations, scopes
- **Controller Tests**: 25 tests covering API endpoints, filtering, pagination
- **Bug Fix Verification**: N+1 query prevention, mass assignment protection

## 🔒 Security Features

### Mass Assignment Protection
- Strong parameters prevent unauthorized attribute assignment
- `is_admin` attribute is protected from API manipulation

### Input Validation
- Product name is required
- Price and stock quantity must be non-negative
- Category associations are validated

### Error Handling
- Proper HTTP status codes
- Structured error responses
- No sensitive information exposure in production

## ⚡ Performance Optimizations

### N+1 Query Prevention
- Eager loading with `includes(:category)`
- Efficient category name retrieval
- Optimized database queries

### Caching
- HTTP-level caching headers
- Cache invalidation on updates
- Production-ready cache store configuration

### Pagination
- Efficient pagination with Kaminari gem
- Configurable page sizes (max 100 items)
- Pagination metadata in responses

## 🏗️ Architecture

### Models

#### Product
- `belongs_to :category` (optional)
- Validations for name, price, stock_quantity
- Scopes: `by_category`, `featured`, `published`, `in_stock`
- Methods: `category_name`, `is_featured?`

#### Category
- `has_many :products`
- Validations for name uniqueness
- Foreign key constraints

### Controllers

#### Api::V1::ProductsController
- RESTful CRUD operations
- Custom actions: `feature`, `unfeature`
- Strong parameter protection
- Error handling and status codes

#### Api::V1::CategoriesController
- Standard CRUD operations
- Proper error handling

## 🔧 Configuration

### Environment Variables

```bash
RAILS_ENV=production
RAILS_LOG_LEVEL=info
DATABASE_URL=postgresql://...
```

### Production Settings

- SSL enforcement (`force_ssl = true`)
- Eager loading (`