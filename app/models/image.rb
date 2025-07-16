class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true # La relación polimórfica original

  # --- Solución Avanzada para Carga Específica ---
  # 1. Auto-referencia
  has_one :self_ref, class_name: 'Image', foreign_key: :id

  # 2. Asociaciones directas
  has_one :product, through: :self_ref, source: :imageable, source_type: 'Product'
  has_one :user, through: :self_ref, source: :imageable, source_type: 'User'


  validates :image_url, presence: true
end
