class CreateCategories < ActiveRecord::Migration[5.0] # Adjust migration version if needed
  def change
    create_table :categories do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end
  end
end 