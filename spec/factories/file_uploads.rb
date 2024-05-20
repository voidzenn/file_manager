FactoryBot.define do
  factory :file_upload do
    user { create :user }
    folder { create :folder }
    name { 'test/' }
    full_path { 'test/test' }
  end
end
