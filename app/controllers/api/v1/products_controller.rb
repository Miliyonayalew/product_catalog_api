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

        # Apply filters with error handling
        if params[:category_id].present?
          begin
            category_id = Integer(params[:category_id])
            unless Category.exists?(category_id)
              return render json: {
                error: "Invalid category_id",
                message: "Category with ID #{category_id} does not exist"
              }, status: :bad_request
            end
            @products = @products.by_category(category_id)
          rescue ArgumentError
            return render json: {
              error: "Invalid category_id",
              message: "category_id must be a valid integer"
            }, status: :bad_request
          end
        end

        # Apply pagination with error handling
        begin
          page = params[:page]&.to_i || 1
          per_page = params[:per_page]&.to_i || 25

          # Validate pagination parameters
          if page < 1
            return render json: {
              error: "Invalid page parameter",
              message: "Page must be greater than 0"
            }, status: :bad_request
          end

          if per_page < 1 || per_page > 100
            return render json: {
              error: "Invalid per_page parameter",
              message: "per_page must be between 1 and 100"
            }, status: :bad_request
          end

          @products = @products.page(page).per(per_page)

          # Check if page is out of range
          if page > @products.total_pages && @products.total_pages > 0
            return render json: {
              error: "Page out of range",
              message: "Page #{page} does not exist. Total pages: #{@products.total_pages}"
            }, status: :bad_request
          end
        rescue => e
          return render json: {
            error: "Pagination error",
            message: e.message
          }, status: :bad_request
        end

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
              category_name: product.category&.name,  # Use eager loaded association directly
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
        begin
          @product = Product.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          return render json: {
            error: "Product not found",
            message: "Product with ID #{params[:id]} does not exist"
          }, status: :not_found
        end

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
          category_name: @product.category&.name,  # Use association directly
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
          render json: {
            error: "Validation failed",
            errors: @product.errors.full_messages
          }, status: :unprocessable_content
        end
      rescue ActionController::ParameterMissing => e
        render json: {
          error: "Missing parameters",
          message: e.message
        }, status: :bad_request
      end

      # PATCH/PUT /api/v1/products/:id
      def update
        begin
          @product = Product.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          return render json: {
            error: "Product not found",
            message: "Product with ID #{params[:id]} does not exist"
          }, status: :not_found
        end

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
          render json: {
            error: "Validation failed",
            errors: @product.errors.full_messages
          }, status: :unprocessable_content
        end
      rescue ActionController::ParameterMissing => e
        render json: {
          error: "Missing parameters",
          message: e.message
        }, status: :bad_request
      end

      # DELETE /api/v1/products/:id
      def destroy
        begin
          @product = Product.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          return render json: {
            error: "Product not found",
            message: "Product with ID #{params[:id]} does not exist"
          }, status: :not_found
        end

        @product.destroy
        # FIXED: Cache invalidation using Rails.cache.delete (works in API mode)
        Rails.cache.delete("product_#{@product.id}")
        head :no_content
      end

      # PATCH /api/v1/products/:id/feature
      # Custom action for featuring a product (for Task 3.2)
      def feature
        begin
          @product = Product.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          return render json: {
            error: "Product not found",
            message: "Product with ID #{params[:id]} does not exist"
          }, status: :not_found
        end

        # IMPROVED: Basic authorization check
        unless admin_authorized?
          return render json: {
            error: "Unauthorized",
            message: "Admin privileges required to feature products"
          }, status: :forbidden
        end

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
        begin
          @product = Product.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          return render json: {
            error: "Product not found",
            message: "Product with ID #{params[:id]} does not exist"
          }, status: :not_found
        end

        # IMPROVED: Basic authorization check
        unless admin_authorized?
          return render json: {
            error: "Unauthorized",
            message: "Admin privileges required to unfeature products"
          }, status: :forbidden
        end

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

      # IMPROVED: Basic authorization method
      def admin_authorized?
        # For demo purposes, check for admin header or parameter
        # In a real application, this would check current_user.admin? or similar
        request.headers["X-Admin-Token"] == "admin-secret-token" ||
        params[:admin_token] == "admin-secret-token"
      end
    end
  end
end
