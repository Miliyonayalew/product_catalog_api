# API Documentation Guide

## Overview

The Product Catalog API provides comprehensive documentation using Swagger/OpenAPI 3.0.1 specification. This documentation is automatically generated and provides an interactive interface for testing API endpoints.

## Accessing the Documentation

### Web Interface
- **URL**: `http://localhost:3000/api-docs`
- **Description**: Interactive Swagger UI interface for exploring and testing API endpoints

### JSON Specification
- **URL**: `http://localhost:3000/swagger/v1/swagger.json`
- **Description**: Raw OpenAPI 3.0.1 JSON specification

## Features

### Interactive Documentation
- **Try It Out**: Test API endpoints directly from the documentation
- **Request/Response Examples**: See real examples for each endpoint
- **Parameter Validation**: Automatic validation of request parameters
- **Response Schemas**: Detailed response structure documentation

### API Endpoints Covered

#### Products
- `GET /api/v1/products` - List products with pagination and filtering
- `POST /api/v1/products` - Create a new product
- `GET /api/v1/products/{id}` - Get a specific product
- `PATCH /api/v1/products/{id}` - Update a product
- `DELETE /api/v1/products/{id}` - Delete a product
- `PATCH /api/v1/products/{id}/feature` - Mark product as featured
- `PATCH /api/v1/products/{id}/unfeature` - Remove featured status

#### Categories
- `GET /api/v1/categories` - List all categories
- `POST /api/v1/categories` - Create a new category
- `GET /api/v1/categories/{id}` - Get a specific category
- `PATCH /api/v1/categories/{id}` - Update a category
- `DELETE /api/v1/categories/{id}` - Delete a category

## Using the Swagger UI

### 1. Navigate to the Documentation
Open your browser and go to `http://localhost:3000/api-docs`

### 2. Explore Endpoints
- Endpoints are grouped by tags (Products, Categories)
- Click on any endpoint to expand its details
- View the endpoint description, parameters, and response schemas

### 3. Test Endpoints
1. Click the "Try it out" button for any endpoint
2. Fill in the required parameters
3. Click "Execute" to send the request
4. View the response, status code, and headers

### 4. Authentication
Currently, the API doesn't require authentication. In a production environment, you would add authentication headers here.

## Query Parameters

### Products Index Filtering
- `category_id` (integer, optional): Filter products by category ID
- `page` (integer, optional): Page number for pagination (default: 1)
- `per_page` (integer, optional): Items per page, max 100 (default: 25)

### Example Requests
```bash
# Get all products
GET /api/v1/products

# Filter by category
GET /api/v1/products?category_id=1

# Paginated results
GET /api/v1/products?page=2&per_page=10

# Combined filtering and pagination
GET /api/v1/products?category_id=1&page=1&per_page=5
```

## Request/Response Examples

### Create a Product
**Request:**
```json
POST /api/v1/products
Content-Type: application/json

{
  "product": {
    "name": "New Product",
    "description": "Product description",
    "price": 99.99,
    "stock_quantity": 10,
    "category_id": 1,
    "is_featured": false
  }
}
```

**Response:**
```json
{
  "id": 1,
  "name": "New Product",
  "description": "Product description",
  "price": "99.99",
  "stock_quantity": 10,
  "category_id": 1,
  "category_name": "Electronics",
  "published_at": null,
  "is_featured": false,
  "is_admin": false
}
```

### Feature a Product
**Request:**
```bash
PATCH /api/v1/products/1/feature
```

**Response:**
```json
{
  "message": "Product successfully featured",
  "product": {
    "id": 1,
    "name": "New Product",
    "is_featured": true,
    "featured_at": "2023-07-13T12:00:00.000Z"
  }
}
```

## Error Responses

### Validation Errors (422)
```json
{
  "errors": {
    "name": ["can't be blank"],
    "price": ["must be greater than or equal to 0"]
  }
}
```

### Not Found (404)
```json
{
  "error": "Product not found"
}
```

## Data Models

### Product Schema
```json
{
  "id": "integer",
  "name": "string",
  "description": "string",
  "price": "string",
  "stock_quantity": "integer",
  "category_id": "integer (nullable)",
  "category_name": "string (nullable)",
  "published_at": "string (date-time, nullable)",
  "is_featured": "boolean",
  "is_admin": "boolean"
}
```

### Category Schema
```json
{
  "id": "integer",
  "name": "string",
  "created_at": "string (date-time)",
  "updated_at": "string (date-time)"
}
```

### Pagination Schema
```json
{
  "current_page": "integer",
  "total_pages": "integer",
  "total_count": "integer",
  "per_page": "integer",
  "next_page": "integer (nullable)",
  "prev_page": "integer (nullable)"
}
```

## Development

### Updating Documentation
The Swagger documentation is manually maintained in `swagger/v1/swagger.json`. To update:

1. Edit the JSON file directly
2. Follow the OpenAPI 3.0.1 specification
3. Test the changes by refreshing the documentation page

### Adding New Endpoints
1. Add the endpoint definition to `swagger/v1/swagger.json`
2. Include all parameters, request bodies, and response schemas
3. Add examples for better developer experience
4. Test the endpoint through the Swagger UI

### Best Practices
- Keep examples realistic and up-to-date
- Include all possible response codes
- Document all parameters and their constraints
- Use descriptive summaries and descriptions
- Group related endpoints with tags

## Troubleshooting

### Documentation Not Loading
- Ensure the Rails server is running
- Check that `swagger/v1/swagger.json` exists
- Verify the route configuration in `config/routes.rb`

### JSON Validation Errors
- Use an OpenAPI validator to check the JSON syntax
- Ensure all required fields are present
- Check for proper JSON formatting

### CORS Issues
- The documentation is served from the same origin as the API
- No CORS configuration should be needed for local development

## Integration with Other Tools

### Postman
- Import the OpenAPI specification from `/swagger/v1/swagger.json`
- Generate a Postman collection automatically
- Use the examples provided in the documentation

### Code Generation
- Use tools like OpenAPI Generator to create client libraries
- Generate SDKs for various programming languages
- Create TypeScript interfaces from the schema

### CI/CD Integration
- Validate the OpenAPI specification in your build pipeline
- Generate documentation as part of the deployment process
- Ensure API changes are reflected in the documentation

## Security Considerations

### Production Deployment
- Consider adding authentication to the documentation
- Restrict access to sensitive API documentation
- Use HTTPS in production environments
- Implement rate limiting for API endpoints

### Information Disclosure
- Be careful not to expose sensitive information in examples
- Use placeholder data for authentication examples
- Consider environment-specific documentation

---

For more information about the API implementation, see the [README.md](../README.md) file.
