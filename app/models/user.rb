# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :folders

  validates :email, presence: true, uniqueness: true,
            format: {
              with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
            }
  validates :password, presence: true, length: { mininum: 8, maximum: 20 },
            format: {
              with: /\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}\z/,
              message: 'must include at least one uppercase letter, one lowercase letter, one digit, and one special character'
            }
  validates :fname, presence: true
  validates :lname, presence: true
end
