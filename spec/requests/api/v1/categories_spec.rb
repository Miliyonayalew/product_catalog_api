require 'swagger_helper'

RSpec.describe 'Api::V1::Categories', swagger_doc: 'v1/swagger.json' do
  path '/api/v1/categories' do
    get 'Retrieves all categories' do
      tags 'Categories'
      produces 'application/json'

      response '200', 'categories retrieved' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 }
               }

        let!(:category) { Category.create!(name: 'Electronics') }

        run_test!
      end
    end

    post 'Creates a new category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string, example: 'New Category' }
            },
            required: ['name']
          }
        }
      }

      response '201', 'category created' do
        let(:category) { { category: { name: 'New Category' } } }

        run_test!
      end

      response '422', 'invalid request' do
        let(:category) { { category: { name: '' } } }

        run_test!
      end
    end
  end

  path '/api/v1/categories/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Retrieves a specific category' do
      tags 'Categories'
      produces 'application/json'

      response '200', 'category found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               }

        let(:id) { Category.create!(name: 'Electronics').id }

        run_test!
      end

      response '404', 'category not found' do
        let(:id) { 99999 }

        run_test!
      end
    end

    patch 'Updates a category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Updated Category' }
            }
          }
        }
      }

      response '200', 'category updated' do
        let(:category_record) { Category.create!(name: 'Electronics') }
        let(:id) { category_record.id }
        let(:category) { { category: { name: 'Updated Category' } } }

        run_test!
      end

      response '422', 'invalid request' do
        let(:category_record) { Category.create!(name: 'Electronics') }
        let(:id) { category_record.id }
        let(:category) { { category: { name: '' } } }

        run_test!
      end

      response '404', 'category not found' do
        let(:id) { 99999 }
        let(:category) { { category: { name: 'Updated Category' } } }

        run_test!
      end
    end

    delete 'Deletes a category' do
      tags 'Categories'

      response '204', 'category deleted' do
        let(:id) { Category.create!(name: 'Electronics').id }

        run_test!
      end

      response '404', 'category not found' do
        let(:id) { 99999 }

        run_test!
      end
    end
  end
end
