class FileUpload < ApplicationRecord
  belongs_to :folder

  validates :name, presence: true, uniqueness: { scope: :folder_id }
end
