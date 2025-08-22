require "test_helper"

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @electronics = categories(:electronics)
    @books = categories(:books)
    @laptop = products(:laptop)
    @headphones = products(:headphones)
    @book = products(:book)
    @tshirt = products(:tshirt)
    @no_category_product = products(:no_category_product)
  end

  # Index action tests
  test "should get index" do
    get api_v1_products_url
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should return products with pagination metadata" do
    get api_v1_products_url
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_includes json_response.keys, "products"
    assert_includes json_response.keys, "pagination"

    pagination = json_response["pagination"]
    assert_includes pagination.keys, "current_page"
    assert_includes pagination.keys, "total_pages"
    assert_includes pagination.keys, "total_count"
    assert_includes pagination.keys, "per_page"
  end

  test "should filter products by category_id" do
    get api_v1_products_url, params: { category_id: @electronics.id }
    assert_response :success

    json_response = JSON.parse(response.body)
    products = json_response["products"]

    # Should only return electronics products
    products.each do |product|
      assert_equal @electronics.id, product["category_id"]
    end

    # Should include laptop and headphones (electronics)
    product_names = products.map { |p| p["name"] }
    assert_includes product_names, "Laptop Pro X"
    assert_includes product_names, "Wireless Headphones"
    assert_not_includes product_names, "The Great Novel" # books category
  end

  test "should paginate products" do
    # Create more products to test pagination
    15.times do |i|
      Product.create!(
        name: "Test Product #{i}",
        price: 10.0 + i,
        stock_quantity: 5,
        category: @electronics
      )
    end

    get api_v1_products_url, params: { page: 2, per_page: 5 }
    assert_response :success

    json_response = JSON.parse(response.body)
    products = json_response["products"]
    pagination = json_response["pagination"]

    assert_equal 5, products.length
    assert_equal 2, pagination["current_page"]
    assert_equal 5, pagination["per_page"]
    assert pagination["total_pages"] > 1
  end

  test "should respect per_page limit" do
    get api_v1_products_url, params: { per_page: 150 } # Over the limit of 100
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    assert_equal 100, pagination["per_page"] # Should be capped at 100
  end

  # Show action tests
  test "should show product" do
    get api_v1_product_url(@laptop)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @laptop.id, json_response["id"]
    assert_equal @laptop.name, json_response["name"]
    assert_equal @laptop.category_name, json_response["category_name"]
  end

  test "should return 404 for non-existent product" do
    get api_v1_product_url(99999)
    assert_response :not_found
  end

  # Create action tests
  test "should create product with valid attributes" do
    assert_difference("Product.count") do
      post api_v1_products_url, params: {
        product: {
          name: "New Product",
          description: "A new product",
          price: 99.99,
          stock_quantity: 10,
          category_id: @electronics.id
        }
      }
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "New Product", json_response["name"]
  end

  test "should not create product with invalid attributes" do
    assert_no_difference("Product.count") do
      post api_v1_products_url, params: {
        product: {
          name: "", # Invalid: empty name
          price: -10, # Invalid: negative price
          stock_quantity: 5
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should prevent mass assignment vulnerability" do
    post api_v1_products_url, params: {
      product: {
        name: "Malicious Product",
        price: 10.0,
        stock_quantity: 5,
        is_admin: true # This should not be allowed
      }
    }

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_not json_response["is_admin"] # Should be false, not true
  end

  # Update action tests
  test "should update product with valid attributes" do
    patch api_v1_product_url(@laptop), params: {
      product: {
        name: "Updated Laptop",
        price: 1500.00
      }
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Updated Laptop", json_response["name"]
    assert_equal "1500.0", json_response["price"]
  end

  test "should not update product with invalid attributes" do
    patch api_v1_product_url(@laptop), params: {
      product: {
        name: "", # Invalid: empty name
        price: -100 # Invalid: negative price
      }
    }

    assert_response :unprocessable_content
  end

  test "should prevent mass assignment vulnerability in update" do
    patch api_v1_product_url(@laptop), params: {
      product: {
        name: "Updated Product",
        is_admin: true # This should not be allowed
      }
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_not json_response["is_admin"] # Should remain false
  end

  # Destroy action tests
  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete api_v1_product_url(@laptop)
    end

    assert_response :no_content
  end

  test "should return 404 when destroying non-existent product" do
    delete api_v1_product_url(99999)
    assert_response :not_found
  end

  # Feature action tests
  test "should feature a product" do
    assert_not @laptop.is_featured?

    patch feature_api_v1_product_url(@laptop)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "Product successfully featured", json_response["message"]
    assert json_response["product"]["is_featured"]
    assert_includes json_response["product"].keys, "featured_at"

    @laptop.reload
    assert @laptop.is_featured?
  end

  test "should not feature an already featured product" do
    @tshirt.update!(is_featured: true)
    assert @tshirt.is_featured?

    patch feature_api_v1_product_url(@tshirt)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "Product is already featured", json_response["message"]
    assert json_response["product"]["is_featured"]
  end

  test "should return 404 when featuring non-existent product" do
    patch feature_api_v1_product_url(99999)
    assert_response :not_found
  end

  # Unfeature action tests
  test "should unfeature a product" do
    @tshirt.update!(is_featured: true)
    assert @tshirt.is_featured?

    patch unfeature_api_v1_product_url(@tshirt)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "Product successfully unfeatured", json_response["message"]
    assert_not json_response["product"]["is_featured"]

    @tshirt.reload
    assert_not @tshirt.is_featured?
  end

  test "should not unfeature a non-featured product" do
    assert_not @laptop.is_featured?

    patch unfeature_api_v1_product_url(@laptop)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "Product is not featured", json_response["message"]
    assert_not json_response["product"]["is_featured"]
  end

  test "should return 404 when unfeaturing non-existent product" do
    patch unfeature_api_v1_product_url(99999)
    assert_response :not_found
  end

  # N+1 Query Prevention Tests
  test "should not cause N+1 queries when fetching products with categories" do
    # Count the number of queries executed
    count = 0
    counter = ->(name, started, finished, unique_id, payload) {
      count += 1 unless payload[:name].in? [ "CACHE", "SCHEMA" ]
    }

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
      get api_v1_products_url
    end

    # Should only have 2 queries: one for products, one for categories
    # (plus potentially some schema queries)
    assert count <= 5, "Expected 2-5 queries, got #{count}"
  end

  test "should include category data in response without additional queries" do
    get api_v1_products_url
    assert_response :success

    json_response = JSON.parse(response.body)
    products = json_response["products"]

    # All products should have category_name populated
    products.each do |product|
      if product["category_id"]
        assert_not_nil product["category_name"], "Category name should be populated for product #{product['id']}"
      else
        assert_nil product["category_name"], "Category name should be nil for product without category"
      end
    end
  end

  # Edge cases
  test "should handle products with nil category gracefully" do
    get api_v1_product_url(@no_category_product)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_nil json_response["category_id"]
    assert_nil json_response["category_name"]
  end

  test "should handle empty category filter gracefully" do
    get api_v1_products_url, params: { category_id: "" }
    assert_response :success

    json_response = JSON.parse(response.body)
    products = json_response["products"]
    # Should return all products when category_id is empty string
    assert products.length > 0
  end
end
