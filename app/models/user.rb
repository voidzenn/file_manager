# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :folders

  before_create :generate_unique_token
  before_create :generate_bucket_token

  validates :email, presence: true, uniqueness: true,
            format: {
              with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
            }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 },
            format: {
              with: /\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}\z/,
              message: 'must include at least one uppercase letter, one lowercase letter, one digit, and one special character'
            }
  validates :fname, presence: true
  validates :lname, presence: true

  private

  def generate_unique_token
    self.unique_token = SecureRandom.hex(10)

    generate_unique_token if self.class.exists?(unique_token: self.unique_token)
  end

  def generate_bucket_token
    self.bucket_token = SecureRandom.uuid

    generate_bucket_token if self.class.exists?(bucket_token: self.bucket_token)
  end
end
