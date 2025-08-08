# This controller is designed to have multiple bugs:
# 1. N+1 Query (part of Bug 2.1): The `index` action fetches products without eager loading categories.
# 2. Mass Assignment Vulnerability (Bug 2.2): The `create` and `update` actions use `params.permit!`
#    or directly assign `params[:product]`, making them vulnerable.
# 3. Stale Price/Data Caching (Bug 2.3): The `show` action uses simple action caching without proper invalidation.
module Api
  module V1
    class ProductsController < ApplicationController
      # BUG 2.3 (Part 1): Basic action caching without proper invalidation.
      # This cache will not be automatically busted when a product is updated.
      # Note: caches_action is not available in Rails API mode (removed in Rails 5.0+)
      # For API caching, consider using HTTP-level caching headers or external caching solutions

      # GET /api/v1/products
      def index
        # BUG 2.1: This will cause an N+1 query problem.
        # For each product, a separate query will be made to fetch its category.
        # Also, if a product's category_id points to a non-existent category,
        # category_name will be nil, which is also part of the bug description.
        @products = Product.all

        # Simplified JSON rendering for illustration.
        # In a real app, you'd typically use serializers (e.g., Active Model Serializers, jbuilder).
        render json: @products.map { |product|
          {
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            stock_quantity: product.stock_quantity,
            category_id: product.category_id,
            category_name: product.category_name, # This call triggers the N+1 query
            published_at: product.published_at,
            is_featured: product.is_featured,
            is_admin: product.is_admin # Exposing this for the mass assignment demo
          }
        }
      end

      # GET /api/v1/products/:id
      def show
        @product = Product.find(params[:id])
        render json: {
          id: @product.id,
          name: @product.name,
          description: @product.description,
          price: @product.price,
          stock_quantity: @product.stock_quantity,
          category_id: @product.category_id,
          category_name: @product.category_name,
          published_at: @product.published_at,
          is_featured: @product.is_featured,
          is_admin: @product.is_admin
        }
      end

      # POST /api/v1/products
      def create
        # BUG 2.2: Mass assignment vulnerability.
        # This allows any attribute in the `product` hash to be set,
        # including potentially malicious or unintended ones (e.g., `is_admin`).
        @product = Product.new(params[:product]) # DIRECT ASSIGNMENT FROM PARAMS

        if @product.save
          render json: @product, status: :created
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/products/:id
      def update
        @product = Product.find(params[:id])
        # BUG 2.2: Mass assignment vulnerability.
        # This allows any attribute in the `product` hash to be set,
        # including potentially malicious or unintended ones.
        if @product.update(params.permit!) # USING permit! which is unsafe
          # BUG 2.3 (Part 2): Cache invalidation missing.
          # The `show` action's cache is not explicitly expired here by default.
          # You would add `expire_action action: :show, id: @product.id` as a fix.
          render json: @product
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product = Product.find(params[:id])
        @product.destroy
        head :no_content
      end

      # Custom action for featuring a product (for Task 3.2)
      def feature
        @product = Product.find(params[:id])
        if @product.update(is_featured: true)
          # BUG 2.3 (Part 3): Cache invalidation missing for custom actions as well.
          # The `show` action's cache is not explicitly expired here by default.
          # You would add `expire_action action: :show, id: @product.id` as a fix.
          render json: @product
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # Private method for strong parameters (this would be the fix for Bug 2.2)
      # private
      # def product_params
      #   params.require(:product).permit(:name, :description, :price, :stock_quantity, :category_id, :published_at, :is_featured)
      # end
    end
  end
end
