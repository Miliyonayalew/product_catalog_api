require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @electronics = categories(:electronics)
    @books = categories(:books)
    @clothing = categories(:clothing)
  end

  # Association tests
  test "should belong to category" do
    product = Product.new(name: "Test Product", price: 10.0, stock_quantity: 5)
    assert product.respond_to?(:category)
  end

  test "should allow nil category" do
    product = Product.new(name: "Test Product", price: 10.0, stock_quantity: 5, category: nil)
    assert product.valid?
  end

  # Validation tests
  test "should be valid with valid attributes" do
    product = Product.new(
      name: "Valid Product",
      description: "A valid product description",
      price: 99.99,
      stock_quantity: 10,
      category: @electronics
    )
    assert product.valid?
  end

  test "should require name" do
    product = Product.new(price: 10.0, stock_quantity: 5)
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "should require non-negative price" do
    product = Product.new(name: "Test Product", price: -10.0, stock_quantity: 5)
    assert_not product.valid?
    assert_includes product.errors[:price], "must be greater than or equal to 0"
  end

  test "should require non-negative stock quantity" do
    product = Product.new(name: "Test Product", price: 10.0, stock_quantity: -5)
    assert_not product.valid?
    assert_includes product.errors[:stock_quantity], "must be greater than or equal to 0"
  end

  # Scope tests
  test "by_category scope should filter by category_id" do
    product1 = Product.create!(name: "Electronics Product", price: 100, stock_quantity: 10, category: @electronics)
    product2 = Product.create!(name: "Book Product", price: 20, stock_quantity: 5, category: @books)

    electronics_products = Product.by_category(@electronics.id)
    assert_includes electronics_products, product1
    assert_not_includes electronics_products, product2
  end

  test "by_category scope should return all products when category_id is nil" do
    product1 = Product.create!(name: "Product 1", price: 100, stock_quantity: 10, category: @electronics)
    product2 = Product.create!(name: "Product 2", price: 20, stock_quantity: 5, category: @books)

    all_products = Product.by_category(nil)
    assert_includes all_products, product1
    assert_includes all_products, product2
  end

  test "featured scope should return only featured products" do
    featured_product = Product.create!(name: "Featured Product", price: 100, stock_quantity: 10, is_featured: true)
    regular_product = Product.create!(name: "Regular Product", price: 50, stock_quantity: 5, is_featured: false)

    featured_products = Product.featured
    assert_includes featured_products, featured_product
    assert_not_includes featured_products, regular_product
  end

  test "published scope should return only published products" do
    published_product = Product.create!(name: "Published Product", price: 100, stock_quantity: 10, published_at: Time.current)
    unpublished_product = Product.create!(name: "Unpublished Product", price: 50, stock_quantity: 5, published_at: nil)

    published_products = Product.published
    assert_includes published_products, published_product
    assert_not_includes published_products, unpublished_product
  end

  test "in_stock scope should return only products with stock > 0" do
    in_stock_product = Product.create!(name: "In Stock Product", price: 100, stock_quantity: 10)
    out_of_stock_product = Product.create!(name: "Out of Stock Product", price: 50, stock_quantity: 0)

    in_stock_products = Product.in_stock
    assert_includes in_stock_products, in_stock_product
    assert_not_includes in_stock_products, out_of_stock_product
  end

  # Method tests
  test "category_name should return category name when category exists" do
    product = Product.create!(name: "Test Product", price: 100, stock_quantity: 10, category: @electronics)
    assert_equal "Electronics", product.category_name
  end

  test "category_name should return nil when category is nil" do
    product = Product.create!(name: "Test Product", price: 100, stock_quantity: 10, category: nil)
    assert_nil product.category_name
  end

  test "category_name should handle missing category gracefully" do
    # Test the safe navigation operator in the category_name method
    product = Product.new(name: "Test Product", price: 100, stock_quantity: 10)
    # The category_name method uses safe navigation (&.), so it should handle nil category
    assert_nil product.category_name
  end

  # Feature status tests
  test "is_featured? should return true for featured products" do
    product = Product.create!(name: "Featured Product", price: 100, stock_quantity: 10, is_featured: true)
    assert product.is_featured?
  end

  test "is_featured? should return false for non-featured products" do
    product = Product.create!(name: "Regular Product", price: 100, stock_quantity: 10, is_featured: false)
    assert_not product.is_featured?
  end
end
