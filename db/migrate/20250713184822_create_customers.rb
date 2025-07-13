class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :surname
      t.string :email
      t.string :phone
      t.text :address
      t.date :registration_date
      t.string :status

      t.timestamps
    end
  end
end
