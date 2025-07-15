class CreateAuditEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_events do |t|
      t.references :auditable, polymorphic: true, null: false

      t.string :event_type

      t.jsonb :old_values
      t.jsonb :new_values

      t.references :user, foreign_key: true, null: true

      t.jsonb :metadata

      t.timestamps
    end

    add_index :audit_events, :event_type
    add_index :audit_events, :created_at
  end
end
