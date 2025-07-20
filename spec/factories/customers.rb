FactoryBot.define do
  factory :customer do
    name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.full_address }
    
    registration_date { Faker::Date.backward(days: 365) }
    
    status { 'active' }
  end
end