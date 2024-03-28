class Folder < ApplicationRecord
  PATH_FORMAT = /\A(?!\.\/)(?!.*\/.*\/)(\S+(?:\s+\S+)*)?(\.[a-zA-Z0-9_\-]+)?\/?\z/

  belongs_to :user
  has_many :file_uploads

  before_create :generate_unique_token

  scope :order_by_date, -> { order(created_at: :desc) }

  validates :path, presence: true
  validates :full_path, uniqueness: { allow_blank: true }
  validate :validate_path_format
  validate :validate_path_uniqueness, if: -> { path_changed? }
  validate :validate_path_not_changed

  private

  def generate_unique_token
    self.unique_token = SecureRandom.hex(10)

    generate_unique_token if self.class.exists?(unique_token: self.unique_token)
  end

  def validate_path_format
    if path.present? && ((path.start_with?('/') || !path.ends_with?('/')) || !path.match?(PATH_FORMAT))
      errors.add(:path, I18n.t('errors.models.folder.format.message'))
    end
  end

  def validate_path_uniqueness
    return root_path_uniqueness if parent_folder_id.nil?

    child_path_uniqueness
  end

  def validate_path_not_changed
    if persisted? && path.present? && !path_changed?
      errors.add(:path, I18n.t('errors.models.folder.same_as_previous_path_name.message'))
    end
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
