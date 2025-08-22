# Categories controller with intentional bugs for learning
# This controller has some issues that trainees should identify and fix
module Api
  module V1
    class CategoriesController < ApplicationController
      # GET /api/v1/categories
      def index
        # BUG: No error handling for database connection issues
        # BUG: No pagination implemented (Task 3.1 requirement)
        @categories = Category.includes(:products)

        render json: @categories.map { |category|
          {
            id: category.id,
            name: category.name,
            products_count: category.products.size, # Use size instead of count to avoid N+1
            created_at: category.created_at,
            updated_at: category.updated_at
          }
        }
      end

      # GET /api/v1/categories/:id
      def show
        # BUG: No error handling for non-existent records
        @category = Category.includes(:products).find(params[:id])

        render json: {
          id: @category.id,
          name: @category.name,
          products: @category.products.map { |product|
            {
              id: product.id,
              name: product.name,
              price: product.price,
              stock_quantity: product.stock_quantity
            }
          }
        }
      end

      # POST /api/v1/categories
      def create
        @category = Category.new(category_params)

        if @category.save
          render json: @category, status: :created
        else
          render json: @category.errors, status: :unprocessable_content
        end
      end

      # PATCH/PUT /api/v1/categories/:id
      def update
        @category = Category.find(params[:id])

        if @category.update(category_params)
          render json: @category
        else
          render json: @category.errors, status: :unprocessable_content
        end
      end

      # DELETE /api/v1/categories/:id
      def destroy
        @category = Category.find(params[:id])

        begin
          @category.destroy
          head :no_content
        rescue ActiveRecord::InvalidForeignKey
          render json: { error: "Cannot delete category with associated products" },
                 status: :unprocessable_content
        end
      end

      private

      def category_params
        params.require(:category).permit(:name)
      end
    end
  end
end
