# frozen_string_literal: true

class Api::V1::CreateFileUploadService
  def initialize current_user, folder_id, filename, full_path
    @current_user = current_user
    @folder_id = folder_id
    @filename = filename
    @full_path = full_path
  end

  def perform
    create_file_upload
  end

  private

  attr_accessor :current_user, :folder_id, :filename, :full_path

  def create_file_upload
    FileUpload.create!(
      user_id: current_user.id,
      folder_id: folder_id,
      name: filename,
      full_path: full_path
    )
  end
end
