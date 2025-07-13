class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :stock
      t.string :barcode
      t.string :brand
      t.string :model
      t.date :creation_date
      t.string :status

      t.timestamps
    end
  end
end
