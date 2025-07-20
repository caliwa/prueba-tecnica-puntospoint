FactoryBot.define do
  factory :purchase_item do
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { Faker::Commerce.price(range: 10.0..1000.0) }
    discount_amount { 0.0 }
    tax_amount { 0.0 }

    # Asocia el item con una compra
    association :purchase

    # Asocia el item con un "comprable", que por defecto será un producto
    association :purchasable, factory: :product

    # Calcula el total_price antes de guardar
    after(:build) do |item|
      item.total_price = (item.quantity * item.unit_price) - item.discount_amount + item.tax_amount
    end
  end
end