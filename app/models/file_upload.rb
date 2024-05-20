class FileUpload < ApplicationRecord
  belongs_to :user
  belongs_to :folder, optional: true

  validates :name, presence: true#, uniqueness: { scope: [:folder_id, :full_path] }

  before_create :generate_unique_token

  private

  def generate_unique_token
    self.unique_token = SecureRandom.hex(10)

    generate_unique_token if self.class.exists?(unique_token: self.unique_token)
  end
end
