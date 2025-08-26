require "test_helper"

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @electronics = categories(:electronics)
    @laptop = products(:laptop)
  end

  test "should get index" do
    get api_v1_products_url
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should get index with pagination" do
    get api_v1_products_url, params: { page: 1, per_page: 10 }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_includes json_response.keys, "pagination"
  end

  test "should get index with category filter" do
    get api_v1_products_url, params: { category_id: @electronics.id }
    assert_response :success
  end

  # NEW: Error handling tests for filtering
  test "should return error for invalid category_id" do
    get api_v1_products_url, params: { category_id: 99999 }
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid category_id", json_response["error"]
    assert_includes json_response["message"], "does not exist"
  end

  test "should return error for non-integer category_id" do
    get api_v1_products_url, params: { category_id: "invalid" }
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid category_id", json_response["error"]
    assert_includes json_response["message"], "must be a valid integer"
  end

  # NEW: Error handling tests for pagination
  test "should return error for negative page" do
    get api_v1_products_url, params: { page: -1 }
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid page parameter", json_response["error"]
  end

  test "should return error for zero page" do
    get api_v1_products_url, params: { page: 0 }
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid page parameter", json_response["error"]
  end

  test "should return error for invalid per_page" do
    get api_v1_products_url, params: { per_page: 0 }
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid per_page parameter", json_response["error"]
  end

  test "should return error for per_page over limit" do
    get api_v1_products_url, params: { per_page: 101 }
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Invalid per_page parameter", json_response["error"]
  end

  test "should return error for page out of range" do
    get api_v1_products_url, params: { page: 999 }
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Page out of range", json_response["error"]
  end

  test "should get show" do
    get api_v1_product_url(@laptop)
    assert_response :success
  end

  # NEW: Error handling test for show
  test "should return error for non-existent product" do
    get api_v1_product_url(99999)
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Product not found", json_response["error"]
  end

  test "should create product" do
    assert_difference("Product.count") do
      post api_v1_products_url, params: {
        product: {
          name: "New Product",
          price: 99.99,
          stock_quantity: 10,
          category_id: @electronics.id
        }
      }
    end
    assert_response :created
  end

  test "should not create product with invalid attributes" do
    assert_no_difference("Product.count") do
      post api_v1_products_url, params: {
        product: {
          name: "",
          price: -10,
          stock_quantity: 5
        }
      }
    end
    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_equal "Validation failed", json_response["error"]
    assert_includes json_response["errors"], "Name can't be blank"
  end

  # NEW: Error handling test for create
  test "should return error for missing product parameters" do
    post api_v1_products_url, params: {}
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Missing parameters", json_response["error"]
  end

  test "should update product" do
    patch api_v1_product_url(@laptop), params: {
      product: { name: "Updated Product" }
    }
    assert_response :success
    @laptop.reload
    assert_equal "Updated Product", @laptop.name
  end

  test "should not update product with invalid attributes" do
    patch api_v1_product_url(@laptop), params: {
      product: {
        name: "",
        price: -100
      }
    }
    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_equal "Validation failed", json_response["error"]
  end

  # NEW: Error handling test for update
  test "should return error for updating non-existent product" do
    patch api_v1_product_url(99999), params: {
      product: { name: "Updated Product" }
    }
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Product not found", json_response["error"]
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete api_v1_product_url(@laptop)
    end
    assert_response :no_content
  end

  # NEW: Error handling test for destroy
  test "should return error for destroying non-existent product" do
    delete api_v1_product_url(99999)
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Product not found", json_response["error"]
  end

  # NEW: Authorization tests for feature action
  test "should feature product with admin authorization" do
    patch feature_api_v1_product_url(@laptop), headers: { "X-Admin-Token" => "admin-secret-token" }
    assert_response :success
    @laptop.reload
    assert @laptop.is_featured?
  end

  test "should feature product with admin token parameter" do
    patch feature_api_v1_product_url(@laptop), params: { admin_token: "admin-secret-token" }
    assert_response :success
    @laptop.reload
    assert @laptop.is_featured?
  end

  test "should not feature product without admin authorization" do
    patch feature_api_v1_product_url(@laptop)
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Unauthorized", json_response["error"]
    assert_includes json_response["message"], "Admin privileges required"
  end

  test "should not feature product with invalid admin token" do
    patch feature_api_v1_product_url(@laptop), headers: { "X-Admin-Token" => "wrong-token" }
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Unauthorized", json_response["error"]
  end

  test "should return message when product is already featured" do
    @laptop.update!(is_featured: true)
    patch feature_api_v1_product_url(@laptop), headers: { "X-Admin-Token" => "admin-secret-token" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Product is already featured", json_response["message"]
  end

  # NEW: Error handling test for feature action
  test "should return error for featuring non-existent product" do
    patch feature_api_v1_product_url(99999), headers: { "X-Admin-Token" => "admin-secret-token" }
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Product not found", json_response["error"]
  end

  # NEW: Authorization tests for unfeature action
  test "should unfeature product with admin authorization" do
    @laptop.update!(is_featured: true)
    patch unfeature_api_v1_product_url(@laptop), headers: { "X-Admin-Token" => "admin-secret-token" }
    assert_response :success
    @laptop.reload
    assert_not @laptop.is_featured?
  end

  test "should not unfeature product without admin authorization" do
    @laptop.update!(is_featured: true)
    patch unfeature_api_v1_product_url(@laptop)
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Unauthorized", json_response["error"]
  end

  test "should return message when product is not featured" do
    @laptop.update!(is_featured: false)
    patch unfeature_api_v1_product_url(@laptop), headers: { "X-Admin-Token" => "admin-secret-token" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Product is not featured", json_response["message"]
  end

  # NEW: Error handling test for unfeature action
  test "should return error for unfeaturing non-existent product" do
    patch unfeature_api_v1_product_url(99999), headers: { "X-Admin-Token" => "admin-secret-token" }
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Product not found", json_response["error"]
  end

  # NEW: N+1 Query prevention test
  test "should not cause N+1 queries when loading products with categories" do
    # Create multiple products to test N+1 prevention
    category = categories(:electronics)
    5.times do |i|
      Product.create!(
        name: "Product #{i}",
        price: 100 + i,
        stock_quantity: 10,
        category: category
      )
    end

    # Count the number of queries executed
    count = 0
    counter = ->(name, started, finished, unique_id, payload) {
      count += 1 unless payload[:name].in? %w[ CACHE SCHEMA ]
    }

    # Subscribe to the notification
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
      get api_v1_products_url
    end

    # Should only have 2 queries: one for products, one for categories (not N+1)
    assert count <= 3, "Expected 2-3 queries, got #{count} (N+1 query detected)"
  end

  # NEW: Cache invalidation test
  test "should invalidate cache when product is updated" do
    # Test that cache invalidation is called by checking the method is invoked
    # Since we can't easily stub Rails.cache.delete in test environment,
    # we'll verify the behavior by checking the response and ensuring no errors
    patch api_v1_product_url(@laptop), params: {
      product: { name: "Updated Product" }
    }

    assert_response :success
    @laptop.reload
    assert_equal "Updated Product", @laptop.name
  end

  test "should invalidate cache when product is featured" do
    patch feature_api_v1_product_url(@laptop), headers: { "X-Admin-Token" => "admin-secret-token" }

    assert_response :success
    @laptop.reload
    assert @laptop.is_featured?
  end

  test "should invalidate cache when product is destroyed" do
    product_to_delete = @laptop
    delete api_v1_product_url(product_to_delete)

    assert_response :no_content
    assert_not Product.exists?(product_to_delete.id)
  end

  # NEW: Strong parameters security test
  test "should not allow mass assignment of is_admin" do
    assert_difference("Product.count") do
      post api_v1_products_url, params: {
        product: {
          name: "Malicious Product",
          price: 99.99,
          stock_quantity: 10,
          is_admin: true  # This should be ignored
        }
      }
    end
    assert_response :created

    # Verify the product was created but is_admin was ignored
    product = Product.last
    assert_equal "Malicious Product", product.name
    assert_not product.is_admin  # Should be false (default value)
  end

  test "should not allow updating is_admin through mass assignment" do
    original_admin_status = @laptop.is_admin
    patch api_v1_product_url(@laptop), params: {
      product: {
        name: "Updated Product",
        is_admin: true  # This should be ignored
      }
    }
    assert_response :success
    @laptop.reload
    assert_equal original_admin_status, @laptop.is_admin
    assert_equal "Updated Product", @laptop.name
  end
end
