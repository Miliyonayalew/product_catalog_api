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

  test "should get show" do
    get api_v1_product_url(@laptop)
    assert_response :success
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
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete api_v1_product_url(@laptop)
    end
    assert_response :no_content
  end

  test "should feature product" do
    patch feature_api_v1_product_url(@laptop)
    assert_response :success
    @laptop.reload
    assert @laptop.is_featured?
  end

  test "should unfeature product" do
    @laptop.update!(is_featured: true)
    patch unfeature_api_v1_product_url(@laptop)
    assert_response :success
    @laptop.reload
    assert_not @laptop.is_featured?
  end
end
