# Categories controller with intentional bugs for learning
# This controller has some issues that trainees should identify and fix
module Api
  module V1
    class CategoriesController < ApplicationController
      # GET /api/v1/categories
      def index
        # BUG: No error handling for database connection issues
        # BUG: No pagination implemented (Task 3.1 requirement)
        @categories = Category.all
        
        render json: @categories.map { |category|
          {
            id: category.id,
            name: category.name,
            products_count: category.products.count, # This could cause N+1 if not careful
            created_at: category.created_at,
            updated_at: category.updated_at
          }
        }
      end

      # GET /api/v1/categories/:id
      def show
        # BUG: No error handling for non-existent records
        @category = Category.find(params[:id])
        
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
        # BUG: Mass assignment vulnerability - no strong parameters
        @category = Category.new(params[:category])
        
        if @category.save
          render json: @category, status: :created
        else
          render json: @category.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/categories/:id
      def update
        @category = Category.find(params[:id])
        
        # BUG: Mass assignment vulnerability - using permit!
        if @category.update(params.permit!)
          render json: @category
        else
          render json: @category.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/categories/:id
      def destroy
        @category = Category.find(params[:id])
        
        # BUG: No handling of dependent records
        # If category has products, this will fail due to foreign key constraint
        @category.destroy
        head :no_content
      end

      # Private method for strong parameters (this would be the fix)
      # private
      # def category_params
      #   params.require(:category).permit(:name)
      # end
    end
  end
end 