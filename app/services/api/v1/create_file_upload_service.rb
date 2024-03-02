# frozen_string_literal: true

class Api::V1::CreateFileUploadService
  def initialize folder_id, filename, full_path
    @folder_id = folder_id
    @filename = filename
    @full_path = full_path
  end

  def perform
    create_file_upload
  end

  private

  attr_accessor :folder_id, :filename, :full_path

  def create_file_upload
    FileUpload.create!(
      folder_id: folder_id,
      name: filename,
      full_path: full_path
    )
  end
end
