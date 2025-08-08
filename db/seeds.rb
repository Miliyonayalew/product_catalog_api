# This file will populate your database with some initial data,
# including products with missing categories to demonstrate the N+1 bug.
# Clear existing data
Product.destroy_all
Category.destroy_all

# Create categories
electronics = Category.create!(name: 'Electronics')
books = Category.create!(name: 'Books')
clothing = Category.create!(name: 'Clothing')

# Create products
Product.create!([
  {
    name: 'Laptop Pro X',
    description: 'Powerful laptop for professionals.',
    price: 1200.00,
    stock_quantity: 50,
    category: electronics,
    published_at: Time.current
  },
  {
    name: 'The Great Novel',
    description: 'A captivating story.',
    price: 15.99,
    stock_quantity: 200,
    category: books,
    published_at: Time.current
  },
  {
    name: 'Wireless Headphones',
    description: 'High-fidelity sound.',
    price: 79.99,
    stock_quantity: 150,
    category: electronics,
    published_at: 1.day.ago
  },
  {
    name: 'Vintage T-Shirt',
    description: 'Comfortable cotton tee.',
    price: 25.00,
    stock_quantity: 100,
    category: clothing,
    published_at: Time.current,
    is_featured: true
  },
  {
    name: 'Product With Missing Category', # This product will have category_id: nil
    description: 'This product has no assigned category, demonstrating the nil issue.',
    price: 10.00,
    stock_quantity: 10,
    # category_id is explicitly nil here, or you can omit `category:` to make it nil
    category_id: nil,
    published_at: Time.current
  },
  {
    name: 'Another Book',
    description: 'Another great read.',
    price: 12.50,
    stock_quantity: 75,
    category: books,
    published_at: 2.days.ago
  },
  # For demonstrating mass assignment vulnerability, you can imagine
  # this product being created or updated with `is_admin: true` from the API.
  {
    name: 'Secret Admin Product',
    description: 'Only admins should manage this.',
    price: 999.00,
    stock_quantity: 1,
    category: electronics,
    published_at: Time.current,
    is_admin: false # This would be flipped by the bug if exposed via mass assignment.
  }
])

puts "Seeding complete! Created {Product.count} products and {Category.count} categories."
