# frozen_string_literal: true

class Api::V1::CreateFileUploadService
  def initialize user_id, folder_id, filename, full_path
    @user_id = user_id
    @folder_id = folder_id
    @filename = filename
    @full_path = full_path
  end

  def perform
    create_file_upload
    broadcast_file_created
  end

  private

  attr_accessor :user_id, :folder_id, :filename, :full_path

  def create_file_upload
    @file_upload = FileUpload.create!(
      user_id: user_id,
      folder_id: folder_id,
      name: filename,
      full_path: full_path
    )
  end

  def broadcast_file_created
    FileChannel.broadcast_file_created(
      [Api::V1::FileUploadSerializer.new(@file_upload).serializable_hash]
    )
  end
end
