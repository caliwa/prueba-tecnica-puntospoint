class Product < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "created_by_user_id"

  has_many :audit_events, as: :auditable, dependent: :destroy
  has_many :categorizations, as: :categorizable, dependent: :destroy
  has_many :categories, through: :categorizations

  has_many :purchase_items, as: :purchasable, dependent: :destroy
  has_many :purchases, through: :purchase_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :barcode, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active inactive discontinued] }

  scope :active, -> { where(status: "active") }
  scope :in_stock, -> { where("stock > 0") }
  scope :in_category, ->(category) { joins(:categories).where(categories: { id: category.id }) }
  scope :low_stock, ->(threshold = 10) { where("stock <= ?", threshold) }
  scope :by_brand, ->(brand) { where(brand: brand) }
  scope :purchased_between, ->(start_date, end_date) {
    joins(:purchases).where(purchases: { purchase_date: start_date..end_date })
  }


  def remove_from_category(category)
    categorizations.where(category: category).destroy_all
  end

  def primary_category
    categorizations.ordered.first&.category
  end

  def total_sold
    purchase_items.sum(:quantity)
  end

  def total_revenue
    purchase_items.sum(:total_price)
  end

  def average_sale_price
    purchase_items.average(:unit_price) || 0
  end

  def recent_purchases(limit = 10)
    purchases.includes(:customer)
             .order(purchase_date: :desc)
             .limit(limit)
  end

  def sold_in_period(start_date, end_date)
    purchase_items.joins(:purchase)
                  .where(purchases: { purchase_date: start_date..end_date })
                  .sum(:quantity)
  end

  def reduce_stock!(quantity)
    if stock >= quantity
      update!(stock: stock - quantity)
    else
      raise "Stock insuficiente. Disponible: #{stock}, Solicitado: #{quantity}"
    end
  end

  def can_be_purchased?(quantity)
    stock >= quantity && status == "active"
  end
end
