class CreateCategorizations < ActiveRecord::Migration[7.2]
  def change
    create_table :categorizations do |t|
      t.references :category, null: false, foreign_key: true
      t.references :categorizable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :categorizations, [ :category_id, :categorizable_type, :categorizable_id ],
              unique: true, name: 'unique_categorization_index'
  end
end
