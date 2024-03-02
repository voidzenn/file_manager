# frozen_string_literal: true

class Api::V1::UploadFileMinioService
  def initialize bucket_token, full_file_path, file
    @bucket_token = bucket_token
    @full_file_path = full_file_path
    @file = file
  end

  def perform
    upload_file
  end

  private

  attr_reader :bucket_token, :full_file_path, :file

  def upload_file
    bucket = Api::V1::GetCurrentBucketService.new(bucket_token).perform
    object = bucket.object(full_file_path)

    object.upload_file(file.path)
  end
end
