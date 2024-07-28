FactoryBot.define do
  factory :file_upload do
    user { create :user }
    folder { create :folder }
    name { 'test.doc' }
    full_path { 'test.doc' }
  end
end
