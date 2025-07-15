class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.integer :stock, default: 0
      t.string :barcode, null: false
      t.string :brand
      t.string :model
      t.date :creation_date, default: -> { 'CURRENT_DATE' }
      t.string :status, default: 'active'

      t.references :created_by_user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :products, :barcode, unique: true
    add_index :products, :status
    add_index :products, :brand
  end
end
