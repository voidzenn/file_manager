class Folder < ApplicationRecord
  validates :user_id, numericality: { only_integer: true, greater_than: 0 }
  validates :path, presence: true
  validate :path_format

  private

  def path_format
    if path.present? && (path.start_with?("/") || !path.ends_with?("/"))
      errors.add(:path, I18n.t("errors.models.folder.path.format"))
    end
  end
end
