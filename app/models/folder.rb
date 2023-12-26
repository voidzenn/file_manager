class Folder < ApplicationRecord
  PATH_FORMAT = /\A(?!\.\/)(?!.*\/.*\/)(\S+(?:\s+\S+)*)?(\.[a-zA-Z0-9_\-]+)?\/?\z/

  belongs_to :user

  validates :path, presence: true
  validate :validate_path_format
  validate :validate_path_uniqueness

  private

  def validate_path_format
    if path.present? && ((path.start_with?("/") || !path.ends_with?("/")) || !path.match?(PATH_FORMAT))
      errors.add(:path, I18n.t("errors.models.folder.format.message"))
    end
  end

  def validate_path_uniqueness
    return root_path_uniqueness if parent_folder_id.nil?

    child_path_uniqueness
  end

  def root_path_uniqueness
    unless self.class.find_by(user_id: user_id, path: path).nil?
      path_uniqueness_error
    end
  end

  def child_path_uniqueness
    unless self.class.find_by(user_id: user_id, parent_folder_id: parent_folder_id, path: path).nil?
      path_uniqueness_error
    end
  end

  def path_uniqueness_error
    errors.add(:path, I18n.t("errors.models.folder.uniqueness.message"))
  end
end
