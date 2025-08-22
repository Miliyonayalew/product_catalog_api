require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @electronics = categories(:electronics)
    @books = categories(:books)
  end

  # Association tests
  test "should have many products" do
    assert @electronics.respond_to?(:products)
  end

  # Validation tests
  test "should be valid with valid attributes" do
    category = Category.new(name: "Valid Category")
    assert category.valid?
  end

  test "should require name" do
    category = Category.new
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    Category.create!(name: "Unique Category")
    duplicate_category = Category.new(name: "Unique Category")
    assert_not duplicate_category.valid?
    assert_includes duplicate_category.errors[:name], "has already been taken"
  end

  # Product association tests
  test "should have products" do
    product = Product.create!(name: "Test Product", price: 100, stock_quantity: 10, category: @electronics)
    assert_includes @electronics.products, product
  end

  test "should not destroy associated products when deleted due to foreign key constraint" do
    product = Product.create!(name: "Test Product", price: 100, stock_quantity: 10, category: @electronics)
    product_id = product.id

    # The category deletion should fail due to foreign key constraint
    # since there's no dependent: :destroy set on the association
    assert_raises(ActiveRecord::InvalidForeignKey) do
      @electronics.destroy
    end

    # Product should still exist
    remaining_product = Product.find_by(id: product_id)
    assert_not_nil remaining_product, "Product should still exist"
    assert_equal @electronics.id, remaining_product.category_id
  end
end
