FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "admin12345" }
    fname { Faker::Name.first_name }
    lname { Faker::Name.last_name }
  end
end
