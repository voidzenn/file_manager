# frozen_string_literal: true

class Api::V1::GetFileUrlMinioService
  def initialize bucket_token, file_path
    @bucket_token = bucket_token
    @file_path = file_path
  end

  def perform
    load_file
  end

  private

  attr_reader :bucket_token, :file_path

  def load_file
    bucket = Api::V1::GetCurrentBucketService.new(bucket_token).perform

    bucket.object(file_path).presigned_url(:get, expires_in: MINIO_GET_FILE_EXPIRATION)
  end
end
