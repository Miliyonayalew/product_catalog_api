require "test_helper"

class Api::V1::CategoriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @electronics = categories(:electronics)
    @laptop = products(:laptop)
  end

  test "should get index" do
    get api_v1_categories_url
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test "should get index without N+1 queries" do
    # Monitor SQL queries to ensure no N+1
    queries = []
    ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      queries << event.payload[:sql] if event.payload[:name] == "Category Load"
    end

    get api_v1_categories_url
    assert_response :success

    # Should only have 1 query for categories (not N+1 for products_count)
    category_queries = queries.select { |sql| sql.include?("categories") }
    assert_equal 1, category_queries.count, "Expected only 1 query for categories, got #{category_queries.count}"
  end

  test "should get show" do
    get api_v1_category_url(@electronics)
    assert_response :success
  end

  test "should get show without N+1 queries" do
    # Monitor SQL queries to ensure no N+1
    queries = []
    ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      queries << event.payload[:sql] if event.payload[:name] == "Product Load"
    end

    get api_v1_category_url(@electronics)
    assert_response :success

    # Should only have 1 query for products (not N+1)
    product_queries = queries.select { |sql| sql.include?("products") }
    assert_equal 1, product_queries.count, "Expected only 1 query for products, got #{product_queries.count}"
  end

  test "should create category" do
    assert_difference("Category.count") do
      post api_v1_categories_url, params: {
        category: { name: "New Category" }
      }
    end
    assert_response :created
  end

  test "should not create category with invalid attributes" do
    assert_no_difference("Category.count") do
      post api_v1_categories_url, params: {
        category: { name: "" }
      }
    end
    assert_response :unprocessable_content
  end

  test "should update category" do
    patch api_v1_category_url(@electronics), params: {
      category: { name: "Updated Electronics" }
    }
    assert_response :success
    @electronics.reload
    assert_equal "Updated Electronics", @electronics.name
  end

  test "should not update category with invalid attributes" do
    patch api_v1_category_url(@electronics), params: {
      category: { name: "" }
    }
    assert_response :unprocessable_content
  end

  test "should destroy category" do
    # Create a category without products for testing deletion
    empty_category = Category.create!(name: "Empty Category")
    assert_difference("Category.count", -1) do
      delete api_v1_category_url(empty_category)
    end
    assert_response :no_content
  end

  test "should not destroy category with associated products" do
    # Create a category with products
    category_with_products = Category.create!(name: "Test Category")
    Product.create!(
      name: "Test Product",
      price: 99.99,
      stock_quantity: 10,
      category: category_with_products
    )

    assert_no_difference("Category.count") do
      delete api_v1_category_url(category_with_products)
    end
    # Should fail due to foreign key constraint
    assert_response :unprocessable_content
  end
end
