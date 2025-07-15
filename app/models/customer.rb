class Customer < ApplicationRecord
  has_many :audit_events, as: :auditable, dependent: :destroy
  has_many :purchases, dependent: :nullify

  validates :name, presence: true
  validates :surname, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :address, presence: true
  validates :registration_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive suspended] }

  scope :active, -> { where(status: "active") }
  scope :registered_before, ->(date) { where("registration_date <= ?", date) }

  before_create :set_default_status

  def full_name
    "#{name} #{surname}"
  end

  def can_be_deleted?
    purchases.empty?
  end

  private

  def set_default_status
    self.status ||= "active"
  end
end
