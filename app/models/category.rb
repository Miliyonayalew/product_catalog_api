# A simple category model.
class Category < ApplicationRecord
  has_many :products

  # name:string
  validates :name, presence: true, uniqueness: true
end
