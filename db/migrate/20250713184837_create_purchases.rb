class CreatePurchases < ActiveRecord::Migration[7.2]
  def change
    create_table :purchases do |t|
      t.references :customer, null: false, foreign_key: true
      t.datetime :purchase_date
      t.decimal :total, precision: 10, scale: 2
      t.string :status
      t.string :payment_method
      t.text :shipping_address

      t.timestamps
    end

    add_index :purchases, :purchase_date
    add_index :purchases, :status
  end
end
