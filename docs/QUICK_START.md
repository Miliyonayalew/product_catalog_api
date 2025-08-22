# Quick Start Guide - API Documentation

## 🚀 Get Started in 3 Steps

### 1. Start the Server
```bash
rails server -p 3000
```

### 2. Open Documentation
Navigate to: **http://localhost:3000/api-docs**

### 3. Start Testing
- Click on any endpoint to expand it
- Click "Try it out" to test the endpoint
- Fill in parameters and click "Execute"

## 📋 What You'll Find

### Interactive API Explorer
- **Real-time testing** of all endpoints
- **Automatic validation** of request parameters
- **Live response** preview with status codes
- **Request/response examples** for every endpoint

### Complete API Coverage
- **Products**: Full CRUD + featuring functionality
- **Categories**: Full CRUD operations
- **Filtering**: By category, pagination support
- **Error handling**: All possible response codes

### Developer-Friendly Features
- **Copy-paste examples** for immediate use
- **Schema definitions** for all data models
- **Parameter constraints** and validation rules
- **Response structure** documentation

## 🔧 Common Use Cases

### Get All Products
1. Find `GET /api/v1/products` in the Products section
2. Click "Try it out"
3. Click "Execute" (no parameters needed)
4. View the paginated response

### Create a Product
1. Find `POST /api/v1/products` in the Products section
2. Click "Try it out"
3. Fill in the request body:
```json
{
  "product": {
    "name": "Test Product",
    "price": 99.99,
    "stock_quantity": 10
  }
}
```
4. Click "Execute"

### Filter Products by Category
1. Find `GET /api/v1/products` in the Products section
2. Click "Try it out"
3. Set `category_id` parameter to `1`
4. Click "Execute"

### Feature a Product
1. Find `PATCH /api/v1/products/{id}/feature` in the Products section
2. Click "Try it out"
3. Set the `id` parameter to an existing product ID
4. Click "Execute"

## 📖 Understanding the Interface

### Endpoint Groups
- **Products**: All product-related operations
- **Categories**: All category-related operations

### Response Codes
- **200**: Success
- **201**: Created successfully
- **204**: Deleted successfully
- **404**: Not found
- **422**: Validation error

### Data Types
- **integer**: Whole numbers
- **string**: Text values
- **boolean**: true/false values
- **date-time**: ISO 8601 formatted dates

## 🛠️ Tips for Developers

### Testing Workflows
1. **Create → Read → Update → Delete**: Test the full CRUD cycle
2. **Error scenarios**: Try invalid data to see error responses
3. **Edge cases**: Test with empty values, large numbers, etc.

### Integration
- **Copy the curl commands** for use in scripts
- **Use the JSON schemas** for client-side validation
- **Reference the examples** for your API client code

### Troubleshooting
- **Check the server logs** for detailed error information
- **Verify the database** has sample data for testing
- **Ensure all required fields** are provided in requests

## 🔗 Related Resources

- **Full Documentation**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Project README**: [../README.md](../README.md)
- **API Implementation**: Check the controller files in `app/controllers/api/v1/`

## 🎯 Next Steps

1. **Explore all endpoints** to understand the full API
2. **Test with your own data** to see real responses
3. **Integrate with your application** using the provided examples
4. **Check the test suite** for more usage examples

---

**Happy API testing! 🚀**
