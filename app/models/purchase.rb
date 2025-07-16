class Purchase < ApplicationRecord
  belongs_to :customer
  has_many :purchase_items, dependent: :destroy

  # Clave: Permite hacer `joins(:products)` para filtrar.
  has_many :products, through: :purchase_items, source: :purchasable, source_type: "Product"

  validates :purchase_date, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[pending confirmed shipped delivered cancelled] }
  validates :payment_method, inclusion: { in: %w[credit_card debit_card cash bank_transfer paypal] }

  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :delivered, -> { where(status: "delivered") }
  scope :by_date_range, ->(start_date, end_date) { where(purchase_date: start_date..end_date) }
  scope :by_payment_method, ->(method) { where(payment_method: method) }

  def add_product(product, quantity, unit_price = nil, discount: 0, tax: 0)
    unit_price ||= product.price

    purchase_items.create!(
      purchasable: product,
      quantity: quantity,
      unit_price: unit_price,
      discount_amount: discount,
      tax_amount: tax
    )
  end

  def remove_product(product)
    purchase_items.where(purchasable: product).destroy_all
  end

  def update_total!
    calculated_total = purchase_items.sum(:total_price)
    update!(total: calculated_total)
  end

  def total_items
    purchase_items.sum(:quantity)
  end

  def total_discount
    purchase_items.sum(:discount_amount)
  end

  def total_tax
    purchase_items.sum(:tax_amount)
  end

  def subtotal
    purchase_items.sum("quantity * unit_price")
  end

  def has_product?(product)
    purchase_items.exists?(purchasable: product)
  end

  def product_quantity(product)
    purchase_items.find_by(purchasable: product)&.quantity || 0
  end
end
