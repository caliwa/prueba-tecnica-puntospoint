class CreateFirstPurchaseNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :first_purchase_notifications do |t|
      t.references :product, index: { unique: true }, null: false, foreign_key: true

      t.timestamps
    end
  end
end
