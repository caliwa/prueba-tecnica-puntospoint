class PurchaseItem < ApplicationRecord
  belongs_to :purchasable, polymorphic: true
  belongs_to :purchase

  belongs_to :product, class_name: 'Product', foreign_key: 'purchasable_id', optional: true


  validates :quantity, presence: true, numericality: { greater_than: 0 }
  # 2. Asociaciones directas y no polimórficas
  # Ahora puedes hacer `includes(:product)` directamente sobre un PurchaseItem


  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }
  validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_amount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_total_price
  after_save :update_purchase_total
  after_destroy :update_purchase_total

  scope :for_products, -> { where(purchasable_type: "Product") }
  scope :for_services, -> { where(purchasable_type: "Service") }
  scope :with_discount, -> { where("discount_amount > 0") }

  private

  def calculate_total_price
    if quantity.present? && unit_price.present?
      subtotal = quantity * unit_price
      self.total_price = subtotal - discount_amount + tax_amount
    end
  end

  def update_purchase_total
    purchase.update_total!
  end
end
