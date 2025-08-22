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
        # @products = Product.all
        @products = Product.includes(:category)

        # Apply filters
        @products = @products.by_category(params[:category_id])

        # Apply pagination
        page = params[:page]&.to_i || 1
        per_page = [ params[:per_page]&.to_i || 25, 100 ].min # Cap at 100 items per page

        @products = @products.page(page).per(per_page)

        # Build response with pagination metadata
        render json: {
          products: @products.map { |product|
            {
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price,
              stock_quantity: product.stock_quantity,
              category_id: product.category_id,
              category_name: product.category_name,
              published_at: product.published_at,
              is_featured: product.is_featured,
              is_admin: product.is_admin
            }
          },
          pagination: {
            current_page: @products.current_page,
            total_pages: @products.total_pages,
            total_count: @products.total_count,
            per_page: @products.limit_value,
            next_page: @products.next_page,
            prev_page: @products.prev_page
          }
        }
      end

      # GET /api/v1/products/:id
      def show
        @product = Product.find(params[:id])

        # FIXED: Add HTTP-level caching headers for better performance
        fresh_when(@product, etag: @product.cache_key)
        expires_in 1.hour, public: true

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
        # @product = Product.new(params[:product]) # DIRECT ASSIGNMENT FROM PARAMS
        # FIXED: Using strong parameters to prevent mass assignment vulnerability
        @product = Product.new(product_params)

        if @product.save
          render json: @product, status: :created
        else
          render json: @product.errors, status: :unprocessable_content
        end
      end

      # PATCH/PUT /api/v1/products/:id
      def update
        @product = Product.find(params[:id])
        # BUG 2.2: Mass assignment vulnerability.
        # This allows any attribute in the `product` hash to be set,
        # including potentially malicious or unintended ones.
        # if @product.update(params.permit!) # USING permit! which is unsafe
        #   # BUG 2.3 (Part 2): Cache invalidation missing.
        #   # The `show` action's cache is not explicitly expired here by default.
        #   # You would add `expire_action action: :show, id: @product.id` as a fix.
        # FIXED: Using strong parameters to prevent mass assignment vulnerability
        if @product.update(product_params)
          # FIXED: Cache invalidation using Rails.cache.delete (works in API mode)
          Rails.cache.delete("product_#{@product.id}")
          render json: @product
        else
          render json: @product.errors, status: :unprocessable_content
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product = Product.find(params[:id])
        @product.destroy
        # FIXED: Cache invalidation using Rails.cache.delete (works in API mode)
        Rails.cache.delete("product_#{@product.id}")
        head :no_content
      end

      # PATCH /api/v1/products/:id/feature
      # Custom action for featuring a product (for Task 3.2)
      def feature
        @product = Product.find(params[:id])

        # TODO: Add proper authorization here
        # In a real application, you would check if the current user is an admin:
        # unless current_user&.admin?
        #   render json: { error: 'Unauthorized' }, status: :forbidden
        #   return
        # end

        # Check if product is already featured
        if @product.is_featured?
          render json: {
            message: "Product is already featured",
            product: {
              id: @product.id,
              name: @product.name,
              is_featured: @product.is_featured
            }
          }, status: :ok
          return
        end

        # Update the product to be featured
        if @product.update(is_featured: true)
          # BUG 2.3 (Part 3): Cache invalidation missing for custom actions as well.
          # The `show` action's cache is not explicitly expired here by default.
          # You would add `expire_action action: :show, id: @product.id` as a fix.
          # FIXED: Cache invalidation using Rails.cache.delete (works in API mode)
          Rails.cache.delete("product_#{@product.id}")

          render json: {
            message: "Product successfully featured",
            product: {
              id: @product.id,
              name: @product.name,
              is_featured: @product.is_featured,
              featured_at: Time.current
            }
          }, status: :ok
        else
          render json: {
            error: "Failed to feature product",
            errors: @product.errors.full_messages
          }, status: :unprocessable_content
        end
      end

      # PATCH /api/v1/products/:id/unfeature
      # Custom action for unfeaturing a product
      def unfeature
        @product = Product.find(params[:id])

        # TODO: Add proper authorization here
        # In a real application, you would check if the current user is an admin:
        # unless current_user&.admin?
        #   render json: { error: 'Unauthorized' }, status: :forbidden
        #   return
        # end

        # Check if product is not featured
        unless @product.is_featured?
          render json: {
            message: "Product is not featured",
            product: {
              id: @product.id,
              name: @product.name,
              is_featured: @product.is_featured
            }
          }, status: :ok
          return
        end

        # Update the product to not be featured
        if @product.update(is_featured: false)
          # FIXED: Cache invalidation using Rails.cache.delete (works in API mode)
          Rails.cache.delete("product_#{@product.id}")

          render json: {
            message: "Product successfully unfeatured",
            product: {
              id: @product.id,
              name: @product.name,
              is_featured: @product.is_featured
            }
          }, status: :ok
        else
          render json: {
            error: "Failed to unfeature product",
            errors: @product.errors.full_messages
          }, status: :unprocessable_content
        end
      end

      # Private method for strong parameters (this would be the fix for Bug 2.2)
      # private
      # def product_params
      #   params.require(:product).permit(:name, :description, :price, :stock_quantity, :category_id, :published_at, :is_featured)
      # end
      # FIXED: Strong parameters method to prevent mass assignment vulnerability
      private
      def product_params
        # Only permit safe attributes - is_admin is intentionally excluded for security
        params.require(:product).permit(:name, :description, :price, :stock_quantity, :category_id, :published_at, :is_featured)
      end
    end
  end
end
