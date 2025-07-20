FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    type { 'User' } # Por defecto, crea un usuario normal

    # Trait para crear un Admin
    trait :admin do
      type { 'Admin' }
    end

    # Fábrica específica para crear un admin directamente
    factory :admin, traits: [ :admin ]
  end
end
