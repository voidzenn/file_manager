class Folder < ApplicationRecord
  validates :user_id, numericality: { only_integer: true, greater_than: 0 }
  validates :path, presence: true
end
