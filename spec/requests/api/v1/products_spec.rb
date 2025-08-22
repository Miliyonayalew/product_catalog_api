require 'swagger_helper'

RSpec.describe 'Api::V1::Products', swagger_doc: 'v1/swagger.json' do
  path '/api/v1/products' do
    get 'Retrieves products with pagination and filtering' do
      tags 'Products'
      produces 'application/json'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Filter products by category ID'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number for pagination', default: 1
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page (max 100)', default: 25

      response '200', 'products retrieved' do
        schema type: :object,
               properties: {
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       description: { type: :string },
                       price: { type: :string },
                       stock_quantity: { type: :integer },
                       category_id: { type: :integer, nullable: true },
                       category_name: { type: :string, nullable: true },
                       published_at: { type: :string, format: 'date-time', nullable: true },
                       is_featured: { type: :boolean },
                       is_admin: { type: :boolean }
                     }
                   }
                 },
                 pagination: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer },
                     per_page: { type: :integer },
                     next_page: { type: :integer, nullable: true },
                     prev_page: { type: :integer, nullable: true }
                   }
                 }
               }

        let(:category) { Category.create!(name: 'Electronics') }
        let!(:product) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category) }

        run_test!
      end
    end

    post 'Creates a new product' do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string, example: 'New Product' },
              description: { type: :string, example: 'Product description' },
              price: { type: :number, example: 99.99 },
              stock_quantity: { type: :integer, example: 10 },
              category_id: { type: :integer, example: 1 },
              published_at: { type: :string, format: 'date-time', example: '2023-07-13T00:00:00.000Z' },
              is_featured: { type: :boolean, example: false }
            },
            required: ['name', 'price', 'stock_quantity']
          }
        }
      }

      response '201', 'product created' do
        let(:category) { Category.create!(name: 'Electronics') }
        let(:product) { { product: { name: 'New Product', price: 99.99, stock_quantity: 10, category_id: category.id } } }

        run_test!
      end

      response '422', 'invalid request' do
        let(:product) { { product: { name: '', price: -10 } } }

        run_test!
      end
    end
  end

  path '/api/v1/products/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Retrieves a specific product' do
      tags 'Products'
      produces 'application/json'

      response '200', 'product found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 description: { type: :string },
                 price: { type: :string },
                 stock_quantity: { type: :integer },
                 category_id: { type: :integer, nullable: true },
                 category_name: { type: :string, nullable: true },
                 published_at: { type: :string, format: 'date-time', nullable: true },
                 is_featured: { type: :boolean },
                 is_admin: { type: :boolean }
               }

        let(:category) { Category.create!(name: 'Electronics') }
        let(:id) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category).id }

        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 99999 }

        run_test!
      end
    end

    patch 'Updates a product' do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Updated Product' },
              description: { type: :string, example: 'Updated description' },
              price: { type: :number, example: 149.99 },
              stock_quantity: { type: :integer, example: 20 },
              category_id: { type: :integer, example: 1 },
              published_at: { type: :string, format: 'date-time', example: '2023-07-13T00:00:00.000Z' },
              is_featured: { type: :boolean, example: true }
            }
          }
        }
      }

      response '200', 'product updated' do
        let(:category) { Category.create!(name: 'Electronics') }
        let(:product_record) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category) }
        let(:id) { product_record.id }
        let(:product) { { product: { name: 'Updated Product', price: 149.99 } } }

        run_test!
      end

      response '422', 'invalid request' do
        let(:category) { Category.create!(name: 'Electronics') }
        let(:product_record) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category) }
        let(:id) { product_record.id }
        let(:product) { { product: { name: '', price: -10 } } }

        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 99999 }
        let(:product) { { product: { name: 'Updated Product' } } }

        run_test!
      end
    end

    delete 'Deletes a product' do
      tags 'Products'

      response '204', 'product deleted' do
        let(:category) { Category.create!(name: 'Electronics') }
        let(:id) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category).id }

        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 99999 }

        run_test!
      end
    end
  end

  path '/api/v1/products/{id}/feature' do
    parameter name: :id, in: :path, type: :integer, required: true

    patch 'Marks a product as featured' do
      tags 'Products'
      produces 'application/json'

      response '200', 'product featured' do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Product successfully featured' },
                 product: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     is_featured: { type: :boolean },
                     featured_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        let(:category) { Category.create!(name: 'Electronics') }
        let(:id) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category, is_featured: false).id }

        run_test!
      end

      response '200', 'product already featured' do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Product is already featured' },
                 product: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     is_featured: { type: :boolean }
                   }
                 }
               }

        let(:category) { Category.create!(name: 'Electronics') }
        let(:id) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category, is_featured: true).id }

        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 99999 }

        run_test!
      end
    end
  end

  path '/api/v1/products/{id}/unfeature' do
    parameter name: :id, in: :path, type: :integer, required: true

    patch 'Removes featured status from a product' do
      tags 'Products'
      produces 'application/json'

      response '200', 'product unfeatured' do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Product successfully unfeatured' },
                 product: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     is_featured: { type: :boolean }
                   }
                 }
               }

        let(:category) { Category.create!(name: 'Electronics') }
        let(:id) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category, is_featured: true).id }

        run_test!
      end

      response '200', 'product not featured' do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Product is not featured' },
                 product: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     is_featured: { type: :boolean }
                   }
                 }
               }

        let(:category) { Category.create!(name: 'Electronics') }
        let(:id) { Product.create!(name: 'Test Product', price: 100, stock_quantity: 10, category: category, is_featured: false).id }

        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 99999 }

        run_test!
      end
    end
  end
end
