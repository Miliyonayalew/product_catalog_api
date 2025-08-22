class CreateProducts < ActiveRecord::Migration[5.0] # Adjust migration version if needed
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, default: 0.0
      t.integer :stock_quantity, default: 0
      t.references :category, foreign_key: true # This will create category_id column
      t.datetime :published_at
      t.boolean :is_featured, default: false # For the featuring task
      # Add a potential malicious attribute for mass assignment bug demo
      t.boolean :is_admin, default: false # This is the "phantom feature" attribute

      t.timestamps
    end
  end
end
