FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 10.0..1000.0) }
    stock { Faker::Number.between(from: 0, to: 100) }
    barcode { Faker::Barcode.unique.ean(13) }
    status { 'active' }
    brand { Faker::Company.name }

    # Asocia el producto con un creador (un usuario)
    association :creator, factory: :user

    # Permite añadir categorías al crear el producto
    # Ejemplo de uso: create(:product, categories: [cat1, cat2])
    transient do
      categories { [] }
    end

    after(:create) do |product, evaluator|
      evaluator.categories.each do |category|
        product.categories << category
      end
    end
  end
end
