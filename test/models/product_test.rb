require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @electronics = categories(:electronics)
    @laptop = products(:laptop)
  end

  test "should be valid" do
    assert @laptop.valid?
  end

  test "should require name" do
    @laptop.name = ""
    assert_not @laptop.valid?
    assert_includes @laptop.errors[:name], "can't be blank"
  end

  test "should require valid price" do
    @laptop.price = nil
    assert_not @laptop.valid?
    assert_includes @laptop.errors[:price], "is not a number"
  end

  test "should require non-negative price" do
    @laptop.price = -10
    assert_not @laptop.valid?
    assert_includes @laptop.errors[:price], "must be greater than or equal to 0"
  end

  test "should require non-negative stock quantity" do
    @laptop.stock_quantity = -5
    assert_not @laptop.valid?
    assert_includes @laptop.errors[:stock_quantity], "must be greater than or equal to 0"
  end

  test "should belong to category" do
    assert_respond_to @laptop, :category
  end

  test "category_name should return category name" do
    assert_equal "Electronics", @laptop.category_name
  end

  test "category_name should return nil when category is nil" do
    @laptop.category = nil
    assert_nil @laptop.category_name
  end

  test "is_featured? should return true when featured" do
    @laptop.update!(is_featured: true)
    assert @laptop.is_featured?
  end

  test "is_featured? should return false when not featured" do
    @laptop.update!(is_featured: false)
    assert_not @laptop.is_featured?
  end

  test "by_category scope should filter by category" do
    electronics_products = Product.by_category(@electronics.id)
    assert electronics_products.all? { |p| p.category_id == @electronics.id }
  end

  test "featured scope should return only featured products" do
    featured_products = Product.featured
    assert featured_products.all?(&:is_featured?)
  end

  test "published scope should return only published products" do
    published_products = Product.published
    assert published_products.all? { |p| p.published_at.present? }
  end

  test "in_stock scope should return only products with stock" do
    in_stock_products = Product.in_stock
    assert in_stock_products.all? { |p| p.stock_quantity > 0 }
  end
end
