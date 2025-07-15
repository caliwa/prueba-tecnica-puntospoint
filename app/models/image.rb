class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  validates :image_url, presence: true
end
