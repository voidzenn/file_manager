FactoryBot.define do
  factory :file_upload do
    folder { create :folder }
    name { 'test/' }
    full_path { 'test/test' }
  end
end
