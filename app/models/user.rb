class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_many :products, foreign_key: "created_by_user_id", dependent: :nullify

  TYPES = [ "User", "Admin" ]

  validates :type, inclusion: { in: TYPES }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  def admin?
    false
  end
end
