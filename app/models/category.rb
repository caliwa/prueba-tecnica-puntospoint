class Category < ApplicationRecord
  has_many :audit_events, as: :auditable, dependent: :destroy
  has_many :categorizations, dependent: :destroy
  has_many :products, through: :categorizations, source: :categorizable, source_type: "Product"
  has_many :subcategories, through: :categorizations, source: :categorizable, source_type: "Category"

  has_many :parent_categorizations, as: :categorizable, class_name: "Categorization"
  has_many :parent_categories, through: :parent_categorizations, source: :category

  validates :name, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active inactive] }

  scope :active, -> { where(status: "active") }
  scope :with_products, -> { joins(:products).distinct }
  scope :root_categories, -> { where.not(id: Categorization.where(categorizable_type: "Category").select(:categorizable_id)) }

  def products_count
    products.count
  end

  def subcategories_count
    subcategories.count
  end

  def is_subcategory?
    parent_categories.exists?
  end

  def can_be_deleted?
    products.empty? && subcategories.empty?
  end
end
