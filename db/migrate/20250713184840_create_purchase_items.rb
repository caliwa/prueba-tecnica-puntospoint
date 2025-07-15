class CreatePurchaseItems < ActiveRecord::Migration[7.2]
  def change
    create_table :purchase_items do |t|
      t.references :purchase, null: false, foreign_key: true
      t.references :purchasable, polymorphic: true, null: false
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :purchase_items, [ :purchasable_type, :purchasable_id ], name: 'index_purchase_items_on_purchasable_type_and_purchasable_id'
    add_index :purchase_items, [ :purchase_id, :purchasable_type, :purchasable_id ],
              name: 'index_purchase_items_on_purchase_and_purchasable'

    add_index :purchase_items, [ :purchase_id, :purchasable_type, :purchasable_id ],
              unique: true, name: 'unique_purchase_item_index'
  end
end
