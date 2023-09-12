FactoryBot.define do
  factory :folder do
    name { Faker::Lorem.word }
    user { create :user }
  end
end
