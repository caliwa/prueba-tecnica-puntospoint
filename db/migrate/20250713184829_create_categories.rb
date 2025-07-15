class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, default: 'active'

      t.timestamps
    end

    add_index :categories, :name, unique: true
    add_index :categories, :status
  end
end
