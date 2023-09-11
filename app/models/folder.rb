class Folder < ApplicationRecord
  validates :name, presence: true
  validates :parent_id, numericality: { only_integer: true, greater_than: 0 },
            allow_blank: true
  validates :child_id, numericality: { only_integer: true, greater_than: 0 },
            allow_blank: true
end
