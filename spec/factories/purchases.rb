FactoryBot.define do
  factory :purchase do
    purchase_date { Faker::Date.between(from: 1.year.ago, to: Date.today) }
    total { 0.0 } # El total se calcula después con los items
    status { 'confirmed' }
    payment_method { 'credit_card' }
    shipping_address { Faker::Address.full_address }

    association :customer
  end
end
