class Api::V1::UploadFileJob < ApplicationJob
  def perform args = {}
    ActiveRecord::Base.transaction do
      Api::V1::CreateFileUploadService.new(
        args[:folder_object].id,
        args[:filename],
        args[:full_file_path]
      ).perform

      Api::V1::UploadFileMinioService.new(
        args[:bucket_token],
        args[:full_file_path],
        args[:file],
      ).perform
    end
  end
end
