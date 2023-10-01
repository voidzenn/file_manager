FactoryBot.define do
  factory :folder do
    # We use sequence to make sure that the path is unique
    sequence(:path) { |n| "#{n}/" }
    user { create :user }
  end
end
