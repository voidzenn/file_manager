class Folder < ApplicationRecord
  belongs_to :user

  validates :user_id, numericality: { only_integer: true, greater_than: 0 }
  validates :path, presence: true,
            uniqueness: {
              scope: :user_id,
              case_sensitive: true,
              message: I18n.t("errors.models.folder.uniqueness.message")
            }
  validate :path_format

  private

  def path_format
    if path.present? && (path.start_with?("/") || !path.ends_with?("/"))
      errors.add(:path, I18n.t("errors.models.folder.format.message"))
    end
  end
end
