class FirstPurchaseNotification < ApplicationRecord
  belongs_to :product

  validates :product, presence: true

  validates :product_id, uniqueness: true

end
