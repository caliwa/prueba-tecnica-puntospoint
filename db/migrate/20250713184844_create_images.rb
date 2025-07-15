class CreateImages < ActiveRecord::Migration[7.2]
  def change
    create_table :images do |t|
      t.references :imageable, polymorphic: true, null: false
      t.string :image_url
      t.text :description
      t.datetime :upload_date

      t.timestamps
    end

    add_index :images, [ :imageable_type, :imageable_id ], name: 'index_images_on_imageable_type_and_imageable_id'
  end
end
