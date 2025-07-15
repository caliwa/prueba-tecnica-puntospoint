class AuditEvent < ApplicationRecord

  belongs_to :auditable, polymorphic: true

  belongs_to :user, optional: true

  scope :for_model, ->(model) { where(auditable: model) }

  scope :of_type, ->(event_type) { where(event_type: event_type) }

  # --- MÉTODOS DE INSTANCIA ---
  # Devuelve un array con los nombres de los campos que cambiaron
  # entre `old_values` y `new_values`.
  def changed_fields
    return [] if old_values.blank? || new_values.blank?

    new_values.select { |key, value| old_values[key] != value }.keys
  end
end
