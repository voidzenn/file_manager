FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "Password12!" }
    fname { Faker::Name.first_name }
    lname { Faker::Name.last_name }
  end
end
