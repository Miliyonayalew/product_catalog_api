# Product Catalog API

A robust Rails API for managing products and categories with advanced features including filtering, pagination, and featuring functionality.

## 🚀 Features

- **RESTful API** with proper versioning (`/api/v1/`)
- **Product Management** - Full CRUD operations with comprehensive error handling
- **Category Management** - Organize products by categories
- **Advanced Filtering** - Filter products by category with validation
- **Pagination** - Efficient data pagination with metadata (1-100 items per page)
- **Product Featuring** - Mark products as featured (admin only)
- **Security** - Strong parameters, mass assignment protection, admin authorization
- **Performance** - N+1 query prevention, HTTP caching, cache invalidation
- **Testing** - Comprehensive test suite with 64 tests covering all scenarios
- **Documentation** - Interactive Swagger/OpenAPI documentation
- **Error Handling** - Detailed error responses with proper HTTP status codes

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
# Run all tests (64 tests)
rails test

# Run specific test types
rails test test/models/
rails test test/controllers/

# Run specific test file
rails test test/controllers/api/v1/products_controller_test.rb
```

### Test Coverage
- **64 total tests** passing
- **36 controller tests** with comprehensive coverage
- **Error handling tests** for all edge cases
- **Authorization tests** for admin endpoints
- **N+1 query prevention tests**
- **Cache invalidation tests**
- **Strong parameters security tests**




## ⚠️ Error Handling

The API provides comprehensive error handling with consistent response formats:

### Error Response Format
```json
{
  "error": "Error type",
  "message": "Detailed error message"
}
```

### Common Error Codes
- **400 Bad Request**: Invalid parameters (category_id, pagination)
- **403 Forbidden**: Missing or invalid admin token for feature/unfeature
- **404 Not Found**: Resource not found
- **422 Unprocessable Entity**: Validation errors

### Validation Error Format
```json
{
  "error": "Validation failed",
  "errors": ["Name can't be blank", "Price must be greater than 0"]
}
```

## 🚀 Performance Features

### N+1 Query Prevention
- Eager loading with `Product.includes(:category)`
- Optimized JSON serialization using eager loaded associations
- Bullet gem integration for query optimization

### Caching Strategy
- HTTP-level caching with `ETag` and `Cache-Control` headers
- Cache invalidation on product updates, deletes, and featuring
- 1-hour cache duration for product details

### Database Optimization
- Proper database indexes
- Efficient pagination with Kaminari gem
- Optimized queries with ActiveRecord scopes

## 🔒 Security Features

### Strong Parameters
- Prevents mass assignment vulnerabilities
- Explicitly permits only safe attributes
- Excludes sensitive fields like `is_admin`

### Authorization
- Admin token validation for sensitive operations
- Multiple authorization methods (header/parameter)
- Proper HTTP status codes for unauthorized access

### Input Validation
- Comprehensive parameter validation
- Type checking for all inputs
- Range validation for pagination parameters

## 🏗️ Architecture

### Models
- **Product**: Core product entity with associations and scopes
- **Category**: Category management with product relationships

### Controllers
- **API Versioning**: Namespaced under `/api/v1/`
- **Error Handling**: Comprehensive exception handling
- **Response Formatting**: Consistent JSON responses

### Database
- **SQLite**: Development database
- **Migrations**: Proper schema management
- **Seeds**: Sample data for development

## 🚀 Deployment

### Production Considerations
- **Environment Configuration**: Production-specific settings
- **Database**: PostgreSQL for production
- **Caching**: Redis for production caching
- **SSL**: Force SSL in production
- **Logging**: Structured logging with request IDs

### Environment Variables
```bash
RAILS_ENV=production
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
RAILS_LOG_LEVEL=info
```

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
