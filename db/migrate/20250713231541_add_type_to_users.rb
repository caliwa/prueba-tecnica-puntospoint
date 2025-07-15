class AddTypeToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :type, :string, default: "User"
  end
end
