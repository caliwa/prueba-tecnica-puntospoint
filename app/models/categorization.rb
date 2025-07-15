class Categorization < ApplicationRecord
  belongs_to :category
  belongs_to :categorizable, polymorphic: true

  validates :category_id, uniqueness: {
    scope: [ :categorizable_type, :categorizable_id ],
    message: "Ya existe esta categorización"
  }

  scope :for_products, -> { where(categorizable_type: "Product") }
  scope :for_categories, -> { where(categorizable_type: "Category") }
  scope :by_category, ->(category) { where(category: category) }
end
