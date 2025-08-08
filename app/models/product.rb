# This model has a `belongs_to` association that, combined with the controller,
# can lead to the N+1 problem and `nil` category names.
class Product < ApplicationRecord
  # BUG: `optional: true` allows products without a category.
  # This combined with the N+1 in the controller will manifest the bug.
  belongs_to :category, optional: true

  # Additional attributes for the challenge:
  # name:string
  # description:text
  # price:decimal
  # stock_quantity:integer
  # category_id:integer (foreign key to Category)
  # published_at:datetime
  # is_featured:boolean (default to false)
  # is_admin:boolean (default to false, for mass assignment vulnerability demo)

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }

  # Example method to get category name (controller will call this)
  # The `&.` (safe navigation) handles nil, but doesn't fix the N+1 or
  # underlying data issue if category_id points to a non-existent category.
  def category_name
    category&.name
  end
end 