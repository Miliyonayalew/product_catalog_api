# Product Catalog API

A robust Rails API for managing products and categories with advanced features including filtering, pagination, and featuring functionality.

## 🚀 Features

- **RESTful API** with proper versioning (`/api/v1/`)
- **Product Management** - Full CRUD operations
- **Category Management** - Organize products by categories
- **Advanced Filtering** - Filter products by category
- **Pagination** - Efficient data pagination with metadata
- **Product Featuring** - Mark products as featured
- **Security** - Strong parameters, mass assignment protection
- **Performance** - N+1 query prevention, caching
- **Testing** - Comprehensive test suite with 47 tests
- **Documentation** - Interactive Swagger/OpenAPI documentation

## 📋 API Endpoints

### Products

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/products` | List all products with pagination |
| `GET` | `/api/v1/products/:id` | Get a specific product |
| `POST` | `/api/v1/products` | Create a new product |
| `PATCH/PUT` | `/api/v1/products/:id` | Update a product |
| `DELETE` | `/api/v1/products/:id` | Delete a product |
| `PATCH` | `/api/v1/products/:id/feature` | Mark product as featured |
| `PATCH` | `/api/v1/products/:id/unfeature` | Remove featured status |

### Categories

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/categories` | List all categories |
| `GET` | `/api/v1/categories/:id` | Get a specific category |
| `POST` | `/api/v1/categories` | Create a new category |
| `PATCH/PUT` | `/api/v1/categories/:id` | Update a category |
| `DELETE` | `/api/v1/categories/:id` | Delete a category |

## 🔧 Query Parameters

### Products Index (`GET /api/v1/products`)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `category_id` | Integer | - | Filter products by category ID |
| `page` | Integer | 1 | Page number for pagination |
| `per_page` | Integer | 25 | Items per page (max: 100) |

### Example Requests

```bash
# Get all products
curl http://localhost:3000/api/v1/products

# Filter by category
curl http://localhost:3000/api/v1/products?category_id=1

# Paginated results
curl http://localhost:3000/api/v1/products?page=2&per_page=10

# Combined filtering and pagination
curl http://localhost:3000/api/v1/products?category_id=1&page=1&per_page=5
```

## 📦 Response Format

### Products List Response

```json
{
  "products": [
    {
      "id": 1,
      "name": "Laptop Pro X",
      "description": "Powerful laptop for professionals",
      "price": "1200.0",
      "stock_quantity": 50,
      "category_id": 1,
      "category_name": "Electronics",
      "published_at": "2023-07-13T00:00:00.000Z",
      "is_featured": false,
      "is_admin": false
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 25,
    "next_page": 2,
    "prev_page": null
  }
}
```

### Feature/Unfeature Response

```json
{
  "message": "Product successfully featured",
  "product": {
    "id": 1,
    "name": "Laptop Pro X",
    "is_featured": true,
    "featured_at": "2023-07-13T12:00:00.000Z"
  }
}
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
- Eager loading (`eager_load = true`)
- Persistent caching (`solid_cache_store`)
- Structured logging with request IDs
- Background job processing (`solid_queue`)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Write tests for new features
- Follow Rails conventions
- Use strong parameters for all inputs
- Add proper error handling
- Update documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the [FAQ](docs/FAQ.md)
- Review the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

---

**Built with ❤️ using Rails 8.0.2**
