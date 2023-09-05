# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true,
            format: {
              with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
            }
  validates :password, presence: true
  validates :fname, presence: true
  validates :lname, presence: true
end
