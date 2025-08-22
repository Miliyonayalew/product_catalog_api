require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @electronics = categories(:electronics)
  end

  test "should be valid" do
    assert @electronics.valid?
  end

  test "should require name" do
    @electronics.name = ""
    assert_not @electronics.valid?
    assert_includes @electronics.errors[:name], "can't be blank"
  end

  test "should have many products" do
    assert_respond_to @electronics, :products
  end

  test "should require unique name" do
    duplicate_category = @electronics.dup
    assert_not duplicate_category.valid?
    assert_includes duplicate_category.errors[:name], "has already been taken"
  end
end
