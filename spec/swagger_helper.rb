# frozen_string_literal: true

# RSwag runs under RSpec; avoid requiring Minitest test_helper here.

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Product Catalog API',
        description: 'A robust Rails API for managing products and categories with advanced features including filtering, pagination, and featuring functionality.',
        version: 'v1',
        contact: {
          name: 'API Support',
          email: 'support@example.com'
        },
        license: {
          name: 'MIT',
          url: 'https://opensource.org/licenses/MIT'
        }
      },
      tags: [
        {
          name: 'Products',
          description: 'Product management operations'
        },
        {
          name: 'Categories',
          description: 'Category management operations'
        }
      ],
      paths: {},
      components: {
        parameters: {
          AdminTokenHeader: {
            name: 'X-Admin-Token',
            in: :header,
            required: false,
            schema: { type: :string },
            description: 'Admin token required for feature/unfeature endpoints'
          }
        },
        schemas: {
          Error: {
            type: :object,
            properties: {
              error: { type: :string },
              message: { type: :string }
            },
            required: %w[error message]
          },
          ValidationError: {
            type: :object,
            properties: {
              error: { type: :string },
              errors: { type: :array, items: { type: :string } }
            },
            required: %w[error errors]
          }
        }
      },
              servers: [
          {
            url: 'http://localhost:3000',
            description: 'Development server'
          },
          {
            url: 'https://api.example.com',
            description: 'Production server'
          }
        ]
    }
  }

  # Output Swagger as JSON to match routes that serve swagger/v1/swagger.json
  config.openapi_format = :json
end
